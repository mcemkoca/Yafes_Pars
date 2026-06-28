using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class PolicyWriteTools
{
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public PolicyWriteTools(IWriteRepository write, OperatorContext ctx)
    {
        _write = write;
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Maak een nieuwe polis aan. / Yeni poliçe oluştur.\n" +
        "Domeincodes: AUTO, MOTOR, FIRE, FAMILY, LIABILITY, LEGAL_PROTECTION, HEALTH, LIFE, LOAN, BUSINESS.\n" +
        "Typecodes (policy.ContractType): AUTO_BA, FIRE_HOME, FAMILY_RC, LOAN_PROTECTION.\n" +
        "Startdatum verplicht. Einddatum optioneel (geen einddatum = doorlopend).")]
    public async Task<string> CreatePolicy(
        [Description("Domeincode: AUTO, MOTOR, FIRE, FAMILY, LIABILITY, HEALTH, LIFE, LOAN, BUSINESS")] string contractDomainCode = "",
        [Description("Typecode: AUTO_BA, FIRE_HOME, FAMILY_RC, LOAN_PROTECTION")] string contractTypeCode = "",
        [Description("Ingangsdatum (YYYY-MM-DD) / Başlangıç tarihi")] DateOnly startDate = default,
        [Description("Vervaldatum (YYYY-MM-DD, optioneel) / Bitiş tarihi")] DateOnly? endDate = null,
        [Description("Maatschappijcode (optioneel) / Sigorta şirket kodu")] string? insurerCode = null,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(contractDomainCode) || string.IsNullOrWhiteSpace(contractTypeCode))
            return "Fout: contractDomainCode en contractTypeCode zijn verplicht.";

        if (startDate == default)
            return "Fout: startdatum is verplicht.";

        if (endDate.HasValue && endDate <= startDate)
            return "Fout: vervaldatum moet na de ingangsdatum liggen.";

        try
        {
            var contractId = await _write.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC policy.SP_CreateContract " +
                "@tenant_id = @tenant_id, @contract_domain_code = @contract_domain_code, " +
                "@contract_type_code = @contract_type_code, @start_date = @start_date, @end_date = @end_date, " +
                "@insurer_institution_code = @insurer_institution_code, @created_contract_id = @id OUTPUT; " +
                "SELECT @id;",
                new
                {
                    tenant_id = _ctx.TenantId,
                    contract_domain_code = contractDomainCode,
                    contract_type_code = contractTypeCode,
                    start_date = startDate,
                    end_date = endDate,
                    insurer_institution_code = insurerCode
                },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                contractId,
                message = $"Polis aangemaakt (domein: {contractDomainCode}, type: {contractTypeCode}). ID: {contractId}"
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Voeg een partij toe aan een polis. / Poliçeye taraf ekle.\n" +
        "Rolcodes: POLICYHOLDER (verzekeringnemer), INSURED (verzekerde), BENEFICIARY (begunstigde).")]
    public async Task<string> AddPolicyParty(
        [Description("Polis-ID (UUID)")] Guid contractId = default,
        [Description("Persoon-ID (UUID) / Kişi ID")] Guid personId = default,
        [Description("Rolcode: POLICYHOLDER, INSURED, BENEFICIARY")] string roleCode = "POLICYHOLDER",
        CancellationToken ct = default)
    {
        if (contractId == default || personId == default)
            return "Fout: contractId en personId zijn verplicht.";

        try
        {
            await _write.ExecuteAsync(
                "EXEC policy.SP_AddContractParty @tenant_id = @tenant_id, @contract_id = @contract_id, " +
                "@person_id = @person_id, @contract_party_role_code = @role_code, @is_primary = 0;",
                new { tenant_id = _ctx.TenantId, contract_id = contractId, person_id = personId, role_code = roleCode },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                message = $"Partij toegevoegd aan polis {contractId} met rol {roleCode}."
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Koppel een verzekerd object aan een polis. / Poliçeye sigortalı nesne bağla.\n" +
        "Gebruik eerst register_vehicle of register_property om het object te registreren.")]
    public async Task<string> AddPolicyObject(
        [Description("Polis-ID (UUID)")] Guid contractId = default,
        [Description("Object-ID van voertuig of eigendom (UUID) / Nesne ID")] Guid insurableObjectId = default,
        CancellationToken ct = default)
    {
        if (contractId == default || insurableObjectId == default)
            return "Fout: contractId en insurableObjectId zijn verplicht.";

        try
        {
            await _write.ExecuteAsync(
                "EXEC policy.SP_AddContractObject @tenant_id = @tenant_id, @contract_id = @contract_id, " +
                "@insurable_object_id = @insurable_object_id, @contract_object_status_code = N'ACTIVE';",
                new { tenant_id = _ctx.TenantId, contract_id = contractId, insurable_object_id = insurableObjectId },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                message = $"Object {insurableObjectId} gekoppeld aan polis {contractId}."
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Voeg een dekkingspost toe aan een polis. / Poliçeye teminat kalemi ekle.\n" +
        "Dekkingscodes: BA_AUTO, OMNIUM, MINI_OMNIUM, FIRE_BUILDING, FIRE_CONTENTS, FAMILY_LIABILITY,\n" +
        "LEGAL_PROTECTION, LEGAL_PROTECTION_AUTO, HOSPITALIZATION, LIFE_COVER.\n" +
        "Limiet en valuta verplicht. Eigen risico optioneel.")]
    public async Task<string> AddCoverageItem(
        [Description("Polis-ID (UUID)")] Guid contractId = default,
        [Description("Dekkingscode: BA_AUTO, OMNIUM, FIRE_BUILDING, HOSPITALIZATION, enz.")] string coverageTypeCode = "",
        [Description("Verzekerd bedrag (bijv. 250000) / Sigorta bedeli")] decimal coverageLimit = 0,
        [Description("Eigen risico (optioneel) / Muafiyet")] decimal? deductible = null,
        [Description("Valuta: EUR (standaard), USD, GBP")] string currencyCode = "EUR",
        CancellationToken ct = default)
    {
        if (contractId == default || string.IsNullOrWhiteSpace(coverageTypeCode) || coverageLimit <= 0)
            return "Fout: contractId, dekkingscode en limiet (> 0) zijn verplicht.";

        try
        {
            var itemId = await _write.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC coverage.sp_AddCoverageItem " +
                "@tenant_id, @contract_id, @coverage_type_code, @coverage_limit, @deductible, @currency_code, @id OUTPUT; " +
                "SELECT @id;",
                new
                {
                    tenant_id = _ctx.TenantId,
                    contract_id = contractId,
                    coverage_type_code = coverageTypeCode,
                    coverage_limit = coverageLimit,
                    deductible,
                    currency_code = currencyCode
                },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                coverageItemId = itemId,
                message = $"Dekking {coverageTypeCode} toegevoegd (limiet: {coverageLimit:N0} {currencyCode})."
            }, JsonOpts.Default);
        }
        catch (SqlException ex) when (ex.Number == 51753)
        {
            return $"Onbekende dekkingscode: '{coverageTypeCode}'. Gebruik een geldige code: BA_AUTO, OMNIUM, FIRE_BUILDING, enz.";
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }
}
