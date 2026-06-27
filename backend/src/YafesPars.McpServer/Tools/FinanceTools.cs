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

    [McpServerTool, Description("Lijst de facturen van een polis. / Bir poliçenin faturalarını listele.")]
    public async Task<string> GetInvoices(
        [Description("Polis-ID (UUID)")] Guid contractId,
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

    [McpServerTool, Description("Maak een nieuwe factuur. / Yeni fatura oluştur. Polis, datums en bedrag verplicht.")]
    public async Task<string> CreateInvoice(
        [Description("Polis-ID (UUID)")] Guid contractId,
        [Description("Factuurdatum (yyyy-MM-dd) / Düzenleme tarihi")] DateOnly issueDate,
        [Description("Vervaldatum (yyyy-MM-dd) / Vade tarihi")] DateOnly dueDate,
        [Description("Bedrag / Tutar")] decimal amount,
        [Description("Para birimi kodu (varsayılan: EUR)")] string currencyCode = "EUR",
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

    [McpServerTool, Description("Registreer een betaling op een factuur. / Fatura ödemesi kaydet.")]
    public async Task<string> RecordPayment(
        [Description("Factuur-ID (UUID)")] Guid invoiceId,
        [Description("Betaaldatum (yyyy-MM-dd) / Ödeme tarihi")] DateOnly paymentDate,
        [Description("Bedrag / Tutar")] decimal amount,
        [Description("Betaalwijze: CASH, BANK_TRANSFER, CREDIT_CARD (standaard: BANK_TRANSFER)")] string paymentMethodCode = "BANK_TRANSFER",
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

    [McpServerTool, Description("Maak een afbetalingsplan. / Taksit planı oluştur. Totaal wordt gelijk verdeeld.")]
    public async Task<string> CreatePaymentPlan(
        [Description("Polis-ID (UUID)")] Guid contractId,
        [Description("Aantal termijnen (1-12) / Taksit sayısı")] short installmentCount,
        [Description("Eerste vervaldatum (yyyy-MM-dd) / İlk taksit tarihi")] DateOnly firstDueDate,
        [Description("Totaalbedrag / Toplam tutar")] decimal totalAmount,
        [Description("Para birimi kodu (varsayılan: EUR)")] string currencyCode = "EUR",
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
