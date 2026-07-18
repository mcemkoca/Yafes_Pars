using System.Security.Claims;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class AssuranceEndpoints
{
    public static IEndpointRouteBuilder MapAssuranceEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/assurance")
            .WithTags("Assurance")
            .RequireAuthorization(AuthRoles.AuditorPolicy)
            .RequireRateLimiting("tenant");

        api.MapGet("/dashboard", GetDashboardAsync);
        api.MapGet("/sql-reviews", GetSqlReviewsAsync);
        api.MapGet("/sql-risk-findings", GetSqlRiskFindingsAsync);
        api.MapGet("/compliance-findings", GetComplianceFindingsAsync);
        api.MapGet("/permission-drift", GetPermissionDriftAsync);

        api.MapPost("/sql-review", CreateSqlReviewAsync)
            .RequireAuthorization(AuthRoles.AdminPolicy)
            .RequireRateLimiting("write");

        api.MapPost("/sensitive-column-scan", RunSensitiveColumnScanAsync)
            .RequireAuthorization(AuthRoles.AdminPolicy)
            .RequireRateLimiting("write");

        api.MapPost("/compliance-scan", RunComplianceScanAsync)
            .RequireAuthorization(AuthRoles.AdminPolicy)
            .RequireRateLimiting("write");

        api.MapPost("/permission-drift-scan", RunPermissionDriftScanAsync)
            .RequireAuthorization(AuthRoles.AdminPolicy)
            .RequireRateLimiting("write");

        return app;
    }

    private static async Task<IResult> GetDashboardAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<AssuranceMetricRow>(
            "assurance.SP_GetAssuranceDashboard",
            new { tenant_id = tenantId },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static async Task<IResult> GetSqlReviewsAsync(
        ClaimsPrincipal user,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<SqlReviewRequestRow>(
            "assurance.SP_GetSqlReviewRequests",
            new
            {
                tenant_id = tenantId,
                limit = Math.Clamp(take.GetValueOrDefault(100), 1, 1000)
            },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static async Task<IResult> CreateSqlReviewAsync(
        ClaimsPrincipal user,
        SqlReviewCreateRequest request,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var submittedBy = TryGetUserId(user);

        if (string.IsNullOrWhiteSpace(request.SubmittedSql))
            return Results.BadRequest(new { error = "submittedSql is required." });

        var rows = await repository.QueryAsync<SqlReviewCreatedRow>(
            "assurance.SP_CreateSqlReviewRequest",
            new
            {
                tenant_id = tenantId,
                environment_code = string.IsNullOrWhiteSpace(request.EnvironmentCode) ? "DEV" : request.EnvironmentCode.Trim().ToUpperInvariant(),
                target_database = string.IsNullOrWhiteSpace(request.TargetDatabase) ? "YafesPars" : request.TargetDatabase.Trim(),
                script_name = request.ScriptName,
                submitted_sql = request.SubmittedSql,
                rollback_sql = request.RollbackSql,
                submitted_by_user_id = submittedBy
            },
            cancellationToken);

        return Results.Ok(rows.FirstOrDefault());
    }

    private static async Task<IResult> GetSqlRiskFindingsAsync(
        ClaimsPrincipal user,
        Guid? sqlReviewRequestId,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<SqlRiskFindingRow>(
            "assurance.SP_GetSqlRiskFindings",
            new { tenant_id = tenantId, sql_review_request_id = sqlReviewRequestId },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static async Task<IResult> RunSensitiveColumnScanAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<SensitiveColumnFindingRow>(
            "assurance.SP_RunSensitiveColumnScan",
            new { tenant_id = tenantId },
            cancellationToken);

        return Results.Ok(new
        {
            generatedAtUtc = DateTime.UtcNow,
            findingCount = rows.Count,
            findings = rows
        });
    }

    private static async Task<IResult> RunComplianceScanAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<ComplianceScanRunRow>(
            "assurance.SP_RunComplianceScan",
            new { tenant_id = tenantId },
            cancellationToken);

        return Results.Ok(rows.FirstOrDefault());
    }

    private static async Task<IResult> GetComplianceFindingsAsync(
        ClaimsPrincipal user,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<ComplianceFindingRow>(
            "assurance.SP_GetComplianceFindings",
            new
            {
                tenant_id = tenantId,
                limit = Math.Clamp(take.GetValueOrDefault(200), 1, 1000)
            },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static async Task<IResult> RunPermissionDriftScanAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<PermissionDriftFindingRow>(
            "assurance.SP_RunPermissionDriftScan",
            new { tenant_id = tenantId },
            cancellationToken);

        return Results.Ok(new
        {
            generatedAtUtc = DateTime.UtcNow,
            findingCount = rows.Count,
            findings = rows
        });
    }

    private static async Task<IResult> GetPermissionDriftAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<PermissionDriftFindingRow>(
            "assurance.SP_GetPermissionDriftFindings",
            new { tenant_id = tenantId },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static Guid? TryGetUserId(ClaimsPrincipal user)
    {
        var value = user.FindFirstValue("sub")
            ?? user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? user.FindFirstValue("user_id");

        return Guid.TryParse(value, out var id) ? id : null;
    }

    public sealed record SqlReviewCreateRequest(
        string EnvironmentCode,
        string TargetDatabase,
        string? ScriptName,
        string SubmittedSql,
        string? RollbackSql);

    private sealed record AssuranceMetricRow(string MetricCode, long MetricValue);

    private sealed record SqlReviewCreatedRow(
        Guid SqlReviewRequestId,
        Guid TenantId,
        string EnvironmentCode,
        string TargetDatabase,
        string? ScriptName,
        int RiskScore,
        string RiskLevel,
        string StatusCode,
        DateTime CreatedAtUtc);

    private sealed record SqlReviewRequestRow(
        Guid SqlReviewRequestId,
        string EnvironmentCode,
        string TargetDatabase,
        string? ScriptName,
        int RiskScore,
        string RiskLevel,
        string StatusCode,
        Guid? SubmittedByUserId,
        DateTime CreatedAtUtc,
        DateTime? ApprovedAtUtc,
        DateTime? ExecutedAtUtc);

    private sealed record SqlRiskFindingRow(
        Guid SqlRiskFindingId,
        Guid SqlReviewRequestId,
        string RuleCode,
        string SeverityCode,
        string CategoryCode,
        string FindingMessage,
        string? Evidence,
        int? LineNumber,
        DateTime CreatedAtUtc);

    private sealed record SensitiveColumnFindingRow(
        Guid SensitiveColumnFindingId,
        string SchemaName,
        string TableName,
        string ColumnName,
        string DetectedPattern,
        string DataCategoryCode,
        decimal ConfidenceScore,
        bool MaskingRecommended,
        bool IsAcknowledged,
        DateTime CreatedAtUtc);

    private sealed record ComplianceScanRunRow(
        Guid ComplianceScanRunId,
        Guid TenantId,
        string ScanScopeCode,
        string StatusCode,
        DateTime StartedAtUtc,
        DateTime? CompletedAtUtc,
        string? SummaryJson);

    private sealed record ComplianceFindingRow(
        Guid ComplianceFindingId,
        Guid ComplianceScanRunId,
        string FrameworkCode,
        string ControlCode,
        string FindingStatusCode,
        string SeverityCode,
        string FindingTitle,
        string? FindingDetail,
        string? RemediationHint,
        DateTime CreatedAtUtc);

    private sealed record PermissionDriftFindingRow(
        Guid PermissionDriftFindingId,
        string FindingTypeCode,
        string SeverityCode,
        string? PrincipalName,
        string? RoleCode,
        string FindingDetail,
        string? RemediationHint,
        bool IsResolved,
        DateTime CreatedAtUtc,
        DateTime? ResolvedAtUtc);
}
