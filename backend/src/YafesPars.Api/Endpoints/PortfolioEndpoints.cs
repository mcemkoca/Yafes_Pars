using System.Security.Claims;
using YafesPars.Api.Security;
using YafesPars.Application.Abstractions;
using YafesPars.Application.ReadModels;

namespace YafesPars.Api.Endpoints;

public static class PortfolioEndpoints
{
    public static IEndpointRouteBuilder MapPortfolioEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/portfolio")
            .WithTags("Portfolio")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("tenant");

        api.MapGet("/summary", QueryPortfolioSummaryAsync);
        api.MapGet("/risk-concentration", QueryRiskConcentrationAsync);

        return app;
    }

    private static async Task<IResult> QueryPortfolioSummaryAsync(
        ClaimsPrincipal user,
        string? tak,
        string? status,
        IReadRepository repo,
        CancellationToken ct)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var sql = $"""
            SELECT
                tak             AS Tak,
                status          AS Status,
                contract_count  AS ContractCount,
                totaal_premie_eur AS TotaalPremieEur,
                totaal_schaden  AS TotaalSchaden,
                totaal_gereserveerd_eur AS TotaalGereserveerdEur,
                totaal_betaald_eur AS TotaalBetaaldEur,
                loss_ratio      AS LossRatio
            FROM reporting.VW_PortfolioSummary
            WHERE tenant_id = @tenantId
              {(tak is not null ? "AND tak = @tak" : "")}
              {(status is not null ? "AND status = @status" : "")}
            ORDER BY totaal_premie_eur DESC
            """;

        var rows = await repo.QueryAsync<PortfolioRow>(sql,
            new { tenantId, tak, status }, ct);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryRiskConcentrationAsync(
        ClaimsPrincipal user,
        int? take,
        IReadRepository repo,
        CancellationToken ct)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var limit = Math.Clamp(take.GetValueOrDefault(10), 1, 50);

        const string sql = """
            SELECT TOP (@limit)
                tak                         AS Tak,
                SUM(contract_count)         AS ContractCount,
                SUM(totaal_premie_eur)      AS TotaalPremieEur,
                SUM(totaal_betaald_eur)     AS TotaalBetaaldEur,
                CASE
                    WHEN SUM(totaal_premie_eur) = 0 THEN NULL
                    ELSE ROUND(SUM(totaal_betaald_eur) / SUM(totaal_premie_eur), 4)
                END                         AS LossRatio,
                0                           AS TotaalSchaden,
                0                           AS TotaalGereserveerdEur,
                ''                          AS Status
            FROM reporting.VW_PortfolioSummary
            WHERE tenant_id = @tenantId
            GROUP BY tak
            ORDER BY TotaalPremieEur DESC
            """;

        var rows = await repo.QueryAsync<PortfolioRow>(sql,
            new { tenantId, limit }, ct);
        return Results.Ok(rows);
    }
}
