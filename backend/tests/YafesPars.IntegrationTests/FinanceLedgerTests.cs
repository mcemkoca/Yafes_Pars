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
        Assert.DoesNotContain("\"error\"", result);

        // Verify Dapper mapping succeeds: journalId must be a non-empty GUID.
        // If snake_case aliases were missing, all GUID fields would silently map to Guid.Empty.
        using var doc = System.Text.Json.JsonDocument.Parse(result);
        var root = doc.RootElement;
        Assert.True(root.TryGetProperty("entries", out var entries), "Result must have 'entries' array");
        Assert.True(entries.GetArrayLength() == 2, "SP_PostLedgerEntry must return debit + credit lines");
        var first = entries[0];
        Assert.True(first.TryGetProperty("journalId", out var jid), "Entry must have journalId");
        Assert.NotEqual(Guid.Empty, jid.GetGuid());
        Assert.True(first.TryGetProperty("debitEur", out var deb) || first.TryGetProperty("creditEur", out _),
            "Entry must have debitEur or creditEur");
    }

    [SkippableFact]
    public async Task GetLedgerBalance_ReturnsNonEmptyAccounts()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var result = await Ledger.GetLedgerBalance();
        Assert.NotNull(result);

        using var doc = System.Text.Json.JsonDocument.Parse(result);
        var root = doc.RootElement;
        Assert.True(root.TryGetProperty("accounts", out var accounts), "Result must have 'accounts' array");
        Assert.True(accounts.GetArrayLength() > 0, "Chart of accounts must have at least one entry");
        var first = accounts[0];
        Assert.True(first.TryGetProperty("accountCode", out var code), "Balance row must have accountCode");
        Assert.False(string.IsNullOrEmpty(code.GetString()), "accountCode must not be empty");
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
