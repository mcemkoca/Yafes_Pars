using System.Security.Claims;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class RenewalEndpoints
{
    public static IEndpointRouteBuilder MapRenewalEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/renewals")
            .WithTags("Renewals")
            .RequireAuthorization(AuthRoles.TenantUserPolicy)
            .RequireRateLimiting("tenant");

        api.MapGet  ("",         GetQueueAsync);
        api.MapPatch("/{id:guid}", ProcessAsync);
        api.MapGet  ("/metrics", GetMetricsAsync);

        return app;
    }

    /// <summary>GET /api/renewals?daysAhead=90&amp;status=PENDING</summary>
    private static async Task<IResult> GetQueueAsync(
        ClaimsPrincipal user,
        IReadRepository read,
        int daysAhead = 90,
        string? status = null,
        CancellationToken ct = default)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<dynamic>(
            "policy.SP_GetRenewalQueue",
            new
            {
                tenant_id   = tenantId,
                days_ahead  = Math.Clamp(daysAhead, 1, 365),
                status_code = string.IsNullOrWhiteSpace(status) ? null : status.ToUpperInvariant()
            }, ct);

        return Results.Ok(new { count = rows.Count, renewals = rows });
    }

    /// <summary>PATCH /api/renewals/{id}</summary>
    private static async Task<IResult> ProcessAsync(
        Guid id,
        ClaimsPrincipal user,
        ProcessRenewalRequest req,
        IReadRepository read,
        CancellationToken ct)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<dynamic>(
            "policy.SP_ProcessRenewal",
            new
            {
                tenant_id           = tenantId,
                renewal_id          = id,
                new_status          = req.NewStatus.ToUpperInvariant(),
                renewed_contract_id = req.RenewedContractId,
                notes               = req.Notes
            }, ct);

        var row = rows.FirstOrDefault();
        if (row is null) return Results.NotFound();
        return Results.Ok(row);
    }

    /// <summary>GET /api/renewals/metrics?year=2026</summary>
    private static async Task<IResult> GetMetricsAsync(
        ClaimsPrincipal user,
        IReadRepository read,
        int? year,
        CancellationToken ct)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<dynamic>(
            "policy.SP_GetRenewalMetrics",
            new { tenant_id = tenantId, year }, ct);

        return Results.Ok(rows.FirstOrDefault());
    }

    private sealed record ProcessRenewalRequest(
        string  NewStatus,
        Guid?   RenewedContractId = null,
        string? Notes             = null);
}
