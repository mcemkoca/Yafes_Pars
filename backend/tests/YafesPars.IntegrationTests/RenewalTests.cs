using System.Text.Json;
using Xunit;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class RenewalTests
{
    private readonly SqlServerFixture _fx;
    public RenewalTests(SqlServerFixture fx) => _fx = fx;

    private RenewalTools Renewal => new(_fx.Read, new StubEmail(), _fx.Operator);

    [SkippableFact]
    public async Task GetRenewalQueue_ReturnsShape()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Renewal.GetRenewalQueue(daysAhead: 90);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("count", out _));
        Assert.True(doc.RootElement.TryGetProperty("urgentCount", out _));
        Assert.True(doc.RootElement.TryGetProperty("renewals", out var arr));
        Assert.Equal(JsonValueKind.Array, arr.ValueKind);
    }

    [SkippableFact]
    public async Task GetRenewalMetrics_ReturnsShape()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Renewal.GetRenewalMetrics(year: DateTime.UtcNow.Year);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("totalCount", out _));
        Assert.True(doc.RootElement.TryGetProperty("performanceLabel", out _));
    }

    [SkippableFact]
    public async Task SendRenewalNotices_DryRun_ReturnsCount()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Renewal.SendRenewalNotices(daysAhead: 90, dryRun: true);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("dryRun", out var dr) && dr.GetBoolean());
        Assert.True(doc.RootElement.TryGetProperty("total", out _));
    }
}

file sealed class StubEmail : IEmailService
{
    public Task<EmailSendResult> SendAsync(EmailMessage message, CancellationToken ct = default)
        => Task.FromResult(new EmailSendResult(true, $"stub_{Guid.NewGuid():N}", null));
}
