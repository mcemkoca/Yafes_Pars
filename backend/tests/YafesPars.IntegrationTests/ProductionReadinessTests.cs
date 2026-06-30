using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class ProductionReadinessTests
{
    private readonly SqlServerFixture _fx;
    public ProductionReadinessTests(SqlServerFixture fx) => _fx = fx;

    private ProductionReadinessTools Prod => new(_fx.Read, _fx.Operator);

    [SkippableFact]
    public async Task CheckProductionReadiness_ReturnsReadinessStatus()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Prod.CheckProductionReadiness();
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("ReadinessStatus", out var status));
        var s = status.GetString();
        Assert.Contains(s, new[] { "READY", "WARNING", "NOT_READY" });
    }

    [SkippableFact]
    public async Task CheckProductionReadiness_HasEnvironmentField()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Prod.CheckProductionReadiness();
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("Environment", out _));
        Assert.True(doc.RootElement.TryGetProperty("AppliedMigrations", out var m));
        Assert.True(m.GetInt32() >= 30, "En az 30 migration uygulanmış olmalı.");
    }

    [SkippableFact]
    public async Task GetMigrationHistory_ReturnsAllMigrations()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Prod.GetMigrationHistory();
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("count", out var count));
        Assert.True(count.GetInt32() >= 30);
        Assert.True(doc.RootElement.TryGetProperty("migrations", out var arr));
        Assert.Equal(JsonValueKind.Array, arr.ValueKind);
    }
}
