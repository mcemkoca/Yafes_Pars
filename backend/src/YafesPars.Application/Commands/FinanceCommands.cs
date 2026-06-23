namespace YafesPars.Application.Commands;

public sealed record CreateInvoiceCommand(
    Guid ContractId,
    DateOnly IssueDate,
    DateOnly DueDate,
    decimal Amount,
    string CurrencyCode
);

public sealed record RecordPaymentCommand(
    Guid InvoiceId,
    DateOnly PaymentDate,
    decimal Amount,
    string PaymentMethodCode
);

public sealed record CreatePaymentPlanCommand(
    Guid ContractId,
    int InstallmentCount,
    DateOnly FirstDueDate,
    decimal TotalAmount,
    string CurrencyCode
);
