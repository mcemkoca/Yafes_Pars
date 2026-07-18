using ModelContextProtocol.Server;
using YafesPars.Infrastructure;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class ClaimSettlementTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
{
    [McpServerTool(Name = "create_settlement", Description = "Maak een schikkingsaanbod aan voor een schadedossier.")]
    public async Task<object> CreateSettlement(
        Guid   claimId,
        decimal offerAmountEur,
        string? iban  = null,
        string? notes = null,
        bool   dryRun = false)
    {
        var rows = await write.ExecuteScalarAsync<IEnumerable<SettlementCreateResult>>(
            "claim.SP_CreateSettlement",
            new
            {
                tenant_id        = ctx.TenantId,
                claim_id         = claimId,
                offer_amount_eur = offerAmountEur,
                iban,
                notes,
                dry_run          = dryRun ? 1 : 0
            });

        return rows ?? new { error = "No result" };
    }

    [McpServerTool(Name = "approve_settlement", Description = "Keur een schikkingsaanbod goed en registreer de betaling.")]
    public async Task<object> ApproveSettlement(
        Guid    settlementId,
        decimal? agreedAmountEur    = null,
        string?  paymentReference   = null)
    {
        var rows = await write.ExecuteScalarAsync<IEnumerable<SettlementApproveResult>>(
            "claim.SP_ApproveSettlement",
            new
            {
                tenant_id         = ctx.TenantId,
                settlement_id     = settlementId,
                agreed_amount_eur = agreedAmountEur,
                payment_reference = paymentReference
            });

        return rows ?? new { error = "No result" };
    }

    [McpServerTool(Name = "update_claim_reserve", Description = "Pas de reserve van een schadedossier handmatig aan.")]
    public async Task<object> UpdateClaimReserve(
        Guid    claimId,
        decimal newReserve,
        string  reasonCode = "MANUAL",
        string? notes      = null)
    {
        var rows = await write.ExecuteScalarAsync<IEnumerable<ReserveUpdateResult>>(
            "claim.SP_UpdateClaimReserve",
            new
            {
                tenant_id   = ctx.TenantId,
                claim_id    = claimId,
                new_reserve = newReserve,
                reason_code = reasonCode,
                notes
            });

        return rows ?? new { error = "No result" };
    }

    [McpServerTool(Name = "get_claim_settlement_summary", Description = "Haal schikkingsoverzicht op per schadedossier (of alle dossiers van de tenant).")]
    public async Task<IEnumerable<SettlementSummaryRow>> GetClaimSettlementSummary(Guid? claimId = null)
    {
        return await read.QueryAsync<SettlementSummaryRow>(
            "claim.SP_GetClaimSettlementSummary",
            new { tenant_id = ctx.TenantId, claim_id = claimId });
    }

    [McpServerTool(Name = "get_reserve_log", Description = "Haal reserve-wijzigingen op voor een schadedossier.")]
    public async Task<IEnumerable<ReserveLogRow>> GetReserveLog(Guid claimId, int limit = 50)
    {
        return await read.QueryAsync<ReserveLogRow>(
            "claim.SP_GetReserveLog",
            new { tenant_id = ctx.TenantId, claim_id = claimId, limit });
    }

    private sealed record SettlementCreateResult
    {
        public Guid    ClaimId              { get; init; }
        public Guid    SettlementId         { get; init; }
        public decimal OfferAmountEur       { get; init; }
        public string  ClaimStatus          { get; init; } = string.Empty;
        public string  Result               { get; init; } = string.Empty;
    }

    private sealed record SettlementApproveResult
    {
        public Guid    SettlementId          { get; init; }
        public Guid    ClaimId               { get; init; }
        public decimal PaidAmount            { get; init; }
        public string  SettlementStatusCode  { get; init; } = string.Empty;
    }

    private sealed record ReserveUpdateResult
    {
        public Guid    ClaimId          { get; init; }
        public decimal PreviousReserve  { get; init; }
        public decimal NewReserve       { get; init; }
    }

    private sealed record SettlementSummaryRow
    {
        public Guid      ClaimId              { get; init; }
        public string    ClaimNumber          { get; init; } = string.Empty;
        public string    ClaimStatusCode      { get; init; } = string.Empty;
        public decimal?  ReservedAmount       { get; init; }
        public decimal?  PaidAmount           { get; init; }
        public Guid?     SettlementId         { get; init; }
        public string?   SettlementStatusCode { get; init; }
        public decimal?  OfferAmountEur       { get; init; }
        public decimal?  AgreedAmountEur      { get; init; }
        public DateTime? OfferedAtUtc         { get; init; }
        public DateTime? ApprovedAtUtc        { get; init; }
        public DateTime? PaidAtUtc            { get; init; }
        public string?   PaymentReference     { get; init; }
    }

    private sealed record ReserveLogRow
    {
        public Guid      ReserveLogId     { get; init; }
        public Guid      ClaimId          { get; init; }
        public decimal?  PreviousReserve  { get; init; }
        public decimal   NewReserve       { get; init; }
        public decimal   DeltaAmount      { get; init; }
        public string    ReasonCode       { get; init; } = string.Empty;
        public string?   Notes            { get; init; }
        public DateTime  ChangedAtUtc     { get; init; }
    }
}
