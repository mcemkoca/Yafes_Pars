using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class FinanceTools
{
    private readonly IReadRepository _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public FinanceTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read = read;
        _write = write;
        _ctx = ctx;
    }

    [McpServerTool, Description("Bir poliçenin faturalarını listele.")]
    public async Task<string> GetInvoices(
        [Description("Poliçe ID'si (UUID)")] Guid contractId,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT InvoiceId, ContractId, IssueDate, DueDate,
                   Amount, CurrencyCode, StatusCode, CreatedAt
            FROM finance.Invoices
            WHERE TenantId = @tenantId AND ContractId = @contractId
            ORDER BY IssueDate DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql,
            new { tenantId = _ctx.TenantId, contractId }, ct);

        return rows.Count == 0
            ? "Bu poliçe için fatura bulunamadı."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }

    [McpServerTool, Description("Yeni fatura oluştur. Poliçe (contract_id), düzenleme tarihi, vade tarihi ve tutar gereklidir.")]
    public async Task<string> CreateInvoice(
        [Description("Poliçe ID'si (UUID)")] Guid contractId,
        [Description("Fatura düzenleme tarihi (yyyy-MM-dd)")] DateOnly issueDate,
        [Description("Vade tarihi (yyyy-MM-dd)")] DateOnly dueDate,
        [Description("Fatura tutarı")] decimal amount,
        [Description("Para birimi kodu (varsayılan: TRY)")] string currencyCode = "TRY",
        CancellationToken ct = default)
    {
        var sql = """
            DECLARE @id UNIQUEIDENTIFIER;
            EXEC finance.sp_CreateInvoice
                @tenant_id     = @tenantId,
                @contract_id   = @contractId,
                @issue_date    = @issueDate,
                @due_date      = @dueDate,
                @amount        = @amount,
                @currency_code = @currencyCode,
                @invoice_id    = @id OUTPUT;
            SELECT @id;
            """;

        var id = await _write.ExecuteScalarAsync<Guid>(sql,
            new { tenantId = _ctx.TenantId, contractId, issueDate, dueDate, amount, currencyCode }, ct);

        return $"Fatura oluşturuldu. InvoiceId: {id}";
    }

    [McpServerTool, Description("Fatura ödemesi kaydet.")]
    public async Task<string> RecordPayment(
        [Description("Fatura ID'si (UUID)")] Guid invoiceId,
        [Description("Ödeme tarihi (yyyy-MM-dd)")] DateOnly paymentDate,
        [Description("Ödeme tutarı")] decimal amount,
        [Description("Ödeme yöntemi: CASH, BANK_TRANSFER, CREDIT_CARD (varsayılan: BANK_TRANSFER)")] string paymentMethodCode = "BANK_TRANSFER",
        CancellationToken ct = default)
    {
        var sql = """
            DECLARE @id UNIQUEIDENTIFIER;
            EXEC finance.sp_RecordPayment
                @tenant_id           = @tenantId,
                @invoice_id          = @invoiceId,
                @payment_date        = @paymentDate,
                @amount              = @amount,
                @payment_method_code = @paymentMethodCode,
                @payment_id          = @id OUTPUT;
            SELECT @id;
            """;

        var id = await _write.ExecuteScalarAsync<Guid>(sql,
            new { tenantId = _ctx.TenantId, invoiceId, paymentDate, amount, paymentMethodCode }, ct);

        return $"Ödeme kaydedildi. PaymentId: {id}";
    }

    [McpServerTool, Description("Taksit planı oluştur. Toplam tutar eşit taksitlere bölünür.")]
    public async Task<string> CreatePaymentPlan(
        [Description("Poliçe ID'si (UUID)")] Guid contractId,
        [Description("Taksit sayısı (1-12)")] short installmentCount,
        [Description("İlk taksit tarihi (yyyy-MM-dd)")] DateOnly firstDueDate,
        [Description("Toplam prim tutarı")] decimal totalAmount,
        [Description("Para birimi kodu (varsayılan: TRY)")] string currencyCode = "TRY",
        CancellationToken ct = default)
    {
        var sql = """
            DECLARE @id UNIQUEIDENTIFIER;
            EXEC finance.sp_CreatePaymentPlan
                @tenant_id         = @tenantId,
                @contract_id       = @contractId,
                @installment_count = @installmentCount,
                @first_due_date    = @firstDueDate,
                @total_amount      = @totalAmount,
                @currency_code     = @currencyCode,
                @plan_id           = @id OUTPUT;
            SELECT @id;
            """;

        var id = await _write.ExecuteScalarAsync<Guid>(sql,
            new { tenantId = _ctx.TenantId, contractId, installmentCount, firstDueDate, totalAmount, currencyCode }, ct);

        return $"{installmentCount} taksitli plan oluşturuldu. PlanId: {id}";
    }
}
