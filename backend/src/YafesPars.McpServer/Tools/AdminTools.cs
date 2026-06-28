using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Tenant-beheer. Let op: provisioning maakt een NIEUWE tenant aan en is dus
/// niet tenant-scoped (in tegenstelling tot de andere tools). Bedoeld voor
/// systeembeheerders / onboarding.
/// </summary>
[McpServerToolType]
public sealed class AdminTools
{
    private readonly IWriteRepository _write;
    private readonly IReadRepository _read;

    public AdminTools(IWriteRepository write, IReadRepository read)
    {
        _write = write;
        _read = read;
    }

    [McpServerTool, Description(
        "Maak een nieuwe tenant (verzekeraar/makelaar) aan met een initiële beheerder. / " +
        "Yeni sigorta şirketi/acente + yönetici oluştur (onboarding).\n" +
        "De beheerder krijgt automatisch de BROKER_ADMIN-rol. tenant_code moet uniek zijn.")]
    public async Task<string> ProvisionTenant(
        [Description("Unieke tenantcode bijv. ACME-BE / Tenant kodu")] string tenantCode = "",
        [Description("Juridische naam / Ticari ünvan")] string legalName = "",
        [Description("Weergavenaam (optioneel) / Görünen ad")] string? displayName = null,
        [Description("BTW-nummer bijv. BE0123456789 / KDV no")] string? vatNumber = null,
        [Description("E-mail van de beheerder / Yönetici e-postası")] string adminEmail = "",
        [Description("Naam van de beheerder / Yönetici adı")] string? adminDisplayName = null,
        [Description("Externe IdP subject-id van de beheerder (optioneel)")] string? adminExternalSubjectId = null,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(tenantCode) || string.IsNullOrWhiteSpace(legalName) || string.IsNullOrWhiteSpace(adminEmail))
            return "Fout: tenantCode, legalName en adminEmail zijn verplicht.";

        try
        {
            var rows = await _write.ExecuteScalarAsync<string>(
                "DECLARE @tid UNIQUEIDENTIFIER, @uid UNIQUEIDENTIFIER; " +
                "EXEC core.SP_ProvisionTenant " +
                "@tenant_code = @tenant_code, @legal_name = @legal_name, @display_name = @display_name, " +
                "@vat_number = @vat_number, @admin_email = @admin_email, @admin_display_name = @admin_display_name, " +
                "@admin_external_subject_id = @admin_external_subject_id, " +
                "@tenant_id = @tid OUTPUT, @admin_user_id = @uid OUTPUT; " +
                "SELECT CAST(@tid AS NVARCHAR(36)) + '|' + CAST(@uid AS NVARCHAR(36));",
                new
                {
                    tenant_code = tenantCode,
                    legal_name = legalName,
                    display_name = displayName,
                    vat_number = vatNumber,
                    admin_email = adminEmail,
                    admin_display_name = adminDisplayName,
                    admin_external_subject_id = adminExternalSubjectId
                },
                ct);

            var parts = (rows ?? "|").Split('|');
            return JsonSerializer.Serialize(new
            {
                success = true,
                tenantId = parts.ElementAtOrDefault(0),
                adminUserId = parts.ElementAtOrDefault(1),
                role = "BROKER_ADMIN",
                message = $"Tenant '{legalName}' ({tenantCode}) aangemaakt met beheerder {adminEmail}."
            }, JsonOpts.Default);
        }
        catch (SqlException ex) when (ex.Number == 51903)
        {
            return $"Tenantcode '{tenantCode}' bestaat al. Kies een unieke code.";
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Lijst alle tenants (verzekeraars/makelaars) in het systeem. / Tüm tenant'ları listele.")]
    public async Task<string> ListTenants(CancellationToken ct = default)
    {
        var sql = """
            SELECT t.tenant_id, t.tenant_code, t.legal_name, t.display_name, t.vat_number, t.is_active,
                   (SELECT COUNT(*) FROM core.AppUser u WHERE u.tenant_id = t.tenant_id) AS user_count,
                   t.created_at_utc
            FROM core.Tenant t
            ORDER BY t.created_at_utc DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, null, ct);
        return rows.Count == 0
            ? "Geen tenants gevonden."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }
}
