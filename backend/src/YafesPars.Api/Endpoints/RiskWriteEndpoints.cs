using Microsoft.Data.SqlClient;
using YafesPars.Application.Commands;
using YafesPars.Application.Abstractions;

namespace YafesPars.Api.Endpoints;

public static class RiskWriteEndpoints
{
    public static IEndpointRouteBuilder MapRiskWriteEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/risk")
            .WithTags("Risk")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("write");

        api.MapPost("/objects", async (CreateRiskObjectCommand cmd, IWriteRepository repo) =>
        {
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "EXEC risk.sp_CreateRiskObject @RiskObjectTypeCode, @Description",
                    new { cmd.RiskObjectTypeCode, cmd.Description });
                return Results.Created($"/api/risk/objects/{id}", new { riskObjectId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 52000 and <= 52030)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/vehicles", async (CreateVehicleRiskCommand cmd, IWriteRepository repo) =>
        {
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "EXEC risk.sp_CreateVehicle @PlateNumber, @Brand, @Model, @ModelYear, @ChassisNumber, @EngineNumber, @MarketValue, @CurrencyCode",
                    new { cmd.PlateNumber, cmd.Brand, cmd.Model, cmd.ModelYear, cmd.ChassisNumber, cmd.EngineNumber, cmd.MarketValue, cmd.CurrencyCode });
                return Results.Created($"/api/risk/vehicles/{id}", new { vehicleId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 52000 and <= 52030)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/properties", async (CreatePropertyRiskCommand cmd, IWriteRepository repo) =>
        {
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "EXEC risk.sp_CreateProperty @Address, @PropertyTypeCode, @ConstructionArea, @ConstructionYear, @InsuredValue, @CurrencyCode",
                    new { cmd.Address, cmd.PropertyTypeCode, cmd.ConstructionArea, cmd.ConstructionYear, cmd.InsuredValue, cmd.CurrencyCode });
                return Results.Created($"/api/risk/properties/{id}", new { propertyId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 52000 and <= 52030)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/links", async (LinkRiskToContractCommand cmd, IWriteRepository repo) =>
        {
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC risk.sp_LinkRiskToContract @ContractId, @RiskObjectId",
                    new { cmd.ContractId, cmd.RiskObjectId });
                return Results.NoContent();
            }
            catch (SqlException ex) when (ex.Number is >= 52000 and <= 52030)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        return app;
    }
}
