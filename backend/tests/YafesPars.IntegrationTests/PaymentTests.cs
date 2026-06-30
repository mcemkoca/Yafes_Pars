using System.Text.Json;
using Xunit;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class PaymentTests
{
    private readonly SqlServerFixture _fx;
    public PaymentTests(SqlServerFixture fx) => _fx = fx;

    private PaymentTools Payments =>
        new(_fx.Read, _fx.Write, new StubMollieService(), _fx.Operator);

    [SkippableFact]
    public async Task GetPaymentTransactions_RunsWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Payments.GetPaymentTransactions(limit: 10);
        Assert.DoesNotContain("error", res.ToLower());
        // Resultaat moet een JSON-array zijn.
        using var doc = JsonDocument.Parse(res);
        Assert.Equal(JsonValueKind.Array, doc.RootElement.ValueKind);
    }

    [SkippableFact]
    public async Task CreatePaymentLink_UnknownInvoice_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Payments.CreatePaymentLink(invoiceId: Guid.NewGuid());
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("error", out _),
            "Verwacht foutbericht voor onbekende factuur.");
    }

    [SkippableFact]
    public async Task UpdatePaymentStatus_InvalidMollieId_ThrowsOrReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        // Een niet-bestaand Mollie-ID moet een fout opleveren uit SP_UpdatePaymentStatus.
        await Assert.ThrowsAnyAsync<Exception>(() =>
            Payments.UpdatePaymentStatus("tr_nonexistent", "PAID"));
    }
}

/// <summary>Stub: geen echte Mollie-aanroepen in integratietests.</summary>
file sealed class StubMollieService : IMolliePaymentService
{
    public Task<MolliePaymentResult> CreatePaymentAsync(
        decimal amountEur, string description, string returnUrl, string webhookUrl,
        CancellationToken cancellationToken = default)
        => Task.FromResult(new MolliePaymentResult(
            $"tr_stub_{Guid.NewGuid():N}",
            $"{returnUrl}?stub=1",
            "open"));

    public Task<string> GetPaymentStatusAsync(string molliePaymentId, CancellationToken cancellationToken = default)
        => Task.FromResult("open");
}
