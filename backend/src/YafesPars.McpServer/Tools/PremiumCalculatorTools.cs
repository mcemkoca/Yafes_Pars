using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Belçika sigorta prim hesaplama motoru.
/// finance.TariffRate tablosundaki baz oranlardan coverage item bazlı prim hesaplar.
/// </summary>
[McpServerToolType]
public sealed class PremiumCalculatorTools
{
    private readonly IReadRepository  _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext  _ctx;

    public PremiumCalculatorTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read  = read;
        _write = write;
        _ctx   = ctx;
    }

    [McpServerTool, Description(
        "Sözleşme için coverage item bazlı prim hesapla. / Premieberekening per dekkingspost.\n" +
        "Her coverage item için baz oran, minimum prim ve hesaplanan prim döner.\n" +
        "Tarife kaydı olmayan coverage'lar Status=NO_TARIFF olarak işaretlenir.")]
    public async Task<string> CalculatePremium(
        [Description("Sözleşme UUID'i")] Guid contractId,
        [Description("Referans tarihi (boş = bugün)")] string? referenceDate = null,
        CancellationToken ct = default)
    {
        DateOnly? refDate = null;
        if (!string.IsNullOrWhiteSpace(referenceDate) && DateOnly.TryParse(referenceDate, out var d))
            refDate = d;

        var rows = await _read.QueryAsync<PremiumRow>(
            "finance.SP_CalculatePremium",
            new
            {
                tenant_id      = _ctx.TenantId,
                contract_id    = contractId,
                reference_date = refDate?.ToDateTime(TimeOnly.MinValue)
            }, ct);

        var noTariff = rows.Count(r => r.Status == "NO_TARIFF");
        var total    = rows.Sum(r => r.CalculatedPremium);

        return JsonSerializer.Serialize(new
        {
            contractId,
            coverageCount   = rows.Count,
            noTariffCount   = noTariff,
            totalAnnualEur  = Math.Round(total, 2),
            monthlyEur      = Math.Round(total / 12, 2),
            items           = rows
        });
    }

    [McpServerTool, Description(
        "Sözleşme prim özeti (tek satır). / Premieoverzicht ophalen.\n" +
        "Toplam yıllık ve aylık prim, coverage sayısı ve tarife eksik coverage sayısı.")]
    public async Task<string> GetPremiumSummary(
        [Description("Sözleşme UUID'i")] Guid contractId,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<SummaryRow>(
            "finance.SP_GetPremiumSummary",
            new { tenant_id = _ctx.TenantId, contract_id = contractId }, ct);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "Sözleşme bulunamadı veya coverage yok." });

        return JsonSerializer.Serialize(row);
    }

    [McpServerTool, Description(
        "Tarife oranlarını listele. / Tariefpercentages ophalen.\n" +
        "coverageDomainCode boş bırakılırsa tüm domain'ler döner.")]
    public async Task<string> GetTariffRates(
        [Description("Coverage domain kodu filtresi (boş = tümü)")] string? coverageDomainCode = null,
        [Description("Pasif tarifeleri de dahil et")] bool includeInactive = false,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<TariffRow>(
            "finance.SP_GetTariffRates",
            new
            {
                tenant_id            = _ctx.TenantId,
                coverage_domain_code = string.IsNullOrWhiteSpace(coverageDomainCode) ? null : coverageDomainCode,
                include_inactive     = includeInactive
            }, ct);

        return JsonSerializer.Serialize(new { count = rows.Count, tariffs = rows });
    }

    [McpServerTool, Description(
        "Tarife oranı ekle/güncelle (Admin). / Tariefpercentage instellen.\n" +
        "baseRatePct: sigortalı değer üzerinden yıllık prim oranı (örn. 0.85 = %0.85).\n" +
        "coverageTypeCode '*' → domain içindeki tüm tipler için geçerli varsayılan.")]
    public async Task<string> UpsertTariffRate(
        [Description("Coverage domain kodu (örn. AUTO, FIRE, LIFE)")] string coverageDomainCode,
        [Description("Yıllık baz prim oranı % olarak (örn. 0.85)")] decimal baseRatePct,
        [Description("Coverage type kodu ('*' = tüm tipler)")] string coverageTypeCode = "*",
        [Description("Minimum prim (EUR)")] decimal minPremiumEur = 0,
        [Description("Maximum prim (EUR, boş = sınırsız)")] decimal? maxPremiumEur = null,
        [Description("Genç sürücü faktörü (örn. 1.3 = %30 artış)")] decimal ageFactorYoung = 1.0m,
        [Description("Kıdemli sürücü faktörü")] decimal ageFactorSenior = 1.0m,
        [Description("Hasarsızlık indirimi (örn. 0.05 = %5)")] decimal noClaimDiscount = 0.0m,
        [Description("Geçerlilik başlangıcı (boş = bugün)")] string? effectiveFrom = null,
        CancellationToken ct = default)
    {
        DateOnly? effFrom = null;
        if (!string.IsNullOrWhiteSpace(effectiveFrom) && DateOnly.TryParse(effectiveFrom, out var d))
            effFrom = d;

        var rows = await _read.QueryAsync<TariffRow>(
            "finance.SP_UpsertTariffRate",
            new
            {
                tenant_id            = _ctx.TenantId,
                coverage_domain_code = coverageDomainCode.ToUpperInvariant(),
                coverage_type_code   = coverageTypeCode,
                base_rate_pct        = baseRatePct,
                min_premium_eur      = minPremiumEur,
                max_premium_eur      = maxPremiumEur,
                age_factor_young     = ageFactorYoung,
                age_factor_senior    = ageFactorSenior,
                no_claim_discount    = noClaimDiscount,
                effective_from       = effFrom?.ToDateTime(TimeOnly.MinValue)
            }, ct);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "Tarife kaydedilemedi." });

        return JsonSerializer.Serialize(new { success = true, tariff = row });
    }

    // -------------------------------------------------------------------------
    private sealed record PremiumRow(
        Guid     CoverageItemId,
        string   CoverageTypeCode,
        decimal  InsuredValue,
        decimal? BaseRatePct,
        decimal? MinPremiumEur,
        decimal? MaxPremiumEur,
        decimal  CalculatedPremium,
        string   Status);

    private sealed record SummaryRow
    {
        public Guid     ContractId           { get; init; }
        public int      CoverageCount        { get; init; }
        public int      MissingTariffCount   { get; init; }
        public decimal  TotalAnnualPremiumEur { get; init; }
        public decimal  MonthlyPremiumEur    { get; init; }
        public DateOnly CalculatedAt         { get; init; }
    }

    private sealed record TariffRow(
        Guid     TariffRateId,
        string   CoverageDomainCode,
        string   CoverageTypeCode,
        decimal  BaseRatePct,
        decimal  MinPremiumEur,
        decimal? MaxPremiumEur,
        DateOnly EffectiveFrom,
        bool     IsActive);
}
