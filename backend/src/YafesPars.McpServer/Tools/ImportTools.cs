using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Bulk import tools voor polissen (staging-flow). Tenant-scoped.
/// Stap 1: StageImportRows  → rijen in import.PolicyImport laden
/// Stap 2: ValidateImportBatch → validatie uitvoeren (dryRun standaard)
/// Stap 3: GetImportBatchStatus → status per rij inzien
/// </summary>
[McpServerToolType]
public sealed class ImportTools
{
    private readonly IReadRepository _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public ImportTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read = read;
        _write = write;
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Laad ruwe polis-rijen in de import-staging tabel. / Ham poliçe satırlarını staging tablosuna yükle.\n" +
        "Geeft een batch_id terug voor gebruik in ValidateImportBatch en GetImportBatchStatus.\n" +
        "rows: JSON-array met velden contract_number, contract_domain_code, contract_type_code, " +
        "start_date (yyyy-MM-dd), end_date (yyyy-MM-dd), policyholder_rrn, policyholder_name, " +
        "gross_premium, currency_code.")]
    public async Task<string> StageImportRows(
        [Description("JSON-array van polis-rijen")] string rowsJson,
        CancellationToken ct = default)
    {
        List<JsonElement>? rows;
        try
        {
            rows = JsonSerializer.Deserialize<List<JsonElement>>(rowsJson);
        }
        catch
        {
            return "Fout: rowsJson is geen geldige JSON-array.";
        }

        if (rows is null || rows.Count == 0)
            return "Fout: geen rijen opgegeven.";
        if (rows.Count > 500)
            return "Fout: maximaal 500 rijen per batch.";

        var batchId = Guid.NewGuid();
        int rowNum = 0;

        foreach (var row in rows)
        {
            rowNum++;
            string? Get(string key) =>
                row.TryGetProperty(key, out var v) ? v.GetString() : null;

            try
            {
                await _write.ExecuteAsync(
                    """
                    INSERT INTO import.PolicyImport (
                        batch_id, tenant_id, row_number,
                        contract_number, contract_domain_code, contract_type_code,
                        start_date, end_date,
                        policyholder_rrn, policyholder_name,
                        gross_premium, currency_code
                    ) VALUES (
                        @batchId, @tenantId, @rowNum,
                        @contractNumber, @contractDomainCode, @contractTypeCode,
                        @startDate, @endDate,
                        @policyholderRrn, @policyholderName,
                        @grossPremium, @currencyCode
                    );
                    """,
                    new
                    {
                        batchId,
                        tenantId = _ctx.TenantId,
                        rowNum,
                        contractNumber = Get("contract_number"),
                        contractDomainCode = Get("contract_domain_code"),
                        contractTypeCode = Get("contract_type_code"),
                        startDate = Get("start_date"),
                        endDate = Get("end_date"),
                        policyholderRrn = Get("policyholder_rrn"),
                        policyholderName = Get("policyholder_name"),
                        grossPremium = Get("gross_premium"),
                        currencyCode = Get("currency_code")
                    },
                    ct);
            }
            catch (SqlException ex)
            {
                return $"Databasefout rij {rowNum}: {ex.Message}";
            }
        }

        return JsonSerializer.Serialize(new
        {
            success = true,
            batchId,
            stagedRows = rowNum,
            message = $"{rowNum} rijen geladen. Gebruik ValidateImportBatch met batchId '{batchId}'."
        }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Valideer een import-batch. / Bir import toplu işlemini doğrula.\n" +
        "Controleert verplichte velden en datumformaten. Geeft valid/invalid aantallen terug.")]
    public async Task<string> ValidateImportBatch(
        [Description("Batch-ID teruggegeven door StageImportRows")] Guid batchId,
        CancellationToken ct = default)
    {
        try
        {
            var result = await _write.ExecuteScalarAsync<string>(
                """
                DECLARE @valid INT, @invalid INT;
                EXEC import.SP_ValidateImportBatch
                    @tenant_id     = @tenantId,
                    @batch_id      = @batchId,
                    @valid_count   = @valid   OUTPUT,
                    @invalid_count = @invalid OUTPUT;
                SELECT CAST(@valid AS NVARCHAR) + '|' + CAST(@invalid AS NVARCHAR);
                """,
                new { tenantId = _ctx.TenantId, batchId },
                ct);

            var parts = (result ?? "0|0").Split('|');
            int valid = int.TryParse(parts[0], out var v) ? v : 0;
            int invalid = int.TryParse(parts.Length > 1 ? parts[1] : "0", out var i) ? i : 0;

            return JsonSerializer.Serialize(new
            {
                batchId,
                validRows = valid,
                invalidRows = invalid,
                ready = invalid == 0,
                message = invalid == 0
                    ? $"Batch geldig: {valid} rijen klaar voor import."
                    : $"{invalid} rij/rijen ongeldig. Gebruik GetImportBatchStatus om de fouten te zien."
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Toon de validatie-status van elke rij in een batch. / Batch satırlarının doğrulama durumunu göster.\n" +
        "Filter op PENDING, VALID, INVALID of IMPORTED.")]
    public async Task<string> GetImportBatchStatus(
        [Description("Batch-ID")] Guid batchId,
        [Description("Status filter: PENDING, VALID, INVALID, IMPORTED (optioneel)")] string? statusFilter = null,
        CancellationToken ct = default)
    {
        var sql = $"""
            SELECT
                row_number, contract_number, contract_domain_code,
                start_date, validation_status, validation_errors
            FROM import.PolicyImport
            WHERE batch_id  = @batchId
              AND tenant_id = @tenantId
              {(statusFilter is not null ? "AND validation_status = @statusFilter" : "")}
            ORDER BY row_number
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new
        {
            batchId,
            tenantId = _ctx.TenantId,
            statusFilter
        }, ct);

        return rows.Count == 0
            ? $"Geen rijen gevonden voor batch {batchId}."
            : JsonSerializer.Serialize(new { batchId, count = rows.Count, rows }, JsonOpts.Default);
    }
}
