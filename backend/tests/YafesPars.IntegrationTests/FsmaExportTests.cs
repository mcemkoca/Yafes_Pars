using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class FsmaExportTests
{
    private readonly SqlServerFixture _fx;
    public FsmaExportTests(SqlServerFixture fx) => _fx = fx;

    private FsmaExportTools Fsma => new(_fx.Read, _fx.Operator);

    [SkippableFact]
    public async Task ExportFsmaReport_Csv_ContainsHeader()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Fsma.ExportFsmaReport("2025-01-01", "2025-12-31", "csv");
        Assert.Contains("section;branche;aantal_polissen", res);
    }

    [SkippableFact]
    public async Task ExportFsmaReport_Json_ReturnsObject()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Fsma.ExportFsmaReport("2025-01-01", "2025-12-31", "json");
        using var doc = JsonDocument.Parse(res);
        Assert.Equal(JsonValueKind.Object, doc.RootElement.ValueKind);
    }

    [SkippableFact]
    public async Task PreviewFsmaReport_ReturnsCountFields()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Fsma.PreviewFsmaReport("2025-01-01", "2025-12-31");
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("totalActivePolicies", out _));
        Assert.True(doc.RootElement.TryGetProperty("totalCommissionEur",  out _));
    }

    [SkippableFact]
    public async Task ExportFsmaReport_InvalidDate_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Fsma.ExportFsmaReport("not-a-date", "2025-12-31");
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("error", out _));
    }

    [SkippableFact]
    public async Task ExportFsmaReport_EndBeforeStart_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Fsma.ExportFsmaReport("2025-12-31", "2025-01-01");
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("error", out _));
    }
}
