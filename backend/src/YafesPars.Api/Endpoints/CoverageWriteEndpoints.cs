using Microsoft.Data.SqlClient;
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

        api.MapPost("/items", async (AddCoverageItemCommand cmd, IWriteRepository repo) =>
        {
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "EXEC coverage.sp_AddCoverageItem @ContractId, @CoverageTypeCode, @CoverageLimit, @Deductible, @CurrencyCode",
                    new { cmd.ContractId, cmd.CoverageTypeCode, cmd.CoverageLimit, cmd.Deductible, cmd.CurrencyCode });
                return Results.Created($"/api/coverage/items/{id}", new { coverageItemId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51900 and <= 51930)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/items/{coverageItemId:guid}/premium", async (Guid coverageItemId, SetPremiumCommand cmd, IWriteRepository repo) =>
        {
            if (cmd.CoverageItemId != coverageItemId)
                return Results.BadRequest(new { error = "Route coverageItemId must match body CoverageItemId." });
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC coverage.sp_SetPremium @CoverageItemId, @GrossPremium, @TaxAmount, @CommissionAmount, @EffectiveDate",
                    new { cmd.CoverageItemId, cmd.GrossPremium, cmd.TaxAmount, cmd.CommissionAmount, cmd.EffectiveDate });
                return Results.NoContent();
            }
            catch (SqlException ex) when (ex.Number is >= 51900 and <= 51930)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPut("/items/{coverageItemId:guid}", async (Guid coverageItemId, UpdateCoverageCommand cmd, IWriteRepository repo) =>
        {
            if (cmd.CoverageItemId != coverageItemId)
                return Results.BadRequest(new { error = "Route coverageItemId must match body CoverageItemId." });
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC coverage.sp_UpdateCoverage @CoverageItemId, @CoverageLimit, @Deductible",
                    new { cmd.CoverageItemId, cmd.CoverageLimit, cmd.Deductible });
                return Results.NoContent();
            }
            catch (SqlException ex) when (ex.Number is >= 51900 and <= 51930)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        return app;
    }
}
