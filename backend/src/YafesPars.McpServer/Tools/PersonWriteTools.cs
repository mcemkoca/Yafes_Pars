using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class PersonWriteTools
{
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public PersonWriteTools(IWriteRepository write, OperatorContext ctx)
    {
        _write = write;
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Maak een nieuwe natuurlijke persoon (klant) aan. / Gerçek kişi (müşteri) oluştur.\n" +
        "Verplichte velden: voornaam of achternaam. / Zorunlu: ad veya soyad.\n" +
        "Taalcode: NL, FR, DE. Nationaliteit: BE, NL, enz.")]
    public async Task<string> CreateNaturalPerson(
        [Description("Voornaam / Ad")] string? firstName = null,
        [Description("Achternaam / Soyad")] string? lastName = null,
        [Description("Taalcode: NL (standaard), FR, DE / Dil kodu")] string languageCode = "NL",
        [Description("Dossiernummer (optioneel) / Dosya numarası")] string? dossier = null,
        [Description("Nationaliteit bijv. BE, NL / Uyruk")] string? nationality = null,
        [Description("Geboortedatum (YYYY-MM-DD) / Doğum tarihi")] DateOnly? birthDate = null,
        [Description("Rijksregisternummer 11 cijfers / Ulusal kimlik numarası")] string? nationalNumber = null,
        [Description("Aanspreektitel: DHR, MVR, X / Unvan")] string? titleCode = null,
        [Description("Rijksregisternummer 11 cijfers / RRN")] string? rrn = null,
        [Description("Burgerlijke staat: ONGEHUWD, GEHUWD, WETTELIJK_SAMENWONEND, FEITELIJK_SAMENWONEND, GESCHEIDEN, WEDUWE_WEDUWNAAR")] string? civilStatus = null,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(firstName) && string.IsNullOrWhiteSpace(lastName))
            return "Fout: voornaam of achternaam is verplicht. / Hata: ad veya soyad zorunludur.";

        try
        {
            var personId = await _write.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC person.SP_CreateNaturalPerson " +
                "@tenant_id, @dossier, @language_code, @nationality, @first_name, @last_name, @birth_date, @title_code, NULL, @id OUTPUT, @rrn, @civil_status; " +
                "SELECT @id;",
                new
                {
                    tenant_id = _ctx.TenantId,
                    dossier,
                    language_code = languageCode,
                    nationality,
                    first_name = firstName,
                    last_name = lastName,
                    birth_date = birthDate,
                    title_code = titleCode,
                    rrn,
                    civil_status = civilStatus
                },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                personId,
                message = $"Klant aangemaakt: {firstName} {lastName} (ID: {personId})"
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Maak een rechtspersoon (bedrijf, vzw) aan. / Tüzel kişi (şirket) oluştur.\n" +
        "Verplichte velden: bedrijfsnaam. KBO-nummer: 10 cijfers. BTW-nummer bijv. BE0123456789.")]
    public async Task<string> CreateLegalPerson(
        [Description("Volledige juridische naam / Ticari ünvan")] string legalName = "",
        [Description("Rechtsvorm: NV, BV, VZW, CVBA / Hukuki form")] string? legalForm = null,
        [Description("BTW-nummer bijv. BE0123456789 / KDV numarası")] string? vatNumber = null,
        [Description("KBO-nummer 10 cijfers bijv. 0123456789 / KBO numarası")] string? kboNumber = null,
        [Description("Taalcode: NL (standaard), FR, DE")] string languageCode = "NL",
        [Description("Dossiernummer / Dosya numarası")] string? dossier = null,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(legalName))
            return "Fout: bedrijfsnaam (legalName) is verplicht.";

        try
        {
            var personId = await _write.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC person.SP_CreateLegalPerson " +
                "@tenant_id = @tenant_id, @dossier = @dossier, @language_code = @language_code, " +
                "@legal_name = @legal_name, @legal_form = @legal_form, @vat_number = @vat_number, " +
                "@kbo_number = @kbo_number, @created_person_id = @id OUTPUT; " +
                "SELECT @id;",
                new
                {
                    tenant_id = _ctx.TenantId,
                    dossier,
                    language_code = languageCode,
                    legal_name = legalName,
                    legal_form = legalForm,
                    vat_number = vatNumber,
                    kbo_number = kboNumber
                },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                personId,
                message = $"Rechtspersoon aangemaakt: {legalName} (ID: {personId})"
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }
}
