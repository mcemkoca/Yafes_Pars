using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class PremiumCalculatorTests
{
    private readonly SqlServerFixture _fx;
    public PremiumCalculatorTests(SqlServerFixture fx) => _fx = fx;

    private PremiumCalculatorTools Premium => new(_fx.Read, _fx.Write, _fx.Operator);

    [SkippableFact]
    public async Task GetTariffRates_ReturnsShape()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Premium.GetTariffRates();
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("count", out _));
        Assert.True(doc.RootElement.TryGetProperty("tariffs", out var arr));
        Assert.Equal(JsonValueKind.Array, arr.ValueKind);
    }

    [SkippableFact]
    public async Task UpsertTariffRate_CreatesEntry()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Premium.UpsertTariffRate(
            coverageDomainCode: "AUTO",
            baseRatePct: 0.85m,
            coverageTypeCode: "*",
            minPremiumEur: 150m,
            maxPremiumEur: 5000m);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("success", out var s) && s.GetBoolean());
        Assert.True(doc.RootElement.TryGetProperty("tariff", out _));
    }

    [SkippableFact]
    public async Task CalculatePremium_ReturnsShape()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        // Demo veride bir sözleşme ID'si al
        var contracts = await _fx.Read.QueryAsync<dynamic>(
            "SELECT TOP 1 contract_id AS ContractId FROM policy.Contract WHERE tenant_id = @tid",
            new { tid = _fx.Operator.TenantId });
        if (contracts.Count == 0) return;

        var contractId = (Guid)contracts[0].ContractId;
        var res = await Premium.CalculatePremium(contractId);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("coverageCount", out _));
        Assert.True(doc.RootElement.TryGetProperty("totalAnnualEur", out _));
    }
}
