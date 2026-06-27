using System.Security.Claims;
using Microsoft.Data.SqlClient;
using YafesPars.Api.Security;
using YafesPars.Application.Abstractions;
using YafesPars.Application.Commands;

namespace YafesPars.Api.Endpoints;

public static class PolicyWriteEndpoints
{
    public static IEndpointRouteBuilder MapPolicyWriteEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/policies")
            .WithTags("Policies")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("write");

        api.MapPost("/", CreateContractAsync)
            .WithSummary("Yeni poliçe oluştur");

        api.MapPost("/{contractId:guid}/parties", AddPartyAsync)
            .WithSummary("Poliçeye taraf ekle");

        api.MapPost("/{contractId:guid}/objects", AddObjectAsync)
            .WithSummary("Poliçeye sigortalı nesne ekle");

        return app;
    }

    private static async Task<IResult> CreateContractAsync(
        CreateContractCommand cmd,
        ClaimsPrincipal user,
        IWriteRepository repository,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(cmd.ContractDomainCode) || string.IsNullOrWhiteSpace(cmd.ContractTypeCode))
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["contractDomainCode"] = ["ContractDomainCode zorunludur."],
                ["contractTypeCode"] = ["ContractTypeCode zorunludur."]
            });

        if (cmd.EndDate.HasValue && cmd.EndDate <= cmd.StartDate)
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["endDate"] = ["EndDate, StartDate'den büyük olmalıdır."]
            });

        var tenantId = TenantClaims.GetRequiredTenantId(user);

        try
        {
            var contractId = await repository.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC policy.SP_CreateContract " +
                "@tenant_id = @tenant_id, @contract_domain_code = @contract_domain_code, " +
                "@contract_type_code = @contract_type_code, @start_date = @start_date, @end_date = @end_date, " +
                "@insurer_institution_code = @insurer_institution_code, @created_contract_id = @id OUTPUT; " +
                "SELECT @id;",
                new
                {
                    tenant_id = tenantId,
                    contract_domain_code = cmd.ContractDomainCode,
                    contract_type_code = cmd.ContractTypeCode,
                    start_date = cmd.StartDate,
                    end_date = cmd.EndDate,
                    insurer_institution_code = cmd.InsurerInstitutionCode
                },
                cancellationToken);

            return Results.Created($"/api/policies/{contractId}", new { contractId });
        }
        catch (SqlException ex) when (ex.Number >= 51600 && ex.Number < 51700)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
    }

    private static async Task<IResult> AddPartyAsync(
        Guid contractId,
        AddContractPartyCommand cmd,
        ClaimsPrincipal user,
        IWriteRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        try
        {
            await repository.ExecuteAsync(
                "EXEC policy.SP_AddContractParty @tenant_id = @tenant_id, @contract_id = @contract_id, " +
                "@person_id = @person_id, @contract_party_role_code = @role_code, @is_primary = 0;",
                new
                {
                    tenant_id = tenantId,
                    contract_id = contractId,
                    person_id = cmd.PersonId,
                    role_code = cmd.RoleCode
                },
                cancellationToken);

            return Results.NoContent();
        }
        catch (SqlException ex) when (ex.Number >= 51600 && ex.Number < 51700)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
    }

    private static async Task<IResult> AddObjectAsync(
        Guid contractId,
        AddContractObjectCommand cmd,
        ClaimsPrincipal user,
        IWriteRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        try
        {
            await repository.ExecuteAsync(
                "EXEC policy.SP_AddContractObject @tenant_id = @tenant_id, @contract_id = @contract_id, " +
                "@insurable_object_id = @insurable_object_id, @contract_object_status_code = N'ACTIVE';",
                new
                {
                    tenant_id = tenantId,
                    contract_id = contractId,
                    insurable_object_id = cmd.InsurableObjectId
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
