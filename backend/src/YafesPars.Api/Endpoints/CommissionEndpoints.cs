using System.Security.Claims;
using Microsoft.Data.SqlClient;
using YafesPars.Api.Security;
using YafesPars.Application.Abstractions;
using YafesPars.Application.ReadModels;

namespace YafesPars.Api.Endpoints;

public static class CommissionEndpoints
{
    public static IEndpointRouteBuilder MapCommissionEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/commissions")
            .WithTags("Commissions")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("tenant");

        api.MapGet("/", QueryCommissionsAsync);
        api.MapGet("/report", QueryCommissionReportAsync);
        api.MapPost("/", CreateCommissionAsync).RequireRateLimiting("write");

        return app;
    }

    private static async Task<IResult> QueryCommissionsAsync(
        ClaimsPrincipal user,
        Guid? contractId,
        string? statusCode,
        int? take,
        IReadRepository repo,
        CancellationToken ct)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var limit = Math.Clamp(take.GetValueOrDefault(50), 1, 200);

        var sql = $"""
            SELECT TOP (@limit)
                commission_id   AS CommissionId,
                commission_date AS CommissionDate,
                commission_type_code AS CommissionTypeCode,
                status_code     AS StatusCode,
                contract_id     AS ContractId,
                broker_person_id AS BrokerPersonId,
                broker_institution_id AS BrokerInstitutionId,
                gross_premium_eur AS GrossPremiumEur,
                rate_pct        AS RatePct,
                commission_eur  AS CommissionEur,
                paid_date       AS PaidDate,
                notes           AS Notes
            FROM finance.Commissions
            WHERE tenant_id  = @tenantId
              AND is_deleted = 0
              {(contractId.HasValue ? "AND contract_id = @contractId" : "")}
              {(statusCode is not null ? "AND status_code = @statusCode" : "")}
            ORDER BY commission_date DESC
            """;

        var rows = await repo.QueryAsync<CommissionRow>(sql,
            new { tenantId, contractId, statusCode, limit }, ct);
        return Results.Ok(rows);
    }

    private static async Task<IResult> QueryCommissionReportAsync(
        ClaimsPrincipal user,
        DateOnly? fromDate,
        DateOnly? toDate,
        int? take,
        IReadRepository repo,
        CancellationToken ct)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var limit = Math.Clamp(take.GetValueOrDefault(100), 1, 500);

        var sql = $"""
            SELECT TOP (@limit)
                commission_date AS CommissionDate,
                commission_type_code AS CommissionTypeCode,
                status_code     AS StatusCode,
                contract_number AS ContractNumber,
                tak             AS Tak,
                productcode     AS Productcode,
                broker_naam     AS BrokerNaam,
                broker_kantoor  AS BrokerKantoor,
                gross_premium_eur AS GrossPremiumEur,
                rate_pct        AS RatePct,
                commission_eur  AS CommissionEur,
                paid_date       AS PaidDate
            FROM reporting.VW_CommissionReport
            WHERE tenant_id = @tenantId
              {(fromDate.HasValue ? "AND commission_date >= @fromDate" : "")}
              {(toDate.HasValue ? "AND commission_date <= @toDate" : "")}
            ORDER BY commission_date DESC
            """;

        var rows = await repo.QueryAsync<CommissionReportRow>(sql,
            new { tenantId, fromDate, toDate, limit }, ct);
        return Results.Ok(rows);
    }

    private static async Task<IResult> CreateCommissionAsync(
        CreateCommissionRequest req,
        ClaimsPrincipal user,
        IWriteRepository repo,
        CancellationToken ct)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        try
        {
            var id = await repo.ExecuteScalarAsync<Guid>(
                """
                DECLARE @id UNIQUEIDENTIFIER;
                EXEC finance.SP_RecordCommission
                    @tenant_id             = @tenantId,
                    @contract_id           = @contractId,
                    @commission_type_code  = @commissionTypeCode,
                    @commission_date       = @commissionDate,
                    @gross_premium_eur     = @grossPremiumEur,
                    @rate_pct              = @ratePct,
                    @broker_person_id      = @brokerPersonId,
                    @broker_institution_id = @brokerInstitutionId,
                    @notes                 = @notes,
                    @commission_id         = @id OUTPUT;
                SELECT @id;
                """,
                new
                {
                    tenantId,
                    contractId = req.ContractId,
                    commissionTypeCode = req.CommissionTypeCode,
                    commissionDate = req.CommissionDate,
                    grossPremiumEur = req.GrossPremiumEur,
                    ratePct = req.RatePct,
                    brokerPersonId = req.BrokerPersonId,
                    brokerInstitutionId = req.BrokerInstitutionId,
                    notes = req.Notes
                },
                ct);
            return Results.Created($"/api/commissions/{id}", new { commissionId = id });
        }
        catch (SqlException ex) when (ex.Number is 51960 or 51961)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
    }

    private sealed record CreateCommissionRequest(
        Guid ContractId,
        DateOnly CommissionDate,
        decimal GrossPremiumEur,
        decimal RatePct,
        string CommissionTypeCode = "PRODUCTIE",
        Guid? BrokerPersonId = null,
        Guid? BrokerInstitutionId = null,
        string? Notes = null);
}
