using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class TenantProvisioningTests
{
    private readonly SqlServerFixture _fx;
    public TenantProvisioningTests(SqlServerFixture fx) => _fx = fx;

    private AdminTools Admin => new(_fx.Write, _fx.Read);

    private static Guid ExtractGuid(string json, string prop)
    {
        using var doc = JsonDocument.Parse(json);
        return Guid.Parse(doc.RootElement.GetProperty(prop).GetString()!);
    }

    [SkippableFact]
    public async Task ProvisionTenant_CreatesTenantAdminAndRole()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var code = "ACME-" + Random.Shared.Next(1000, 9999);
        var res = await Admin.ProvisionTenant(
            code, "Acme Verzekeringen NV", "Acme", "BE0123456789",
            "beheerder@acme.be", "Acme Beheerder");

        Assert.DoesNotContain("Fout", res);
        Assert.DoesNotContain("Databasefout", res);
        var tenantId = ExtractGuid(res, "tenantId");
        var adminUserId = ExtractGuid(res, "adminUserId");

        // Tenant bestaat
        var tenantCount = (await _fx.Read.QueryAsync<long>(
            "SELECT COUNT_BIG(*) FROM core.Tenant WHERE tenant_id = @id AND tenant_code = @code",
            new { id = tenantId, code })).Single();
        Assert.Equal(1, tenantCount);

        // Beheerder bestaat in de juiste tenant
        var userCount = (await _fx.Read.QueryAsync<long>(
            "SELECT COUNT_BIG(*) FROM core.AppUser WHERE user_id = @uid AND tenant_id = @tid AND email = 'beheerder@acme.be'",
            new { uid = adminUserId, tid = tenantId })).Single();
        Assert.Equal(1, userCount);

        // BROKER_ADMIN-rol toegekend
        var roleCount = (await _fx.Read.QueryAsync<long>(
            """
            SELECT COUNT_BIG(*) FROM core.UserRole ur
            INNER JOIN core.Role r ON r.role_id = ur.role_id
            WHERE ur.user_id = @uid AND r.role_code = 'BROKER_ADMIN'
            """,
            new { uid = adminUserId })).Single();
        Assert.Equal(1, roleCount);
    }

    [SkippableFact]
    public async Task ProvisionTenant_RejectsDuplicateCode()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var code = "DUP-" + Random.Shared.Next(1000, 9999);
        var first = await Admin.ProvisionTenant(code, "Eerste NV", null, null, "a@first.be");
        Assert.DoesNotContain("Fout", first);

        var second = await Admin.ProvisionTenant(code, "Tweede NV", null, null, "b@second.be");
        Assert.Contains("bestaat al", second);
    }

    [SkippableFact]
    public async Task ProvisionTenant_RequiresMandatoryFields()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var res = await Admin.ProvisionTenant("", "Geen code NV", null, null, "x@y.be");
        Assert.StartsWith("Fout", res);
    }
}
