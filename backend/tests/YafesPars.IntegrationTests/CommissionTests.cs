using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class CommissionTests
{
    private readonly SqlServerFixture _fx;
    public CommissionTests(SqlServerFixture fx) => _fx = fx;

    private CommissionTools Commissions => new(_fx.Read, _fx.Write, _fx.Operator);

    [SkippableFact]
    public async Task GetCommissions_RunsWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Commissions.GetCommissions(limit: 10);
        Assert.DoesNotContain("Databasefout", res);
    }

    [SkippableFact]
    public async Task RecordCommission_InvalidRate_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Commissions.RecordCommission(
            contractId: Guid.NewGuid(),
            commissionDate: DateOnly.FromDateTime(DateTime.UtcNow),
            grossPremiumEur: 1000m,
            ratePct: 1.5m); // ongeldig: > 1
        Assert.Contains("Ongeldig tarief", res);
    }

    [SkippableFact]
    public async Task GetCommissionReport_QueriesViewWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Commissions.GetCommissionReport(limit: 50);
        Assert.DoesNotContain("Databasefout", res);
    }
}
