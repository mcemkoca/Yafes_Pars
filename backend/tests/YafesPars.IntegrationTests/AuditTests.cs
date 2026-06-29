using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class AuditTests
{
    private readonly SqlServerFixture _fx;
    public AuditTests(SqlServerFixture fx) => _fx = fx;

    private AuditTools Audit => new(_fx.Read, _fx.Operator);

    [SkippableFact]
    public async Task GetAuditLog_RunsWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Audit.GetAuditLog(limit: 10);
        Assert.DoesNotContain("Databasefout", res);
    }

    [SkippableFact]
    public async Task GetEntityHistory_UnknownEntity_ReturnsNoData()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Audit.GetEntityHistory("policy", "Contract", Guid.NewGuid().ToString());
        Assert.DoesNotContain("Databasefout", res);
        Assert.Contains("Geen wijzigingshistorie", res);
    }

    [SkippableFact]
    public async Task GetUserActivity_UnknownUser_ReturnsNoActivity()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Audit.GetUserActivity(Guid.NewGuid(), hoursBack: 1);
        Assert.DoesNotContain("Databasefout", res);
        Assert.Contains("Geen activiteit", res);
    }
}
