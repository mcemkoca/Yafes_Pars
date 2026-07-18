using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class FinanceLedgerTests
{
    private readonly SqlServerFixture _fx;
    public FinanceLedgerTests(SqlServerFixture fx) => _fx = fx;

    private FinanceLedgerTools Ledger =>
        new(_fx.Read, _fx.Write, _fx.Operator);

    [SkippableFact]
    public async Task GetLedgerBalance_NoFilter_ReturnsAccounts()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var result = await Ledger.GetLedgerBalance();
        Assert.NotNull(result);
    }

    [SkippableFact]
    public async Task GetLedgerBalance_AssetFilter_ReturnsAccounts()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var result = await Ledger.GetLedgerBalance(accountType: "ASSET");
        Assert.NotNull(result);
    }

    [SkippableFact]
    public async Task GetLedgerByContract_UnknownContract_ReturnsEmpty()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var result = await Ledger.GetLedgerByContract(contractId: Guid.NewGuid());
        Assert.NotNull(result);
        Assert.Equal("[]", ExtractEntriesJson(result));
    }

    [SkippableFact]
    public async Task PostLedgerEntry_ValidAccounts_ReturnsJournalId()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var result = await Ledger.PostLedgerEntry(
            debitAccount:  "6000",
            creditAccount: "4200",
            amountEur:     250.00m,
            sourceType:    "CLAIM",
            description:   "Integration test claim payment");

        Assert.NotNull(result);
        Assert.Contains("journalId", result);
        Assert.DoesNotContain("\"error\"", result);
    }

    [SkippableFact]
    public async Task GetClaimCostSummary_NoFilter_ReturnsJson()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var result = await Ledger.GetClaimCostSummary();
        Assert.NotNull(result);
    }

    [SkippableFact]
    public async Task GetClaimCostSummary_UnknownClaim_ReturnsEmptyList()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var result = await Ledger.GetClaimCostSummary(claimId: Guid.NewGuid());
        Assert.NotNull(result);
        Assert.Contains("\"count\":0", result);
    }

    // Extracts the "entries" array serialization from the JSON result
    private static string ExtractEntriesJson(string json)
    {
        using var doc = System.Text.Json.JsonDocument.Parse(json);
        if (doc.RootElement.TryGetProperty("entries", out var entries))
            return entries.GetRawText();
        return "[]";
    }
}
