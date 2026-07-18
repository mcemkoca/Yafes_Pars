using Microsoft.AspNetCore.Mvc;
using YafesPars.Infrastructure;

namespace YafesPars.Api.Endpoints;

public static class ClaimSettlementEndpoints
{
    public static void MapClaimSettlementEndpoints(this WebApplication app)
    {
        var grp = app.MapGroup("/api/claims/{claimId:guid}/settlements")
                     .RequireAuthorization()
                     .WithTags("ClaimSettlements");

        grp.MapGet("/", GetSettlementsAsync)
           .WithName("GetClaimSettlements");

        grp.MapPost("/", CreateSettlementAsync)
           .WithName("CreateSettlement")
           .RequireRateLimiting("write");

        grp.MapPost("/{settlementId:guid}/approve", ApproveSettlementAsync)
           .WithName("ApproveSettlement")
           .RequireRateLimiting("write");

        app.MapGet("/api/claims/{claimId:guid}/reserve-log", GetReserveLogAsync)
           .RequireAuthorization()
           .WithTags("ClaimSettlements")
           .WithName("GetReserveLog");

        app.MapPut("/api/claims/{claimId:guid}/reserve", UpdateReserveAsync)
           .RequireAuthorization()
           .RequireRateLimiting("write")
           .WithTags("ClaimSettlements")
           .WithName("UpdateClaimReserve");
    }

    private static async Task<IResult> GetSettlementsAsync(
        Guid claimId,
        IReadRepository read,
        OperatorContext ctx)
    {
        var rows = await read.QueryAsync<dynamic>(
            "claim.SP_GetClaimSettlementSummary",
            new { tenant_id = ctx.TenantId, claim_id = claimId });

        return Results.Ok(rows);
    }

    private static async Task<IResult> CreateSettlementAsync(
        Guid claimId,
        [FromBody] CreateSettlementRequest req,
        IWriteRepository write,
        OperatorContext ctx)
    {
        if (req.OfferAmountEur <= 0)
            return Results.BadRequest(new { error = "offer_amount_eur must be positive" });

        var result = await write.ExecuteScalarAsync<dynamic>(
            "claim.SP_CreateSettlement",
            new
            {
                tenant_id        = ctx.TenantId,
                claim_id         = claimId,
                offer_amount_eur = req.OfferAmountEur,
                iban             = req.Iban,
                notes            = req.Notes,
                dry_run          = 0
            });

        return Results.Ok(result);
    }

    private static async Task<IResult> ApproveSettlementAsync(
        Guid claimId,
        Guid settlementId,
        [FromBody] ApproveSettlementRequest req,
        IWriteRepository write,
        OperatorContext ctx)
    {
        var result = await write.ExecuteScalarAsync<dynamic>(
            "claim.SP_ApproveSettlement",
            new
            {
                tenant_id         = ctx.TenantId,
                settlement_id     = settlementId,
                agreed_amount_eur = req.AgreedAmountEur,
                payment_reference = req.PaymentReference
            });

        return Results.Ok(result);
    }

    private static async Task<IResult> GetReserveLogAsync(
        Guid claimId,
        IReadRepository read,
        OperatorContext ctx,
        [FromQuery] int limit = 50)
    {
        var rows = await read.QueryAsync<dynamic>(
            "claim.SP_GetReserveLog",
            new { tenant_id = ctx.TenantId, claim_id = claimId, limit });

        return Results.Ok(rows);
    }

    private static async Task<IResult> UpdateReserveAsync(
        Guid claimId,
        [FromBody] UpdateReserveRequest req,
        IWriteRepository write,
        OperatorContext ctx)
    {
        if (req.NewReserve < 0)
            return Results.BadRequest(new { error = "new_reserve cannot be negative" });

        var result = await write.ExecuteScalarAsync<dynamic>(
            "claim.SP_UpdateClaimReserve",
            new
            {
                tenant_id   = ctx.TenantId,
                claim_id    = claimId,
                new_reserve = req.NewReserve,
                reason_code = req.ReasonCode ?? "MANUAL",
                notes       = req.Notes
            });

        return Results.Ok(result);
    }

    private sealed record CreateSettlementRequest(
        decimal OfferAmountEur,
        string? Iban  = null,
        string? Notes = null);

    private sealed record ApproveSettlementRequest(
        decimal? AgreedAmountEur  = null,
        string?  PaymentReference = null);

    private sealed record UpdateReserveRequest(
        decimal NewReserve,
        string? ReasonCode = "MANUAL",
        string? Notes      = null);
}
