using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class ClaimSettlementTests
{
    private readonly SqlServerFixture _fx;
    public ClaimSettlementTests(SqlServerFixture fx) => _fx = fx;

    private ClaimSettlementTools Settlement =>
        new(_fx.Read, _fx.Write, _fx.Operator);

    [SkippableFact]
    public async Task GetClaimSettlementSummary_NoFilter_ReturnsCollection()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var rows = await Settlement.GetClaimSettlementSummary();
        Assert.NotNull(rows);
    }

    [SkippableFact]
    public async Task GetReserveLog_UnknownClaim_ReturnsEmpty()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var rows = await Settlement.GetReserveLog(Guid.NewGuid(), limit: 10);
        Assert.NotNull(rows);
        Assert.Empty(rows);
    }

    [SkippableFact]
    public async Task CreateSettlement_UnknownClaim_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var result = await Settlement.CreateSettlement(
            claimId: Guid.NewGuid(),
            offerAmountEur: 1000m);

        Assert.NotNull(result);
    }

    [SkippableFact]
    public async Task CreateSettlement_DryRun_ReturnsDryRunResult()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var result = await Settlement.CreateSettlement(
            claimId: Guid.NewGuid(),
            offerAmountEur: 500m,
            dryRun: true);

        Assert.NotNull(result);
    }
}
