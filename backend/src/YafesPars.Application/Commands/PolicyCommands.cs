namespace YafesPars.Application.Commands;

public sealed record CreateContractCommand(
    string ContractDomainCode,
    string ContractTypeCode,
    DateOnly StartDate,
    DateOnly? EndDate,
    string? InsurerInstitutionCode
);

public sealed record AddContractPartyCommand(
    Guid ContractId,
    Guid PersonId,
    string RoleCode
);

public sealed record AddContractObjectCommand(
    Guid ContractId,
    Guid InsurableObjectId
);
