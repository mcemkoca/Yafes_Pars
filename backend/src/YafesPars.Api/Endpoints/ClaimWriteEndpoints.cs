using System.Security.Claims;
using Microsoft.Data.SqlClient;
using YafesPars.Api.Security;
using YafesPars.Application.Abstractions;
using YafesPars.Application.Commands;

namespace YafesPars.Api.Endpoints;

public static class ClaimWriteEndpoints
{
    public static IEndpointRouteBuilder MapClaimWriteEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/claims")
            .WithTags("Claims")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("write");

        api.MapPost("/", CreateClaimAsync)
            .WithSummary("Yeni hasar kaydı oluştur");

        api.MapPost("/{claimId:guid}/close", CloseClaimAsync)
            .WithSummary("Hasarı kapat");

        return app;
    }

    private static async Task<IResult> CreateClaimAsync(
        CreateClaimCommand cmd,
        ClaimsPrincipal user,
        IWriteRepository repository,
        CancellationToken cancellationToken)
    {
        if (cmd.IncidentDate > cmd.ReportedDate)
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["incidentDate"] = ["IncidentDate, ReportedDate'den büyük olamaz."]
            });

        if (cmd.ReservedAmount is < 0)
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["reservedAmount"] = ["ReservedAmount negatif olamaz."]
            });

        var tenantId = TenantClaims.GetRequiredTenantId(user);

        try
        {
            var claimId = await repository.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC claim.SP_CreateClaim " +
                "@tenant_id = @tenant_id, @contract_id = @contract_id, @reported_date = @reported_date, " +
                "@incident_date = @incident_date, @coverage_code = @coverage_code, @description = @description, " +
                "@reserved_amount = @reserved_amount, @created_claim_id = @id OUTPUT; " +
                "SELECT @id;",
                new
                {
                    tenant_id = tenantId,
                    contract_id = cmd.ContractId,
                    coverage_code = cmd.CoverageCode,
                    incident_date = cmd.IncidentDate,
                    reported_date = cmd.ReportedDate,
                    description = cmd.Description,
                    reserved_amount = cmd.ReservedAmount
                },
                cancellationToken);

            return Results.Created($"/api/claims/{claimId}", new { claimId });
        }
        catch (SqlException ex) when (ex.Number >= 51600 && ex.Number < 51700)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
    }

    private static async Task<IResult> CloseClaimAsync(
        Guid claimId,
        CloseClaimCommand cmd,
        ClaimsPrincipal user,
        IWriteRepository repository,
        CancellationToken cancellationToken)
    {
        if (cmd.PaidAmount is < 0)
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["paidAmount"] = ["PaidAmount negatif olamaz."]
            });

        var tenantId = TenantClaims.GetRequiredTenantId(user);

        try
        {
            await repository.ExecuteAsync(
                "EXEC claim.SP_CloseClaim @tenant_id = @tenant_id, @claim_id = @claim_id, " +
                "@closed_date = @closed_date, @paid_amount = @paid_amount;",
                new
                {
                    tenant_id = tenantId,
                    claim_id = claimId,
                    closed_date = DateOnly.FromDateTime(DateTime.UtcNow),
                    paid_amount = cmd.PaidAmount
                },
                cancellationToken);

            return Results.NoContent();
        }
        catch (SqlException ex) when (ex.Number >= 51600 && ex.Number < 51700)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
    }
}
