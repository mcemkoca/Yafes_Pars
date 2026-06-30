using System.Security.Claims;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class PremiumEndpoints
{
    public static IEndpointRouteBuilder MapPremiumEndpoints(this IEndpointRouteBuilder app)
    {
        var read = app.MapGroup("/api/premium")
            .WithTags("Premium")
            .RequireAuthorization(AuthRoles.TenantUserPolicy)
            .RequireRateLimiting("tenant");

        read.MapGet("/calculate/{contractId:guid}", CalculateAsync);
        read.MapGet("/summary/{contractId:guid}",   SummaryAsync);
        read.MapGet("/tariffs",                      GetTariffsAsync);
        read.MapPut("/tariffs",                      UpsertTariffAsync)
            .RequireAuthorization(AuthRoles.AdminPolicy);

        return app;
    }

    /// <summary>GET /api/premium/calculate/{contractId}?referenceDate=2026-01-01</summary>
    private static async Task<IResult> CalculateAsync(
        Guid contractId,
        ClaimsPrincipal user,
        IReadRepository read,
        string? referenceDate,
        CancellationToken ct)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<dynamic>(
            "finance.SP_CalculatePremium",
            new
            {
                tenant_id      = tenantId,
                contract_id    = contractId,
                reference_date = string.IsNullOrWhiteSpace(referenceDate) ? (DateTime?)null
                                 : DateTime.Parse(referenceDate)
            }, ct);

        var total = 0m;
        foreach (var r in rows)
        {
            decimal cp = r.CalculatedPremium ?? 0m;
            total += cp;
        }

        return Results.Ok(new
        {
            contractId,
            coverageCount  = rows.Count,
            totalAnnualEur = Math.Round(total, 2),
            monthlyEur     = Math.Round(total / 12, 2),
            items          = rows
        });
    }

    /// <summary>GET /api/premium/summary/{contractId}</summary>
    private static async Task<IResult> SummaryAsync(
        Guid contractId,
        ClaimsPrincipal user,
        IReadRepository read,
        CancellationToken ct)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<dynamic>(
            "finance.SP_GetPremiumSummary",
            new { tenant_id = tenantId, contract_id = contractId }, ct);

        var row = rows.FirstOrDefault();
        if (row is null) return Results.NotFound();
        return Results.Ok(row);
    }

    /// <summary>GET /api/premium/tariffs?coverageDomainCode=AUTO</summary>
    private static async Task<IResult> GetTariffsAsync(
        ClaimsPrincipal user,
        IReadRepository read,
        string? coverageDomainCode,
        bool includeInactive = false,
        CancellationToken ct = default)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<dynamic>(
            "finance.SP_GetTariffRates",
            new
            {
                tenant_id            = tenantId,
                coverage_domain_code = string.IsNullOrWhiteSpace(coverageDomainCode) ? null : coverageDomainCode,
                include_inactive     = includeInactive
            }, ct);

        return Results.Ok(new { count = rows.Count, tariffs = rows });
    }

    /// <summary>PUT /api/premium/tariffs (Admin only)</summary>
    private static async Task<IResult> UpsertTariffAsync(
        ClaimsPrincipal user,
        UpsertTariffRequest req,
        IReadRepository read,
        CancellationToken ct)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<dynamic>(
            "finance.SP_UpsertTariffRate",
            new
            {
                tenant_id            = tenantId,
                coverage_domain_code = req.CoverageDomainCode.ToUpperInvariant(),
                coverage_type_code   = req.CoverageTypeCode ?? "*",
                base_rate_pct        = req.BaseRatePct,
                min_premium_eur      = req.MinPremiumEur,
                max_premium_eur      = req.MaxPremiumEur,
                age_factor_young     = req.AgeFactorYoung,
                age_factor_senior    = req.AgeFactorSenior,
                no_claim_discount    = req.NoClaimDiscount,
                effective_from       = req.EffectiveFrom.HasValue ? (DateTime?)req.EffectiveFrom.Value.ToDateTime(TimeOnly.MinValue) : null
            }, ct);

        var row = rows.FirstOrDefault();
        if (row is null) return Results.Problem("Tarife kaydedilemedi.");
        return Results.Ok(row);
    }

    private sealed record UpsertTariffRequest(
        string   CoverageDomainCode,
        decimal  BaseRatePct,
        string?  CoverageTypeCode  = "*",
        decimal  MinPremiumEur     = 0,
        decimal? MaxPremiumEur     = null,
        decimal  AgeFactorYoung    = 1.0m,
        decimal  AgeFactorSenior   = 1.0m,
        decimal  NoClaimDiscount   = 0.0m,
        DateOnly? EffectiveFrom    = null);
}
