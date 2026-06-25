using System.Security.Claims;
using Microsoft.Data.SqlClient;
using YafesPars.Api.Security;
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

        api.MapPost("/objects", async (CreateRiskObjectCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "DECLARE @id UNIQUEIDENTIFIER; " +
                    "EXEC risk.sp_CreateRiskObject @tenant_id, @risk_object_type_code, @description, NULL, NULL, @id OUTPUT; " +
                    "SELECT @id;",
                    new { tenant_id = tenantId, risk_object_type_code = cmd.RiskObjectTypeCode, description = cmd.Description },
                    ct);
                return Results.Created($"/api/risk/objects/{id}", new { riskObjectId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51710 and <= 51730)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/vehicles", async (CreateVehicleRiskCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "DECLARE @id UNIQUEIDENTIFIER; " +
                    "EXEC risk.sp_CreateVehicle @tenant_id, @plate_number, @brand, @model, @model_year, @chassis_number, @engine_number, @market_value, @currency_code, NULL, @id OUTPUT; " +
                    "SELECT @id;",
                    new { tenant_id = tenantId, plate_number = cmd.PlateNumber, brand = cmd.Brand, model = cmd.Model, model_year = cmd.ModelYear, chassis_number = cmd.ChassisNumber, engine_number = cmd.EngineNumber, market_value = cmd.MarketValue, currency_code = cmd.CurrencyCode },
                    ct);
                return Results.Created($"/api/risk/vehicles/{id}", new { vehicleId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51710 and <= 51730)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/properties", async (CreatePropertyRiskCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "DECLARE @id UNIQUEIDENTIFIER; " +
                    "EXEC risk.sp_CreateProperty @tenant_id, @property_address, @property_type_code, @construction_area, @construction_year, @insured_value, @currency_code, NULL, @id OUTPUT; " +
                    "SELECT @id;",
                    new { tenant_id = tenantId, property_address = cmd.Address, property_type_code = cmd.PropertyTypeCode, construction_area = cmd.ConstructionArea, construction_year = cmd.ConstructionYear, insured_value = cmd.InsuredValue, currency_code = cmd.CurrencyCode },
                    ct);
                return Results.Created($"/api/risk/properties/{id}", new { propertyId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51710 and <= 51730)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/links", async (LinkRiskToContractCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC risk.sp_LinkRiskToContract @tenant_id, @contract_id, @insurable_object_id;",
                    new { tenant_id = tenantId, contract_id = cmd.ContractId, insurable_object_id = cmd.RiskObjectId },
                    ct);
                return Results.NoContent();
            }
            catch (SqlException ex) when (ex.Number is >= 51710 and <= 51730)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        return app;
    }
}
