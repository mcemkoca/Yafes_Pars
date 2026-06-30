namespace YafesPars.Application.ReadModels;

public sealed class CustomerSummary
{
    public Guid TenantId { get; init; }
    public Guid PersonId { get; init; }
    public string PersonKind { get; init; } = "";
    public string? Dossier { get; init; }
    public string? FirstName { get; init; }
    public string? LastName { get; init; }
    public string? LegalForm { get; init; }
    public string? PrimaryEmail { get; init; }
    public string? PrimaryPhone { get; init; }
    public DateTime CreatedAtUtc { get; init; }
    public DateTime UpdatedAtUtc { get; init; }
}

public sealed class InstitutionSummary
{
    public Guid TenantId { get; init; }
    public Guid InstitutionId { get; init; }
    public string InstitutionCode { get; init; } = "";
    public string Name { get; init; } = "";
    public string? LegalName { get; init; }
    public string? VatNumber { get; init; }
    public string? City { get; init; }
    public string? CountryCode { get; init; }
    public bool IsActive { get; init; }
}

public sealed class RiskSummary
{
    public Guid TenantId { get; init; }
    public Guid InsurableObjectId { get; init; }
    public string ObjectTypeCode { get; init; } = "";
    public string Description { get; init; } = "";
    public string StatusCode { get; init; } = "";
    public string? LicensePlate { get; init; }
    public string? ChassisNumber { get; init; }
    public string? Brand { get; init; }
    public string? Model { get; init; }
    public string? City { get; init; }
}

public sealed class PolicySummary
{
    public Guid TenantId { get; init; }
    public Guid ContractId { get; init; }
    public string ContractNumber { get; init; } = "";
    public string ContractStatusCode { get; init; } = "";
    public string ContractDomainCode { get; init; } = "";
    public string ContractTypeCode { get; init; } = "";
    public DateOnly StartDate { get; init; }
    public DateOnly? EndDate { get; init; }
    public string? CompanyName { get; init; }
    public int? LatestVersionNo { get; init; }
    public long PartyCount { get; init; }
    public long ObjectCount { get; init; }
}

public sealed class ClaimSummary
{
    public Guid TenantId { get; init; }
    public Guid ClaimId { get; init; }
    public string ClaimNumber { get; init; } = "";
    public Guid ContractId { get; init; }
    public string ContractNumber { get; init; } = "";
    public string? CoverageCode { get; init; }
    public string ClaimStatusCode { get; init; } = "";
    public DateOnly? IncidentDate { get; init; }
    public DateOnly ReportedDate { get; init; }
    public DateOnly? ClosedDate { get; init; }
    public decimal? PaidAmount { get; init; }
    public decimal? ReservedAmount { get; init; }
}

public sealed class TaskSummary
{
    public Guid TenantId { get; init; }
    public Guid TaskId { get; init; }
    public string Title { get; init; } = "";
    public string? RelatedEntityType { get; init; }
    public Guid? RelatedEntityId { get; init; }
    public Guid? AssignedToUserId { get; init; }
    public string? AssignedToName { get; init; }
    public string TaskPriorityCode { get; init; } = "";
    public string TaskStatusCode { get; init; } = "";
    public DateTime? DueAtUtc { get; init; }
}

public sealed class CoverageSummary
{
    public string CoverageCode { get; init; } = "";
    public string LabelNl { get; init; } = "";
    public string? LabelFr { get; init; }
    public string? LabelEn { get; init; }
    public string? LabelTr { get; init; }
    public string? Description { get; init; }
}

public sealed class CommissionRow
{
    public Guid CommissionId { get; init; }
    public DateOnly CommissionDate { get; init; }
    public string CommissionTypeCode { get; init; } = "";
    public string StatusCode { get; init; } = "";
    public Guid ContractId { get; init; }
    public Guid? BrokerPersonId { get; init; }
    public Guid? BrokerInstitutionId { get; init; }
    public decimal GrossPremiumEur { get; init; }
    public decimal RatePct { get; init; }
    public decimal CommissionEur { get; init; }
    public DateOnly? PaidDate { get; init; }
    public string? Notes { get; init; }
}

public sealed class CommissionReportRow
{
    public DateOnly CommissionDate { get; init; }
    public string CommissionTypeCode { get; init; } = "";
    public string StatusCode { get; init; } = "";
    public string? ContractNumber { get; init; }
    public string? Tak { get; init; }
    public string? Productcode { get; init; }
    public string? BrokerNaam { get; init; }
    public string? BrokerKantoor { get; init; }
    public decimal GrossPremiumEur { get; init; }
    public decimal RatePct { get; init; }
    public decimal CommissionEur { get; init; }
    public DateOnly? PaidDate { get; init; }
}

public sealed class PortfolioRow
{
    public string Tak { get; init; } = "";
    public string Status { get; init; } = "";
    public int ContractCount { get; init; }
    public decimal TotaalPremieEur { get; init; }
    public int TotaalSchaden { get; init; }
    public decimal TotaalGereserveerdEur { get; init; }
    public decimal TotaalBetaaldEur { get; init; }
    public decimal? LossRatio { get; init; }
}

public sealed class ImportBatchRow
{
    public int RowNumber { get; init; }
    public string? ContractNumber { get; init; }
    public string? ContractDomainCode { get; init; }
    public string? StartDate { get; init; }
    public string ValidationStatus { get; init; } = "";
    public string? ValidationErrors { get; init; }
}

public sealed class AuditLogRow
{
    public long AuditLogId { get; init; }
    public string SchemaName { get; init; } = "";
    public string TableName { get; init; } = "";
    public string PrimaryKeyValue { get; init; } = "";
    public string ActionType { get; init; } = "";
    public DateTime ChangedAtUtc { get; init; }
    public string? ChangedByName { get; init; }
    public Guid? ChangedByUserId { get; init; }
    public string? SourceSystem { get; init; }
}
