using System.Security.Claims;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class MonitoringEndpoints
{
    public static IEndpointRouteBuilder MapMonitoringEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/monitoring")
            .WithTags("Monitoring")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("tenant");

        api.MapGet("/dashboard",      GetDashboardAsync);
        api.MapGet("/health-score",   GetHealthScoreAsync);
        api.MapGet("/recent-activity", GetRecentActivityAsync);

        return app;
    }

    /// <summary>GET /api/monitoring/dashboard?daysBack=30</summary>
    private static async Task<IResult> GetDashboardAsync(
        ClaimsPrincipal user,
        int? daysBack,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var days     = Math.Clamp(daysBack.GetValueOrDefault(30), 1, 365);

        var rows = await repository.QueryAsync<DashboardMetricRow>(
            "reporting.SP_OperationalDashboard",
            new { tenant_id = tenantId, days_back = days },
            cancellationToken);

        return Results.Ok(new
        {
            tenantId,
            daysBack = days,
            asOfUtc  = DateTime.UtcNow,
            metrics  = rows.GroupBy(r => r.MetricCategory)
                .Select(g => new
                {
                    category = g.Key,
                    items    = g.Select(r => new
                    {
                        dimension = r.Dimension,
                        count     = r.MetricValue,
                        amount    = r.MetricAmount,
                        asOfDate  = r.AsOfDate,
                    }),
                }),
        });
    }

    /// <summary>GET /api/monitoring/health-score</summary>
    private static async Task<IResult> GetHealthScoreAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<HealthScoreRow>(
            "reporting.SP_TenantHealthScore",
            new { tenant_id = tenantId },
            cancellationToken);

        var row = rows.FirstOrDefault();
        if (row is null)
            return Results.Problem("Sağlık skoru hesaplanamadı.", statusCode: 500);

        return Results.Ok(row);
    }

    /// <summary>GET /api/monitoring/recent-activity?hoursBack=24</summary>
    private static async Task<IResult> GetRecentActivityAsync(
        ClaimsPrincipal user,
        int? hoursBack,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var hours    = Math.Clamp(hoursBack.GetValueOrDefault(24), 1, 168);

        var rows = await repository.QueryAsync<ActivityRow>(
            "reporting.SP_RecentActivity",
            new { tenant_id = tenantId, hours_back = hours },
            cancellationToken);

        return Results.Ok(new
        {
            tenantId,
            hoursBack = hours,
            asOfUtc   = DateTime.UtcNow,
            totalEvents = rows.Sum(r => r.EventCount),
            activity  = rows,
        });
    }

    private sealed record DashboardMetricRow(
        string   MetricCategory,
        string   Dimension,
        int      MetricValue,
        decimal? MetricAmount,
        DateOnly AsOfDate);

    private sealed record HealthScoreRow(
        int      HealthScore,
        int      ActiveContracts,
        int      OpenClaims,
        int      OverdueInvoices,
        int      ExpiringSoon,
        decimal  OverdueRatePct,
        decimal  ClaimRatePct,
        DateOnly AsOfDate,
        string   Status);

    private sealed record ActivityRow(
        string   SchemaName,
        string   TableName,
        string   ActionType,
        int      EventCount,
        DateTime LastEventUtc);
}
