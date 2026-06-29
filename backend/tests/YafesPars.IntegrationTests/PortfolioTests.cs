using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class PortfolioTests
{
    private readonly SqlServerFixture _fx;
    public PortfolioTests(SqlServerFixture fx) => _fx = fx;

    private PortfolioTools Portfolio => new(_fx.Read, _fx.Operator);

    [SkippableFact]
    public async Task GetPortfolioSummary_RunsWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Portfolio.GetPortfolioSummary();
        Assert.DoesNotContain("Databasefout", res);
    }

    [SkippableFact]
    public async Task GetRiskConcentration_RunsWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Portfolio.GetRiskConcentration(5);
        Assert.DoesNotContain("Databasefout", res);
    }
}
