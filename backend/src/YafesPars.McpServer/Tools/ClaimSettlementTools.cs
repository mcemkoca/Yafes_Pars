using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class ClaimSettlementTools
{
    private readonly IReadRepository  _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext  _ctx;

    public ClaimSettlementTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read  = read;
        _write = write;
        _ctx   = ctx;
    }

    [McpServerTool, Description("Maak een schikkingsaanbod aan voor een schadedossier.")]
    public async Task<string> CreateSettlement(
        Guid    claimId,
        decimal offerAmountEur,
        string? iban  = null,
        string? notes = null,
        bool    dryRun = false)
    {
        var rows = await _read.QueryAsync<object>(
            "claim.SP_CreateSettlement",
            new
            {
                tenant_id        = _ctx.TenantId,
                claim_id         = claimId,
                offer_amount_eur = offerAmountEur,
                iban,
                notes,
                dry_run          = dryRun ? 1 : 0
            });

        return JsonSerializer.Serialize(rows);
    }

    [McpServerTool, Description("Keur een schikkingsaanbod goed en registreer de betaling.")]
    public async Task<string> ApproveSettlement(
        Guid    settlementId,
        Guid?   claimId              = null,
        decimal? agreedAmountEur     = null,
        string?  paymentReference    = null,
        string?  paymentMethodCode   = null)
    {
        var rows = await _read.QueryAsync<object>(
            "claim.SP_ApproveSettlement",
            new
            {
                tenant_id            = _ctx.TenantId,
                settlement_id        = settlementId,
                claim_id             = claimId,
                agreed_amount_eur    = agreedAmountEur,
                payment_reference    = paymentReference,
                payment_method_code  = paymentMethodCode
            });

        return JsonSerializer.Serialize(rows);
    }

    [McpServerTool, Description("Pas de reserve van een schadedossier handmatig aan.")]
    public async Task<string> UpdateClaimReserve(
        Guid    claimId,
        decimal newReserve,
        string  reasonCode = "MANUAL",
        string? notes      = null)
    {
        var rows = await _read.QueryAsync<object>(
            "claim.SP_UpdateClaimReserve",
            new
            {
                tenant_id   = _ctx.TenantId,
                claim_id    = claimId,
                new_reserve = newReserve,
                reason_code = reasonCode,
                notes
            });

        return JsonSerializer.Serialize(rows);
    }

    [McpServerTool, Description("Haal schikkingsoverzicht op per schadedossier (of alle dossiers van de tenant).")]
    public async Task<string> GetClaimSettlementSummary(Guid? claimId = null)
    {
        var rows = await _read.QueryAsync<object>(
            "claim.SP_GetClaimSettlementSummary",
            new { tenant_id = _ctx.TenantId, claim_id = claimId });

        return JsonSerializer.Serialize(rows);
    }

    [McpServerTool, Description("Haal reserve-wijzigingen op voor een schadedossier.")]
    public async Task<string> GetReserveLog(Guid claimId, int limit = 50)
    {
        var rows = await _read.QueryAsync<object>(
            "claim.SP_GetReserveLog",
            new { tenant_id = _ctx.TenantId, claim_id = claimId, limit });

        return JsonSerializer.Serialize(rows);
    }
}
