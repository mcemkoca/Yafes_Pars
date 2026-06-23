namespace YafesPars.Application.Commands;

public sealed record AddCoverageItemCommand(
    Guid ContractId,
    string CoverageTypeCode,
    decimal CoverageLimit,
    decimal? Deductible,
    string CurrencyCode
);

public sealed record SetPremiumCommand(
    Guid CoverageItemId,
    decimal GrossPremium,
    decimal? TaxAmount,
    decimal? CommissionAmount,
    DateOnly EffectiveDate
);

public sealed record UpdateCoverageCommand(
    Guid CoverageItemId,
    decimal CoverageLimit,
    decimal? Deductible
);
