using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class TenantManagementTests
{
    private readonly SqlServerFixture _fx;
    public TenantManagementTests(SqlServerFixture fx) => _fx = fx;

    private TenantManagementTools Mgmt => new(_fx.Read, _fx.Operator);

    [SkippableFact]
    public async Task GetTenants_ReturnsTenantsObject()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Mgmt.GetTenants();
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("count", out _));
        Assert.True(doc.RootElement.TryGetProperty("tenants", out _));
    }

    [SkippableFact]
    public async Task GetTenants_IncludeInactive_ReturnsArray()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var active   = await Mgmt.GetTenants(includeInactive: false);
        var allItems = await Mgmt.GetTenants(includeInactive: true);
        using var docActive = JsonDocument.Parse(active);
        using var docAll    = JsonDocument.Parse(allItems);
        var countActive = docActive.RootElement.GetProperty("count").GetInt32();
        var countAll    = docAll.RootElement.GetProperty("count").GetInt32();
        Assert.True(countAll >= countActive, "Tüm tenant sayısı ≥ aktif tenant sayısı olmalı.");
    }

    [SkippableFact]
    public async Task GetSystemSettings_ReturnsArray()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Mgmt.GetSystemSettings();
        using var doc = JsonDocument.Parse(res);
        Assert.Equal(JsonValueKind.Array, doc.RootElement.ValueKind);
        Assert.True(doc.RootElement.GetArrayLength() > 0,
            "En az bir sistem ayarı (environment) bekleniyor.");
    }

    [SkippableFact]
    public async Task UpsertSystemSetting_CreatesOrUpdates()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var testKey = $"test_faz10_{Guid.NewGuid():N}";
        var res = await Mgmt.UpsertSystemSetting(testKey, "test_value", "Faz 10 integrasyon testi");
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("SettingKey", out var key));
        Assert.Equal(testKey, key.GetString());
    }

    [SkippableFact]
    public async Task ProvisionTenant_NewTenant_ReturnsTenantId()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var code  = $"T-{Guid.NewGuid():N}"[..12];
        var res   = await Mgmt.ProvisionTenant(
            tenantCode:    code,
            legalName:     "Faz 10 Test NV",
            adminEmail:    $"admin+{Guid.NewGuid():N}@test.example.com");
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("TenantId", out var tid));
        Assert.NotEqual(Guid.Empty, tid.GetGuid());
    }
}
