using System.Security.Claims;
using Microsoft.Data.SqlClient;
using YafesPars.Api.Security;
using YafesPars.Application.Abstractions;
using YafesPars.Application.Commands;

namespace YafesPars.Api.Endpoints;

public static class PersonWriteEndpoints
{
    public static IEndpointRouteBuilder MapPersonWriteEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/persons")
            .WithTags("Persons")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("write");

        api.MapPost("/natural", CreateNaturalPersonAsync)
            .WithSummary("Gerçek kişi oluştur");

        api.MapPost("/legal", CreateLegalPersonAsync)
            .WithSummary("Tüzel kişi oluştur");

        return app;
    }

    private static async Task<IResult> CreateNaturalPersonAsync(
        CreateNaturalPersonCommand cmd,
        ClaimsPrincipal user,
        IWriteRepository repository,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(cmd.FirstName) && string.IsNullOrWhiteSpace(cmd.LastName))
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["name"] = ["FirstName veya LastName zorunludur."]
            });

        var tenantId = TenantClaims.GetRequiredTenantId(user);

        try
        {
            var personId = await repository.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC person.SP_CreateNaturalPerson " +
                "@tenant_id, @dossier, @language_code, @nationality, @first_name, @last_name, @birth_date, @title_code, NULL, @id OUTPUT; " +
                "SELECT @id;",
                new
                {
                    tenant_id = tenantId,
                    dossier = cmd.Dossier,
                    language_code = cmd.LanguageCode,
                    nationality = cmd.Nationality,
                    first_name = cmd.FirstName,
                    last_name = cmd.LastName,
                    birth_date = cmd.BirthDate,
                    title_code = cmd.TitleCode
                },
                cancellationToken);

            return Results.Created($"/api/persons/{personId}", new { personId });
        }
        catch (SqlException ex) when (ex.Number == 51630 || ex.Number == 51631)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
    }

    private static async Task<IResult> CreateLegalPersonAsync(
        CreateLegalPersonCommand cmd,
        ClaimsPrincipal user,
        IWriteRepository repository,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(cmd.LegalName))
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["legalName"] = ["LegalName zorunludur."]
            });

        var tenantId = TenantClaims.GetRequiredTenantId(user);

        try
        {
            var personId = await repository.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC person.SP_CreateLegalPerson " +
                "@tenant_id, @dossier, @language_code, @legal_name, @legal_form, @vat_number, NULL, @id OUTPUT; " +
                "SELECT @id;",
                new
                {
                    tenant_id = tenantId,
                    dossier = cmd.Dossier,
                    language_code = cmd.LanguageCode,
                    legal_name = cmd.LegalName,
                    legal_form = cmd.LegalForm,
                    vat_number = cmd.VatNumber
                },
                cancellationToken);

            return Results.Created($"/api/persons/{personId}", new { personId });
        }
        catch (SqlException ex) when (ex.Number >= 51600 && ex.Number < 51700)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
    }
}
