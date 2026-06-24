namespace YafesPars.Application.Commands;

public sealed record CreateRiskObjectCommand(
    string RiskObjectTypeCode,
    string? Description
);

public sealed record CreateVehicleRiskCommand(
    string PlateNumber,
    string? Brand,
    string? Model,
    int? ModelYear,
    string? ChassisNumber,
    string? EngineNumber,
    decimal? MarketValue,
    string CurrencyCode
);

public sealed record CreatePropertyRiskCommand(
    string? Address,
    string? PropertyTypeCode,
    decimal? ConstructionArea,
    int? ConstructionYear,
    decimal? InsuredValue,
    string CurrencyCode
);

public sealed record LinkRiskToContractCommand(
    Guid ContractId,
    Guid RiskObjectId
);
