using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class OperationsTests
{
    private readonly SqlServerFixture _fx;
    public OperationsTests(SqlServerFixture fx) => _fx = fx;

    private OperationsTools Ops => new(_fx.Read, _fx.Write, _fx.Operator);

    [SkippableFact]
    public async Task GetExpiringPolicies_RunsWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Ops.GetExpiringPolicies(90);
        Assert.DoesNotContain("Databasefout", res);
    }

    [SkippableFact]
    public async Task CreateRenewalTasks_DryRun_Succeeds()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Ops.CreateRenewalTasks(60, dryRun: true);
        Assert.DoesNotContain("Databasefout", res);
        Assert.Contains("Dry-run", res);
    }

    [SkippableFact]
    public async Task GetFsmaReport_QueriesViewWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Ops.GetFsmaReport(50);
        // View moet bestaan en de query mag niet falen (leeg resultaat is ok).
        Assert.DoesNotContain("Databasefout", res);
    }
}
