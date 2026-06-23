using System.Security.Claims;
using YafesPars.Application.Abstractions;
using YafesPars.Application.ReadModels;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class DomainReadEndpoints
{
    public static IEndpointRouteBuilder MapDomainReadEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api")
            .WithTags("Domain reads")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("tenant");

        api.MapGet("/tenants", QueryTenantsAsync);
        api.MapGet("/persons", QueryPersonsAsync);
        api.MapGet("/institutions", QueryInstitutionsAsync);
        api.MapGet("/risks", QueryRisksAsync);
        api.MapGet("/policies", QueryPoliciesAsync);
        api.MapGet("/claims", QueryClaimsAsync);
        api.MapGet("/documents", QueryDocumentsAsync);
        api.MapGet("/tasks", QueryTasksAsync);
        api.MapGet("/coverage", QueryCoverageAsync);
        api.MapGet("/settings/lookups", QueryLookupHealthAsync);

        return app;
    }

    private static int NormalizeTake(int? take)
    {
        return Math.Clamp(take.GetValueOrDefault(50), 1, 200);
    }

    private static async Task<IResult> QueryTenantsAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        int? take,
        CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT TOP (@Take)
                tenant_id AS TenantId,
                tenant_code AS TenantCode,
                display_name AS DisplayName,
                legal_name AS LegalName,
                is_active AS IsActive
            FROM core.Tenant
            WHERE tenant_id = @TenantId
            ORDER BY tenant_code;
            """;

        var rows = await repository.QueryAsync<TenantRow>(
            sql,
            new { TenantId = TenantClaims.GetRequiredTenantId(user), Take = NormalizeTake(take) },
            cancellationToken);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryPersonsAsync(
        ClaimsPrincipal user,
        string? search,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<CustomerSummary>(
            """
            SELECT TOP (@Take) *
            FROM person.VW_CustomerSummary
            WHERE tenant_id = @TenantId
              AND (
                    @Search IS NULL
                 OR dossier LIKE @SearchPattern
                 OR first_name LIKE @SearchPattern
                 OR last_name LIKE @SearchPattern
                 OR primary_email LIKE @SearchPattern
              )
            ORDER BY updated_at_utc DESC;
            """,
            Params(user, search, take),
            cancellationToken);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryInstitutionsAsync(
        ClaimsPrincipal user,
        string? search,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<InstitutionSummary>(
            """
            SELECT TOP (@Take) *
            FROM institution.VW_InstitutionSummary
            WHERE tenant_id = @TenantId
              AND (@Search IS NULL OR institution_code LIKE @SearchPattern OR name LIKE @SearchPattern)
            ORDER BY name;
            """,
            Params(user, search, take),
            cancellationToken);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryRisksAsync(
        ClaimsPrincipal user,
        string? search,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<RiskSummary>(
            """
            SELECT TOP (@Take) *
            FROM risk.VW_InsurableObjectSummary
            WHERE tenant_id = @TenantId
              AND (@Search IS NULL OR description LIKE @SearchPattern OR license_plate LIKE @SearchPattern OR chassis_number LIKE @SearchPattern)
            ORDER BY updated_at_utc DESC;
            """,
            Params(user, search, take),
            cancellationToken);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryPoliciesAsync(
        ClaimsPrincipal user,
        string? search,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<PolicySummary>(
            """
            SELECT TOP (@Take) *
            FROM policy.VW_PolicyDashboard
            WHERE tenant_id = @TenantId
              AND (@Search IS NULL OR contract_number LIKE @SearchPattern OR company_name LIKE @SearchPattern)
            ORDER BY contract_number DESC;
            """,
            Params(user, search, take),
            cancellationToken);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryClaimsAsync(
        ClaimsPrincipal user,
        string? search,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<ClaimSummary>(
            """
            SELECT TOP (@Take) *
            FROM claim.VW_ClaimDashboard
            WHERE tenant_id = @TenantId
              AND (@Search IS NULL OR claim_number LIKE @SearchPattern OR contract_number LIKE @SearchPattern)
            ORDER BY reported_date DESC;
            """,
            Params(user, search, take),
            cancellationToken);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryDocumentsAsync(
        ClaimsPrincipal user,
        string? ownerEntityType,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<DocumentRow>(
            """
            SELECT TOP (@Take)
                document_id AS DocumentId,
                tenant_id AS TenantId,
                owner_entity_type AS OwnerEntityType,
                owner_entity_id AS OwnerEntityId,
                document_type_code AS DocumentTypeCode,
                file_name AS FileName,
                mime_type AS MimeType,
                file_size_bytes AS FileSizeBytes,
                uploaded_at_utc AS UploadedAtUtc
            FROM document.Document
            WHERE tenant_id = @TenantId
              AND is_deleted = 0
              AND (@OwnerEntityType IS NULL OR owner_entity_type = @OwnerEntityType)
            ORDER BY uploaded_at_utc DESC;
            """,
            new
            {
                TenantId = TenantClaims.GetRequiredTenantId(user),
                OwnerEntityType = ownerEntityType,
                Take = NormalizeTake(take)
            },
            cancellationToken);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryTasksAsync(
        ClaimsPrincipal user,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<TaskSummary>(
            """
            SELECT TOP (@Take) *
            FROM tasking.VW_OpenTaskDashboard
            WHERE tenant_id = @TenantId
            ORDER BY due_at_utc, created_at_utc DESC;
            """,
            new { TenantId = TenantClaims.GetRequiredTenantId(user), Take = NormalizeTake(take) },
            cancellationToken);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryCoverageAsync(
        string? domain,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<CoverageSummary>(
            """
            SELECT DISTINCT
                c.coverage_code,
                c.label_nl,
                c.label_fr,
                c.label_en,
                c.label_tr,
                c.description
            FROM coverage.Coverage c
            LEFT JOIN coverage.CoverageDomain cd
                ON cd.coverage_code = c.coverage_code
            WHERE c.is_active = 1
              AND (@Domain IS NULL OR cd.contract_domain_code = @Domain)
            ORDER BY c.coverage_code;
            """,
            new { Domain = domain },
            cancellationToken);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryLookupHealthAsync(
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<LookupHealthRow>(
            """
            SELECT 'coverage.Coverage' AS LookupName, COUNT_BIG(*) AS RowCount FROM coverage.Coverage
            UNION ALL SELECT 'risk.VehicleType', COUNT_BIG(*) FROM risk.VehicleType
            UNION ALL SELECT 'risk.RealEstateType', COUNT_BIG(*) FROM risk.RealEstateType
            UNION ALL SELECT 'tasking.TaskStatus', COUNT_BIG(*) FROM tasking.TaskStatus
            UNION ALL SELECT 'claim.ClaimStatus', COUNT_BIG(*) FROM claim.ClaimStatus;
            """,
            cancellationToken: cancellationToken);
        return Results.Ok(rows);
    }

    private static object Params(ClaimsPrincipal user, string? search, int? take)
    {
        return new
        {
            TenantId = TenantClaims.GetRequiredTenantId(user),
            Search = string.IsNullOrWhiteSpace(search) ? null : search,
            SearchPattern = string.IsNullOrWhiteSpace(search) ? null : $"%{search.Trim()}%",
            Take = NormalizeTake(take)
        };
    }

    private sealed class TenantRow
    {
        public Guid TenantId { get; init; }
        public string TenantCode { get; init; } = "";
        public string DisplayName { get; init; } = "";
        public string LegalName { get; init; } = "";
        public bool IsActive { get; init; }
    }

    private sealed class DocumentRow
    {
        public Guid DocumentId { get; init; }
        public Guid TenantId { get; init; }
        public string OwnerEntityType { get; init; } = "";
        public Guid OwnerEntityId { get; init; }
        public string DocumentTypeCode { get; init; } = "";
        public string FileName { get; init; } = "";
        public string MimeType { get; init; } = "";
        public long FileSizeBytes { get; init; }
        public DateTime UploadedAtUtc { get; init; }
    }

    private sealed class LookupHealthRow
    {
        public string LookupName { get; init; } = "";
        public long RowCount { get; init; }
    }
}
