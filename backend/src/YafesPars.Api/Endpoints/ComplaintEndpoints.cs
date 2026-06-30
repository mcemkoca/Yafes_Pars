using System.Security.Claims;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class ComplaintEndpoints
{
    public static IEndpointRouteBuilder MapComplaintEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/complaints")
            .WithTags("Complaints")
            .RequireAuthorization(AuthRoles.TenantUserPolicy)
            .RequireRateLimiting("tenant");

        api.MapPost   ("",                     RegisterComplaintAsync);
        api.MapPatch  ("/{id:guid}/status",    UpdateStatusAsync);
        api.MapGet    ("",                     GetComplaintsAsync);
        api.MapGet    ("/dashboard",           GetDashboardAsync);
        api.MapGet    ("/fsma-report",         GetFsmaReportAsync);

        return app;
    }

    /// <summary>POST /api/complaints</summary>
    private static async Task<IResult> RegisterComplaintAsync(
        ClaimsPrincipal user,
        RegisterComplaintRequest req,
        IReadRepository read,
        CancellationToken ct)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<ComplaintResultRow>(
            "communication.SP_RegisterComplaint",
            new
            {
                tenant_id       = tenantId,
                person_id       = req.PersonId,
                contract_id     = req.ContractId,
                claim_id        = req.ClaimId,
                channel_code    = req.Channel.ToUpperInvariant(),
                subject         = req.Subject,
                description     = req.Description,
                priority_code   = req.Priority.ToUpperInvariant(),
                fsma_reportable = req.FsmaReportable
            }, ct);

        var row = rows.FirstOrDefault();
        if (row is null) return Results.Problem("Şikayet kaydedilemedi.");

        return Results.Created($"/api/complaints/{row.ComplaintId}", row);
    }

    /// <summary>PATCH /api/complaints/{id}/status</summary>
    private static async Task<IResult> UpdateStatusAsync(
        Guid id,
        ClaimsPrincipal user,
        UpdateStatusRequest req,
        IReadRepository read,
        CancellationToken ct)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<ComplaintStatusRow>(
            "communication.SP_UpdateComplaintStatus",
            new
            {
                complaint_id     = id,
                tenant_id        = tenantId,
                new_status       = req.NewStatus.ToUpperInvariant(),
                resolution_notes = req.ResolutionNotes,
                assigned_user_id = req.AssignedUserId
            }, ct);

        var row = rows.FirstOrDefault();
        if (row is null) return Results.NotFound();
        return Results.Ok(row);
    }

    /// <summary>GET /api/complaints?status=OPEN&amp;limit=100</summary>
    private static async Task<IResult> GetComplaintsAsync(
        ClaimsPrincipal user,
        IReadRepository read,
        string? status,
        int limit = 100,
        CancellationToken ct = default)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<dynamic>(
            "communication.SP_GetComplaintsByTenant",
            new
            {
                tenant_id   = tenantId,
                status_code = string.IsNullOrWhiteSpace(status) ? null : status.ToUpperInvariant(),
                top_n       = Math.Clamp(limit, 1, 500)
            }, ct);

        return Results.Ok(new { count = rows.Count, complaints = rows });
    }

    /// <summary>GET /api/complaints/dashboard</summary>
    private static async Task<IResult> GetDashboardAsync(
        ClaimsPrincipal user,
        IReadRepository read,
        CancellationToken ct)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<dynamic>(
            "communication.SP_GetComplaintDashboard",
            new { tenant_id = tenantId }, ct);

        return Results.Ok(rows.FirstOrDefault());
    }

    /// <summary>GET /api/complaints/fsma-report?year=2026</summary>
    private static async Task<IResult> GetFsmaReportAsync(
        ClaimsPrincipal user,
        IReadRepository read,
        int? year,
        CancellationToken ct)
    {
        if (!TenantClaims.TryGetTenantId(user, out var tenantId))
            return Results.Unauthorized();

        var rows = await read.QueryAsync<dynamic>(
            "reporting.SP_FsmaComplaintReport",
            new { tenant_id = tenantId, year }, ct);

        return Results.Ok(new { reportYear = year ?? DateTime.UtcNow.Year, count = rows.Count, complaints = rows });
    }

    // DTO'lar
    private sealed record RegisterComplaintRequest(
        Guid    PersonId,
        string  Subject,
        string  Description,
        string  Channel       = "EMAIL",
        string  Priority      = "NORMAL",
        Guid?   ContractId    = null,
        Guid?   ClaimId       = null,
        bool    FsmaReportable = false);

    private sealed record UpdateStatusRequest(
        string  NewStatus,
        string? ResolutionNotes = null,
        Guid?   AssignedUserId  = null);

    private sealed record ComplaintResultRow(
        Guid     ComplaintId,
        string   StatusCode,
        DateOnly ReceivedDate,
        bool     FsmaReportable);

    private sealed record ComplaintStatusRow(
        Guid      ComplaintId,
        string    StatusCode,
        DateOnly? ResolvedDate,
        bool      FsmaReportable,
        DateTime  UpdatedAtUtc);
}
