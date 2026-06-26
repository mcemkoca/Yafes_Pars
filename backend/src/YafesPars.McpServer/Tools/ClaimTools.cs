using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class ClaimTools
{
    private readonly IReadRepository _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public ClaimTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read = read;
        _write = write;
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Haal schadedossiers op van een polis. / Bir poliçenin hasar dosyalarını listele.\n" +
        "Statussen / Durumlar: OPEN, IN_PROGRESS, CLOSED, PENDING.")]
    public async Task<string> GetClaims(
        [Description("Polis-ID (UUID)")] Guid contractId,
        [Description("Statusfilter: OPEN, CLOSED, PENDING, IN_PROGRESS")] string? statusCode = null,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT cl.claim_id, cl.claim_number, cl.claim_status_code,
                   cl.incident_date, cl.reported_date, cl.closed_date,
                   cl.paid_amount, cl.reserved_amount,
                   c.contract_number
            FROM claim.Claim cl
            INNER JOIN policy.Contract c ON c.contract_id = cl.contract_id
            WHERE cl.tenant_id = @tenantId
              AND cl.contract_id = @contractId
              AND (@statusCode IS NULL OR cl.claim_status_code = @statusCode)
            ORDER BY cl.reported_date DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql,
            new { tenantId = _ctx.TenantId, contractId, statusCode }, ct);

        return rows.Count == 0
            ? "Bu poliçeye ait hasar dosyası bulunamadı."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Registreer een nieuw schadegeval. / Yeni hasar bildirimi oluştur.\n" +
        "Dekkingscodes: BA_AUTO, OMNIUM, FIRE_BUILDING, FIRE_CONTENTS, HOSPITALIZATION, enz.")]
    public async Task<string> CreateClaim(
        [Description("Polis-ID (UUID)")] Guid contractId,
        [Description("Datum van het schadegeval (YYYY-MM-DD)")] DateOnly incidentDate,
        [Description("Beschrijving van de schade / Hasar açıklaması")] string description,
        [Description("Dekkingscode bijv. BA_AUTO, OMNIUM, FIRE_BUILDING")] string? coverageCode = null,
        [Description("Geraamd schadebedrag / Tahmini hasar tutarı")] decimal? reservedAmount = null,
        CancellationToken ct = default)
    {
        var claimNumber = $"S{DateTime.UtcNow:yyyyMMdd}-{Random.Shared.Next(1000, 9999)}";

        var sql = """
            INSERT INTO claim.Claim
                (tenant_id, contract_id, claim_number, claim_status_code,
                 coverage_code, incident_date, reported_date, reserved_amount)
            OUTPUT inserted.claim_id
            VALUES
                (@tenantId, @contractId, @claimNumber, 'OPEN',
                 @coverageCode, @incidentDate, CAST(SYSUTCDATETIME() AS DATE), @reservedAmount);
            """;

        var id = await _write.ExecuteScalarAsync<Guid>(sql,
            new { tenantId = _ctx.TenantId, contractId, claimNumber, coverageCode, incidentDate, reservedAmount }, ct);

        return JsonSerializer.Serialize(new
        {
            success = true,
            claimId = id,
            claimNumber,
            message = $"Schadedossier aangemaakt: {claimNumber} (ID: {id})"
        }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Sluit een schadedossier af. / Hasar dosyasını kapat.\n" +
        "Vereist: claimId en betaald bedrag. Status wordt CLOSED.")]
    public async Task<string> CloseClaim(
        [Description("Schadedossier-ID (UUID)")] Guid claimId = default,
        [Description("Uitbetaald bedrag / Ödenen tutar")] decimal? paidAmount = null,
        [Description("Afsluitreden bijv. VERGOED, AFGEWEZEN, INGETROKKEN")] string? closureReason = null,
        CancellationToken ct = default)
    {
        if (claimId == default)
            return "Fout: claimId is verplicht.";

        try
        {
            await _write.ExecuteAsync(
                "EXEC claim.sp_CloseClaim @tenant_id, @claim_id, @paid_amount, @closure_reason, NULL;",
                new
                {
                    tenant_id = _ctx.TenantId,
                    claim_id = claimId,
                    paid_amount = paidAmount,
                    closure_reason = closureReason
                },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                message = $"Schadedossier {claimId} afgesloten. Betaald: {paidAmount?.ToString("N2") ?? "n.v.t."}"
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }
}
