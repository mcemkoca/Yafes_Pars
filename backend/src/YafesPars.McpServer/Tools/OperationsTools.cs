using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Operationele tools: vervaldagbeheer (verlengingen) en FSMA-rapportage.
/// Alles tenant-scoped.
/// </summary>
[McpServerToolType]
public sealed class OperationsTools
{
    private readonly IReadRepository _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public OperationsTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read = read;
        _write = write;
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Toon polissen die binnenkort vervallen. / Yakında vadesi dolan poliçeleri göster.\n" +
        "Standaard binnen 60 dagen. Voor opvolging vóór verlenging.")]
    public async Task<string> GetExpiringPolicies(
        [Description("Aantal dagen vooruit (standaard 60) / Kaç gün ileri")] int daysAhead = 60,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT c.contract_id, c.contract_number, c.contract_domain_code, c.contract_type_code,
                   c.start_date, c.end_date, c.contract_status_code,
                   DATEDIFF(DAY, CAST(SYSUTCDATETIME() AS DATE), c.end_date) AS days_until_expiry
            FROM policy.Contract c
            WHERE c.tenant_id = @tenantId
              AND c.is_deleted = 0
              AND c.contract_status_code = 'ACTIVE'
              AND c.end_date IS NOT NULL
              AND c.end_date BETWEEN CAST(SYSUTCDATETIME() AS DATE)
                                 AND DATEADD(DAY, @daysAhead, CAST(SYSUTCDATETIME() AS DATE))
            ORDER BY c.end_date ASC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new { tenantId = _ctx.TenantId, daysAhead }, ct);

        return rows.Count == 0
            ? $"Geen polissen die binnen {daysAhead} dagen vervallen. / {daysAhead} gün içinde vadesi dolan poliçe yok."
            : JsonSerializer.Serialize(new { count = rows.Count, daysAhead, policies = rows }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Maak verlengingstaken aan voor binnenkort vervallende polissen. / Yenileme görevleri oluştur.\n" +
        "dryRun=true (standaard) toont alleen het aantal; dryRun=false maakt de taken echt aan.")]
    public async Task<string> CreateRenewalTasks(
        [Description("Aantal dagen vooruit (standaard 60)")] int daysAhead = 60,
        [Description("true = alleen tellen (standaard), false = taken aanmaken")] bool dryRun = true,
        CancellationToken ct = default)
    {
        try
        {
            await _write.ExecuteAsync(
                "EXEC tasking.SP_CreateRenewalTasks @tenant_id = @tenant_id, @days_ahead = @days_ahead, @dry_run = @dry_run;",
                new { tenant_id = _ctx.TenantId, days_ahead = daysAhead, dry_run = dryRun ? 1 : 0 },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                dryRun,
                daysAhead,
                message = dryRun
                    ? $"Dry-run voltooid ({daysAhead} dagen). Roep opnieuw aan met dryRun=false om de taken echt aan te maken."
                    : $"Verlengingstaken aangemaakt voor polissen die binnen {daysAhead} dagen vervallen."
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "FSMA/IDD-rapportage: polis-overzicht met premie en schade per contract. / FSMA raporu.\n" +
        "Gebaseerd op reporting.VW_FsmaReport. Voor toezichtsrapportage (Belgische FSMA).")]
    public async Task<string> GetFsmaReport(
        [Description("Max aantal regels (standaard 100)")] int limit = 100,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT TOP (@limit)
                contract_number, tak, productcode, status,
                vn_naam, vn_rrn, vn_kbo,
                ingangsdatum, vervaldatum,
                totaal_premie_eur, aantal_schaden, totaal_gereserveerd_eur, totaal_betaald_eur
            FROM reporting.VW_FsmaReport
            WHERE tenant_id = @tenantId
            ORDER BY ingangsdatum DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new { tenantId = _ctx.TenantId, limit }, ct);

        return rows.Count == 0
            ? "Geen FSMA-rapportgegevens. / FSMA rapor verisi yok."
            : JsonSerializer.Serialize(new { count = rows.Count, report = rows }, JsonOpts.Default);
    }
}
