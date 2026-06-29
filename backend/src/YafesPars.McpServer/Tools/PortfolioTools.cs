using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Portefeuille-analyse tools. Read-only, tenant-scoped.
/// </summary>
[McpServerToolType]
public sealed class PortfolioTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public PortfolioTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Portefeuille-overzicht per tak en status. / Tak ve duruma göre portföy özeti.\n" +
        "Premie (rolling 12 maanden), aantal schaden, schadelast en loss ratio. " +
        "Gebaseerd op reporting.VW_PortfolioSummary.")]
    public async Task<string> GetPortfolioSummary(
        [Description("Tak filter (optioneel, bv. 'AUTO', 'FIRE')")] string? tak = null,
        [Description("Status filter (optioneel, bv. 'ACTIVE')")] string? statusCode = null,
        CancellationToken ct = default)
    {
        var sql = $"""
            SELECT
                tak, status, contract_count,
                totaal_premie_eur, totaal_schaden,
                totaal_gereserveerd_eur, totaal_betaald_eur, loss_ratio
            FROM reporting.VW_PortfolioSummary
            WHERE tenant_id = @tenantId
              {(tak is not null ? "AND tak = @tak" : "")}
              {(statusCode is not null ? "AND status = @statusCode" : "")}
            ORDER BY totaal_premie_eur DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new
        {
            tenantId = _ctx.TenantId,
            tak,
            statusCode
        }, ct);

        return rows.Count == 0
            ? "Geen portefeuillegegevens gevonden. / Portföy verisi bulunamadı."
            : JsonSerializer.Serialize(new { count = rows.Count, summary = rows }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Risicoconcentratie: top takken op premievolume en schadelast. / Risk yoğunlaşması.\n" +
        "Helpt bij het identificeren van takken met een ongunstige loss ratio.")]
    public async Task<string> GetRiskConcentration(
        [Description("Max aantal takken (standaard 10)")] int limit = 10,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT TOP (@limit)
                tak,
                SUM(contract_count)            AS contract_count,
                SUM(totaal_premie_eur)         AS totaal_premie_eur,
                SUM(totaal_betaald_eur)        AS totaal_betaald_eur,
                CASE
                    WHEN SUM(totaal_premie_eur) = 0 THEN NULL
                    ELSE ROUND(SUM(totaal_betaald_eur) / SUM(totaal_premie_eur), 4)
                END                            AS loss_ratio
            FROM reporting.VW_PortfolioSummary
            WHERE tenant_id = @tenantId
            GROUP BY tak
            ORDER BY totaal_premie_eur DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new { tenantId = _ctx.TenantId, limit }, ct);

        return rows.Count == 0
            ? "Geen risicogegevens gevonden. / Risk verisi bulunamadı."
            : JsonSerializer.Serialize(new { count = rows.Count, concentration = rows }, JsonOpts.Default);
    }
}
