using System.Security.Claims;
using Microsoft.Data.SqlClient;
using YafesPars.Api.Security;
using YafesPars.Application.Abstractions;
using YafesPars.Application.ReadModels;

namespace YafesPars.Api.Endpoints;

public static class ImportEndpoints
{
    public static IEndpointRouteBuilder MapImportEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/import")
            .WithTags("Import")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("write");

        api.MapPost("/policies/stage", StagePoliciesAsync);
        api.MapPost("/policies/{batchId:guid}/validate", ValidateBatchAsync);
        api.MapGet("/policies/{batchId:guid}/status", GetBatchStatusAsync)
            .RequireRateLimiting("tenant");

        return app;
    }

    private static async Task<IResult> StagePoliciesAsync(
        StagePoliciesRequest req,
        ClaimsPrincipal user,
        IWriteRepository repo,
        CancellationToken ct)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        if (req.Rows is null || req.Rows.Count == 0)
            return Results.BadRequest(new { error = "Geen rijen opgegeven." });
        if (req.Rows.Count > 500)
            return Results.BadRequest(new { error = "Maximaal 500 rijen per batch." });

        var batchId = Guid.NewGuid();
        int rowNum = 0;

        foreach (var row in req.Rows)
        {
            rowNum++;
            try
            {
                await repo.ExecuteAsync(
                    """
                    INSERT INTO import.PolicyImport (
                        batch_id, tenant_id, row_number,
                        contract_number, contract_domain_code, contract_type_code,
                        start_date, end_date,
                        policyholder_rrn, policyholder_name,
                        gross_premium, currency_code
                    ) VALUES (
                        @batchId, @tenantId, @rowNum,
                        @contractNumber, @contractDomainCode, @contractTypeCode,
                        @startDate, @endDate,
                        @policyholderRrn, @policyholderName,
                        @grossPremium, @currencyCode
                    );
                    """,
                    new
                    {
                        batchId, tenantId, rowNum,
                        contractNumber = row.ContractNumber,
                        contractDomainCode = row.ContractDomainCode,
                        contractTypeCode = row.ContractTypeCode,
                        startDate = row.StartDate,
                        endDate = row.EndDate,
                        policyholderRrn = row.PolicyholderRrn,
                        policyholderName = row.PolicyholderName,
                        grossPremium = row.GrossPremium,
                        currencyCode = row.CurrencyCode
                    },
                    ct);
            }
            catch (SqlException ex)
            {
                return Results.Problem($"Databasefout rij {rowNum}: {ex.Message}");
            }
        }

        return Results.Created($"/api/import/policies/{batchId}/status",
            new { batchId, stagedRows = rowNum });
    }

    private static async Task<IResult> ValidateBatchAsync(
        Guid batchId,
        ClaimsPrincipal user,
        IWriteRepository repo,
        CancellationToken ct)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        try
        {
            var result = await repo.ExecuteScalarAsync<string>(
                """
                DECLARE @valid INT, @invalid INT;
                EXEC import.SP_ValidateImportBatch
                    @tenant_id     = @tenantId,
                    @batch_id      = @batchId,
                    @valid_count   = @valid   OUTPUT,
                    @invalid_count = @invalid OUTPUT;
                SELECT CAST(@valid AS NVARCHAR) + '|' + CAST(@invalid AS NVARCHAR);
                """,
                new { tenantId, batchId }, ct);

            var parts = (result ?? "0|0").Split('|');
            int valid = int.TryParse(parts[0], out var v) ? v : 0;
            int invalid = int.TryParse(parts.Length > 1 ? parts[1] : "0", out var i) ? i : 0;

            return Results.Ok(new { batchId, validRows = valid, invalidRows = invalid, ready = invalid == 0 });
        }
        catch (SqlException ex)
        {
            return Results.Problem(ex.Message);
        }
    }

    private static async Task<IResult> GetBatchStatusAsync(
        Guid batchId,
        ClaimsPrincipal user,
        string? statusFilter,
        IReadRepository repo,
        CancellationToken ct)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var sql = $"""
            SELECT
                row_number           AS RowNumber,
                contract_number      AS ContractNumber,
                contract_domain_code AS ContractDomainCode,
                start_date           AS StartDate,
                validation_status    AS ValidationStatus,
                validation_errors    AS ValidationErrors
            FROM import.PolicyImport
            WHERE batch_id  = @batchId
              AND tenant_id = @tenantId
              {(statusFilter is not null ? "AND validation_status = @statusFilter" : "")}
            ORDER BY row_number
            """;

        var rows = await repo.QueryAsync<ImportBatchRow>(sql,
            new { batchId, tenantId, statusFilter }, ct);

        return rows.Count == 0
            ? Results.NotFound(new { error = $"Batch {batchId} niet gevonden." })
            : Results.Ok(new { batchId, count = rows.Count, rows });
    }

    private sealed record PolicyImportRow(
        string? ContractNumber,
        string? ContractDomainCode,
        string? ContractTypeCode,
        string? StartDate,
        string? EndDate,
        string? PolicyholderRrn,
        string? PolicyholderName,
        string? GrossPremium,
        string? CurrencyCode);

    private sealed record StagePoliciesRequest(List<PolicyImportRow>? Rows);
}
