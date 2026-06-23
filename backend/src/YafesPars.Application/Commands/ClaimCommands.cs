namespace YafesPars.Application.Commands;

public sealed record CreateClaimCommand(
    Guid ContractId,
    string? CoverageCode,
    DateOnly IncidentDate,
    DateOnly ReportedDate,
    string? Description,
    decimal? ReservedAmount
);

public sealed record CloseClaimCommand(
    Guid ClaimId,
    decimal? PaidAmount,
    string? CloseReason
);
