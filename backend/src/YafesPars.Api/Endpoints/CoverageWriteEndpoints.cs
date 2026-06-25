using System.Security.Claims;
using Microsoft.Data.SqlClient;
using YafesPars.Api.Security;
using YafesPars.Application.Commands;
using YafesPars.Application.Abstractions;

namespace YafesPars.Api.Endpoints;

public static class CoverageWriteEndpoints
{
    public static IEndpointRouteBuilder MapCoverageWriteEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/coverage")
            .WithTags("Coverage")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("write");

        api.MapPost("/items", async (AddCoverageItemCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "DECLARE @id UNIQUEIDENTIFIER; " +
                    "EXEC coverage.sp_AddCoverageItem @tenant_id, @contract_id, @coverage_type_code, @coverage_limit, @deductible, @currency_code, @id OUTPUT; " +
                    "SELECT @id;",
                    new { tenant_id = tenantId, contract_id = cmd.ContractId, coverage_type_code = cmd.CoverageTypeCode, coverage_limit = cmd.CoverageLimit, deductible = cmd.Deductible, currency_code = cmd.CurrencyCode },
                    ct);
                return Results.Created($"/api/coverage/items/{id}", new { coverageItemId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51740 and <= 51780)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/items/{coverageItemId:guid}/premium", async (Guid coverageItemId, SetPremiumCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            if (cmd.CoverageItemId != coverageItemId)
                return Results.BadRequest(new { error = "Route coverageItemId must match body CoverageItemId." });
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC coverage.sp_SetPremium @tenant_id, @coverage_item_id, @gross_premium, @tax_amount, @commission_amount, @effective_date;",
                    new { tenant_id = tenantId, coverage_item_id = cmd.CoverageItemId, gross_premium = cmd.GrossPremium, tax_amount = cmd.TaxAmount, commission_amount = cmd.CommissionAmount, effective_date = cmd.EffectiveDate },
                    ct);
                return Results.NoContent();
            }
            catch (SqlException ex) when (ex.Number is >= 51740 and <= 51780)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPut("/items/{coverageItemId:guid}", async (Guid coverageItemId, UpdateCoverageCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            if (cmd.CoverageItemId != coverageItemId)
                return Results.BadRequest(new { error = "Route coverageItemId must match body CoverageItemId." });
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC coverage.sp_UpdateCoverage @tenant_id, @coverage_item_id, @coverage_limit, @deductible;",
                    new { tenant_id = tenantId, coverage_item_id = cmd.CoverageItemId, coverage_limit = cmd.CoverageLimit, deductible = cmd.Deductible },
                    ct);
                return Results.NoContent();
            }
            catch (SqlException ex) when (ex.Number is >= 51740 and <= 51780)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        return app;
    }
}
