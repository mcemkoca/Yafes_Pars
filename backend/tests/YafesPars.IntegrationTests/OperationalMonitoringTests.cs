using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class OperationalMonitoringTests
{
    private readonly SqlServerFixture _fx;
    public OperationalMonitoringTests(SqlServerFixture fx) => _fx = fx;

    private OperationalMonitoringTools Monitor => new(_fx.Read, _fx.Operator);

    [SkippableFact]
    public async Task GetOperationalDashboard_ReturnsMetricsObject()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Monitor.GetOperationalDashboard(daysBack: 30);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("metrics", out _),
            "Dashboard yanıtında 'metrics' alanı bekleniyor.");
    }

    [SkippableFact]
    public async Task GetTenantHealthScore_ReturnsHealthScore()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Monitor.GetTenantHealthScore();
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("HealthScore", out var score),
            "HealthScore alanı bekleniyor.");
        var value = score.GetInt32();
        Assert.InRange(value, 0, 100);
    }

    [SkippableFact]
    public async Task GetTenantHealthScore_StatusIsValid()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Monitor.GetTenantHealthScore();
        using var doc = JsonDocument.Parse(res);
        if (doc.RootElement.TryGetProperty("Status", out var status))
        {
            var s = status.GetString();
            Assert.Contains(s, new[] { "HEALTHY", "WARNING", "CRITICAL" });
        }
    }

    [SkippableFact]
    public async Task GetRecentActivity_ReturnsActivityObject()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Monitor.GetRecentActivity(hoursBack: 24);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("totalEvents", out _));
        Assert.True(doc.RootElement.TryGetProperty("activity", out _));
    }

    [SkippableFact]
    public async Task GetOperationalDashboard_LongerPeriod_ReturnsData()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Monitor.GetOperationalDashboard(daysBack: 90);
        using var doc = JsonDocument.Parse(res);
        Assert.Equal(JsonValueKind.Object, doc.RootElement.ValueKind);
        Assert.True(doc.RootElement.TryGetProperty("daysBack", out var db));
        Assert.Equal(90, db.GetInt32());
    }
}
