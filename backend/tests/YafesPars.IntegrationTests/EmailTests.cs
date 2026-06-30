using System.Text.Json;
using Xunit;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class EmailTests
{
    private readonly SqlServerFixture _fx;
    public EmailTests(SqlServerFixture fx) => _fx = fx;

    private EmailTools Emails =>
        new(_fx.Read, _fx.Write, new StubEmailService(), _fx.Operator);

    [SkippableFact]
    public async Task GetEmailLog_ReturnsJsonArray()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Emails.GetEmailLog(limit: 10);
        using var doc = JsonDocument.Parse(res);
        Assert.Equal(JsonValueKind.Array, doc.RootElement.ValueKind);
    }

    [SkippableFact]
    public async Task SendOverdueReminders_DryRun_ReturnsCount()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Emails.SendOverdueReminders(limit: 5, dryRun: true);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("wouldSend", out _) ||
                    doc.RootElement.TryGetProperty("message",   out _),
            "Dry-run moet 'wouldSend' of 'message' teruggeven.");
    }

    [SkippableFact]
    public async Task SendPaymentConfirmation_UnknownInvoice_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Emails.SendPaymentConfirmation(Guid.NewGuid());
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("error", out _),
            "Onbekende factuur moet een foutbericht opleveren.");
    }

    [SkippableFact]
    public async Task SendRenewalNotice_UnknownContract_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Emails.SendRenewalNotice(Guid.NewGuid());
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("error", out _),
            "Onbekend contract moet een foutbericht opleveren.");
    }
}

/// <summary>Stub: geen echte e-mails in integratietests.</summary>
file sealed class StubEmailService : IEmailService
{
    public Task<EmailSendResult> SendAsync(EmailMessage message, CancellationToken ct = default)
        => Task.FromResult(new EmailSendResult(true, $"stub_{Guid.NewGuid():N}", null));
}
