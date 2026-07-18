using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class ComplaintTests
{
    private readonly SqlServerFixture _fx;
    public ComplaintTests(SqlServerFixture fx) => _fx = fx;

    private ComplaintTools Complaints => new(_fx.Read, _fx.Write, _fx.Operator);

    [SkippableFact]
    public async Task GetComplaintDashboard_ReturnsCounts()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Complaints.GetComplaintDashboard();
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("openCount", out _));
        Assert.True(doc.RootElement.TryGetProperty("overdueCount", out _));
        Assert.True(doc.RootElement.TryGetProperty("complianceStatus", out _));
    }

    [SkippableFact]
    public async Task GetComplaints_ReturnsListShape()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Complaints.GetComplaints(limit: 10);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("count", out _));
        Assert.True(doc.RootElement.TryGetProperty("complaints", out var arr));
        Assert.Equal(JsonValueKind.Array, arr.ValueKind);
    }

    [SkippableFact]
    public async Task GetFsmaComplaintReport_ReturnsShape()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Complaints.GetFsmaComplaintReport(year: DateTime.UtcNow.Year);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("reportYear", out _));
        Assert.True(doc.RootElement.TryGetProperty("totalFsma", out _));
        Assert.True(doc.RootElement.TryGetProperty("complianceRate", out var rate));
        Assert.True(rate.GetDouble() >= 0 && rate.GetDouble() <= 100);
    }
}
