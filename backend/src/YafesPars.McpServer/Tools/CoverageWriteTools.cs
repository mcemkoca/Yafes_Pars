using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class CoverageWriteTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public CoverageWriteTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx  = ctx;
    }

    [McpServerTool, Description(
        "Premie instellen voor een dekkingsitem. / Bir teminat kalemi için prim belirle.\n" +
        "Schrijft bruto premie, belasting en commissie naar coverage.ContractCoverageItem.\n" +
        "effectiveDate leeg = vandaag.")]
    public async Task<string> SetPremium(
        [Description("Teminat kalemi UUID")] Guid coverageItemId,
        [Description("Bruto prim (EUR, > 0)")] decimal grossPremium,
        [Description("Belastingbedrag (EUR, optioneel)")] decimal? taxAmount = null,
        [Description("Commissiebedrag (EUR, optioneel)")] decimal? commissionAmount = null,
        [Description("Ingangsdatum (ISO: yyyy-MM-dd, leeg = vandaag)")] string? effectiveDate = null,
        CancellationToken ct = default)
    {
        DateOnly? effDate = null;
        if (!string.IsNullOrWhiteSpace(effectiveDate) && DateOnly.TryParse(effectiveDate, out var d))
            effDate = d;

        var rows = await _read.QueryAsync<PremiumResultRow>(
            "coverage.sp_SetPremium",
            new
            {
                tenant_id          = _ctx.TenantId,
                coverage_item_id   = coverageItemId,
                gross_premium      = grossPremium,
                tax_amount         = taxAmount,
                commission_amount  = commissionAmount,
                effective_date     = effDate?.ToDateTime(TimeOnly.MinValue)
            }, ct);

        return JsonSerializer.Serialize(new { success = true, result = rows.FirstOrDefault() }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Dekking updaten: limiet en eigen risico wijzigen. / Teminat limitini ve muafiyeti güncelle.\n" +
        "coverageLimit en deductible worden meteen geldig na opslaan.")]
    public async Task<string> UpdateCoverage(
        [Description("Teminat kalemi UUID")] Guid coverageItemId,
        [Description("Yeni teminat limiti (EUR)")] decimal coverageLimit,
        [Description("Yeni muafiyet (EUR, isteğe bağlı)")] decimal? deductible = null,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<CoverageUpdateRow>(
            "coverage.sp_UpdateCoverage",
            new
            {
                tenant_id        = _ctx.TenantId,
                coverage_item_id = coverageItemId,
                coverage_limit   = coverageLimit,
                deductible
            }, ct);

        return JsonSerializer.Serialize(new { success = true, result = rows.FirstOrDefault() }, JsonOpts.Default);
    }

    // -------------------------------------------------------------------------
    private sealed record PremiumResultRow(
        Guid     CoverageItemId,
        decimal  GrossPremium,
        decimal? TaxAmount,
        decimal? CommissionAmount,
        DateOnly EffectiveDate);

    private sealed record CoverageUpdateRow(
        Guid    CoverageItemId,
        decimal CoverageLimit,
        decimal? Deductible,
        DateTime UpdatedAtUtc);
}
