using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Legacy veri göçü araçları — import.LegacyPerson / LegacyContract / LegacyClaim tabloları.
/// NOT: Bu araçlar migration 043'teki staging tablolarını yönetir.
/// import.PolicyImport'u hedefleyen ImportTools.cs ile çakışmaz.
/// </summary>
[McpServerToolType]
public sealed class LegacyImportTools
{
    private readonly IReadRepository  _read;
    private readonly OperatorContext  _ctx;

    public LegacyImportTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx  = ctx;
    }

    [McpServerTool, Description(
        "Legacy kişi kayıtlarını içe aktar (import.LegacyPerson). / Personen importeren vanuit legacy.\n" +
        "batchSize: işlenecek maksimum satır sayısı (varsayılan 500, maks 500).\n" +
        "dryRun=true: gerçekten yazmadan özetler; false: kayıtları core.Person'a işler.\n" +
        "Belgika: CURSOR tabanlı, yeniden çalıştırılabilir (idempotent per legacy_bet_id).\n" +
        "Sonuç: processed, succeeded, failed, dryOk sayıları.")]
    public async Task<string> ImportLegacyPersons(
        [Description("İşlenecek satır sayısı (varsayılan 500)")] int batchSize = 500,
        [Description("true = simülasyon, false = gerçek yazma")] bool dryRun = true,
        CancellationToken ct = default)
    {
        var clampedBatch = Math.Clamp(batchSize, 1, 500);

        var rows = await _read.QueryAsync<ImportResultRow>(
            "import.SP_ImportLegacyPersons",
            new
            {
                tenant_id  = _ctx.TenantId,
                batch_size = clampedBatch,
                dry_run    = dryRun ? 1 : 0
            }, ct);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "SP yanıt dönmedi." });

        return JsonSerializer.Serialize(new
        {
            dryRun,
            batchSize = clampedBatch,
            processed  = row.Processed,
            succeeded  = row.Succeeded,
            failed     = row.Failed,
            dryOk      = row.DryOk,
            message    = dryRun
                ? $"DRY RUN: {row.DryOk} kayıt geçerli, {row.Failed} hata."
                : $"{row.Succeeded} kayıt işlendi, {row.Failed} hata."
        });
    }

    [McpServerTool, Description(
        "Tüm legacy staging tablolarının import özeti. / Overzicht van alle legacy importtabellen.\n" +
        "LegacyPerson, LegacyContract ve LegacyClaim tablolarından PENDING/DONE/ERROR/DRY_OK sayılarını döner.\n" +
        "Bağımsız çalışır — tenant filtresi uygulanmaz (import öncesi cross-tenant görünürlük).")]
    public async Task<string> GetLegacyImportSummary(CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<ImportSummaryRow>(
            "import.SP_GetImportSummary",
            new { }, ct);

        return JsonSerializer.Serialize(new
        {
            tables = rows,
            totalRows    = rows.Sum(r => r.TotalRows),
            totalPending  = rows.Sum(r => r.PendingCount),
            totalDone     = rows.Sum(r => r.DoneCount),
            totalError    = rows.Sum(r => r.ErrorCount),
            totalDryOk    = rows.Sum(r => r.DryOkCount),
            readyToImport = rows.All(r => r.ErrorCount == 0),
            message = rows.All(r => r.ErrorCount == 0)
                ? "Tüm staging tablolar temiz — import başlatılabilir."
                : "Hatalı kayıtlar mevcut — önce hataları gözden geçir."
        });
    }

    [McpServerTool, Description(
        "Legacy staging tablosundaki hatalı kayıtları listele. / Foutieve legacy-importrijen weergeven.\n" +
        "tableName: LegacyPerson | LegacyContract | LegacyClaim\n" +
        "ERROR durumundaki satırların import_error mesajlarını döner (maks 100 satır).")]
    public async Task<string> GetLegacyImportErrors(
        [Description("Tablo adı: LegacyPerson | LegacyContract | LegacyClaim")] string tableName,
        CancellationToken ct = default)
    {
        var allowed = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            { "LegacyPerson", "LegacyContract", "LegacyClaim" };

        if (!allowed.Contains(tableName))
            return JsonSerializer.Serialize(new
            {
                error = $"Geçersiz tablo adı '{tableName}'. İzin verilenler: {string.Join(", ", allowed)}"
            });

        var sql = tableName.ToUpperInvariant() switch
        {
            "LEGACYPERSON" =>
                "SELECT TOP 100 legacy_bet_id AS legacy_id, import_status, import_error FROM import.LegacyPerson WHERE import_status = N'ERROR' ORDER BY legacy_bet_id",
            "LEGACYCONTRACT" =>
                "SELECT TOP 100 legacy_contract_id AS legacy_id, import_status, import_error FROM import.LegacyContract WHERE import_status = N'ERROR' ORDER BY legacy_contract_id",
            _ =>
                "SELECT TOP 100 legacy_schade_id AS legacy_id, import_status, import_error FROM import.LegacyClaim WHERE import_status = N'ERROR' ORDER BY legacy_schade_id"
        };

        var rows = await _read.QueryAsync<LegacyErrorRow>(sql, null, ct);

        return JsonSerializer.Serialize(new
        {
            tableName,
            errorCount = rows.Count,
            errors     = rows
        });
    }

    // -------------------------------------------------------------------------
    private sealed record ImportResultRow(int Processed, int Succeeded, int Failed, int DryOk);

    private sealed record ImportSummaryRow(
        string TableName,
        int    TotalRows,
        int    PendingCount,
        int    DoneCount,
        int    ErrorCount,
        int    DryOkCount);

    private sealed record LegacyErrorRow(long LegacyId, string ImportStatus, string? ImportError);
}
