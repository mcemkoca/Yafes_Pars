using System.Security.Claims;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class AuditEndpoints
{
    public static IEndpointRouteBuilder MapAuditEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/audit")
            .WithTags("Audit")
            .RequireAuthorization("Auditor")    // Auditor veya Admin rolü gerekli
            .RequireRateLimiting("tenant");

        api.MapGet("/logs",           QueryAuditLogAsync);
        api.MapGet("/history",        GetEntityHistoryAsync);
        api.MapGet("/gdpr/{personId:guid}", GetGdprReportAsync);
        api.MapGet("/deletions",      GetDeletionsAsync);

        return app;
    }

    /// <summary>GET /api/audit/logs?schemaName=policy&tableName=Contract&actionType=UPDATE&fromDate=2026-01-01</summary>
    private static async Task<IResult> QueryAuditLogAsync(
        ClaimsPrincipal user,
        string? schemaName,
        string? tableName,
        string? entityId,
        string? actionType,
        string? fromDate,
        string? toDate,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var limit    = Math.Clamp(take.GetValueOrDefault(100), 1, 1000);

        DateTime? fromUtc = fromDate is not null && DateTime.TryParse(fromDate, out var f) ? f : null;
        DateTime? toUtc   = toDate   is not null && DateTime.TryParse(toDate,   out var t) ? t.AddDays(1).AddSeconds(-1) : null;

        if (actionType is not null && actionType is not ("INSERT" or "UPDATE" or "DELETE"))
            return Results.BadRequest(new { error = "actionType moet INSERT, UPDATE of DELETE zijn." });

        var rows = await repository.QueryAsync<AuditLogRow>(
            "audit.SP_QueryAuditLog",
            new
            {
                tenant_id   = tenantId,
                schema_name = schemaName,
                table_name  = tableName,
                entity_id   = entityId,
                action_type = actionType,
                from_utc    = fromUtc,
                to_utc      = toUtc,
                limit,
            },
            cancellationToken);

        return Results.Ok(rows);
    }

    /// <summary>GET /api/audit/history?schemaName=policy&tableName=Contract&entityId=&lt;guid&gt;</summary>
    private static async Task<IResult> GetEntityHistoryAsync(
        ClaimsPrincipal user,
        string schemaName,
        string tableName,
        string entityId,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        if (string.IsNullOrWhiteSpace(schemaName) || string.IsNullOrWhiteSpace(tableName) || string.IsNullOrWhiteSpace(entityId))
            return Results.BadRequest(new { error = "schemaName, tableName en entityId zijn verplicht." });

        var rows = await repository.QueryAsync<EntityHistoryRow>(
            "audit.SP_GetEntityHistory",
            new
            {
                tenant_id   = tenantId,
                schema_name = schemaName,
                table_name  = tableName,
                entity_id   = entityId,
                limit       = Math.Clamp(take.GetValueOrDefault(50), 1, 500),
            },
            cancellationToken);

        return Results.Ok(rows);
    }

    /// <summary>GET /api/audit/gdpr/{personId} — GDPR Madde 15 veri erişim raporu</summary>
    private static async Task<IResult> GetGdprReportAsync(
        Guid personId,
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<GdprDataRow>(
            "audit.SP_GdprDataAccessReport",
            new { tenant_id = tenantId, person_id = personId },
            cancellationToken);

        if (!rows.Any())
            return Results.NotFound(new { error = "Kişi bulunamadı." });

        return Results.Ok(new
        {
            personId,
            generatedAt    = DateTime.UtcNow,
            gdprArticle    = "Article 15 GDPR — Recht van inzage",
            dataCategories = rows
                .GroupBy(r => r.DataCategory)
                .Select(g => new { category = g.Key, count = g.Count(), records = g }),
        });
    }

    /// <summary>GET /api/audit/deletions?fromDate=2026-01-01</summary>
    private static async Task<IResult> GetDeletionsAsync(
        ClaimsPrincipal user,
        string? fromDate,
        string? toDate,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        DateTime? fromUtc = fromDate is not null && DateTime.TryParse(fromDate, out var f) ? f : null;
        DateTime? toUtc   = toDate   is not null && DateTime.TryParse(toDate,   out var t) ? t.AddDays(1).AddSeconds(-1) : null;

        var rows = await repository.QueryAsync<AuditLogRow>(
            "audit.SP_QueryAuditLog",
            new
            {
                tenant_id   = tenantId,
                schema_name = (string?)null,
                table_name  = (string?)null,
                entity_id   = (string?)null,
                action_type = "DELETE",
                from_utc    = fromUtc,
                to_utc      = toUtc,
                limit       = Math.Clamp(take.GetValueOrDefault(100), 1, 1000),
            },
            cancellationToken);

        return Results.Ok(new { deletionCount = rows.Count(), records = rows });
    }

    private sealed record AuditLogRow(
        long     AuditLogId,
        string   SchemaName,
        string   TableName,
        string   EntityId,
        string   ActionType,
        DateTime ChangedAtUtc,
        string?  ChangedByName,
        string?  OldValuesJson,
        string?  NewValuesJson,
        string?  SourceSystem,
        Guid?    CorrelationId);

    private sealed record EntityHistoryRow(
        long     AuditLogId,
        string   ActionType,
        DateTime ChangedAtUtc,
        string?  ChangedByName,
        string   ColumnName,
        string?  OldValue,
        string?  NewValue);

    private sealed record GdprDataRow
    {
        public string  DataCategory { get; init; } = "";
        public string  Label        { get; init; } = "";
        public Guid?   EntityId     { get; init; }
        public string? Detail1      { get; init; }
        public string? Detail2      { get; init; }
        public string? CreatedAt    { get; init; }
        public string? UpdatedAt    { get; init; }
        public bool    IsAnonymised { get; init; }
    }
}
