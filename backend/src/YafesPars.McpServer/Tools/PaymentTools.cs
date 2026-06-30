using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Mollie-betalingstools voor premie-invordering. Tenant-scoped.
/// Ondersteunt iDEAL, Bancontact, SEPA, creditcard via Mollie REST API v2.
/// </summary>
[McpServerToolType]
public sealed class PaymentTools
{
    private readonly IReadRepository _read;
    private readonly IWriteRepository _write;
    private readonly IMolliePaymentService _mollie;
    private readonly OperatorContext _ctx;

    public PaymentTools(IReadRepository read, IWriteRepository write,
        IMolliePaymentService mollie, OperatorContext ctx)
    {
        _read   = read;
        _write  = write;
        _mollie = mollie;
        _ctx    = ctx;
    }

    [McpServerTool, Description(
        "Maak een Mollie-betalingslink aan voor een factuur. / Bir fatura için Mollie ödeme bağlantısı oluştur.\n" +
        "Retourneert de checkout-URL die naar de klant gestuurd kan worden.\n" +
        "Wanneer MOLLIE_API_KEY ontbreekt, wordt een stub-URL teruggegeven (development).")]
    public async Task<string> CreatePaymentLink(
        [Description("Factuur-ID (GUID) waarvoor betaald wordt.")] Guid invoiceId,
        [Description("Beschrijving op de betaalpagina (optioneel).")] string? description = null,
        [Description("Return-URL na betaling (optioneel, default 'https://app.yafespars.be/betaling/terugkeer').")] string? returnUrl = null,
        [Description("Webhook-URL voor Mollie-callbacks (optioneel).")] string? webhookUrl = null,
        CancellationToken cancellationToken = default)
    {
        // Haal het te betalen bedrag op uit de factuur.
        var rows = await _read.QueryAsync<InvoiceAmountRow>(
            """
            SELECT TOP 1
                TotalAmountEur,
                StatusCode
            FROM finance.Invoices
            WHERE invoice_id = @invoiceId
              AND tenant_id  = @tenantId
              AND is_deleted = 0
            """,
            new { invoiceId, tenantId = _ctx.TenantId },
            cancellationToken);
        var row = rows.FirstOrDefault();

        if (row is null)
            return JsonSerializer.Serialize(new { error = "Factuur niet gevonden." });

        if (row.StatusCode == "PAID")
            return JsonSerializer.Serialize(new { error = "Factuur is al betaald." });

        var desc     = description ?? $"Verzekeringspremie factuur {invoiceId:N}";
        var redirect = returnUrl   ?? "https://app.yafespars.be/betaling/terugkeer";
        var webhook  = webhookUrl  ?? "https://app.yafespars.be/api/payments/webhook";

        // Sla transactierecord op in DB.
        var result = await _write.ExecuteScalarAsync<Guid>(
            "finance.SP_CreatePaymentTransaction",
            new
            {
                tenant_id   = _ctx.TenantId,
                invoice_id  = invoiceId,
                amount_eur  = row.TotalAmountEur,
                description = desc,
                return_url  = redirect,
                webhook_url = webhook,
            },
            cancellationToken);

        // Roep Mollie API aan.
        MolliePaymentResult mollieResult;
        try
        {
            mollieResult = await _mollie.CreatePaymentAsync(
                row.TotalAmountEur, desc, redirect, webhook, cancellationToken);
        }
        catch (Exception ex)
        {
            return JsonSerializer.Serialize(new
            {
                error       = "Mollie API fout.",
                detail      = ex.Message,
                transactionId = result,
            });
        }

        // Update transactie met Mollie-ID en checkout-URL.
        await _write.ExecuteAsync(
            "finance.SP_UpdatePaymentStatus",
            new
            {
                tenant_id            = _ctx.TenantId,
                transaction_id       = result,
                mollie_payment_id    = (string?)null,
                status_code          = "PENDING",
                mollie_payment_id_set = mollieResult.MolliePaymentId,
                checkout_url         = mollieResult.CheckoutUrl,
            },
            cancellationToken);

        return JsonSerializer.Serialize(new
        {
            transactionId  = result,
            molliePaymentId = mollieResult.MolliePaymentId,
            checkoutUrl    = mollieResult.CheckoutUrl,
            amountEur      = row.TotalAmountEur,
            status         = mollieResult.Status,
        });
    }

    [McpServerTool, Description(
        "Lijst betalingstransacties voor een factuur of tenant. / Bir fatura veya tenant için ödeme işlemlerini listele.")]
    public async Task<string> GetPaymentTransactions(
        [Description("Filter op factuur-ID (optioneel).")] Guid? invoiceId = null,
        [Description("Filter op status: PENDING, PAID, FAILED, CANCELLED, EXPIRED (optioneel).")] string? statusCode = null,
        [Description("Maximum aantal resultaten (standaard 50).")] int limit = 50,
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<PaymentTransactionRow>(
            """
            SELECT TOP (@limit)
                transaction_id      AS TransactionId,
                invoice_id          AS InvoiceId,
                mollie_payment_id   AS MolliePaymentId,
                mollie_checkout_url AS CheckoutUrl,
                amount_eur          AS AmountEur,
                status_code         AS StatusCode,
                payment_method      AS PaymentMethod,
                created_at_utc      AS CreatedAtUtc,
                paid_at_utc         AS PaidAtUtc
            FROM finance.PaymentTransaction
            WHERE tenant_id = @tenantId
              AND is_deleted = 0
              AND (@invoiceId  IS NULL OR invoice_id  = @invoiceId)
              AND (@statusCode IS NULL OR status_code = @statusCode)
            ORDER BY created_at_utc DESC
            """,
            new
            {
                tenantId   = _ctx.TenantId,
                invoiceId,
                statusCode,
                limit      = Math.Clamp(limit, 1, 200),
            },
            cancellationToken);

        return JsonSerializer.Serialize(rows);
    }

    [McpServerTool, Description(
        "Werk betalingsstatus bij op basis van Mollie-ID (voor webhooks of handmatige controle). / Mollie ID'ye göre ödeme durumunu güncelle.")]
    public async Task<string> UpdatePaymentStatus(
        [Description("Mollie-betaling-ID (tr_xxxx).")] string molliePaymentId,
        [Description("Nieuwe status: PAID, FAILED, CANCELLED of EXPIRED.")] string statusCode,
        CancellationToken cancellationToken = default)
    {
        await _write.ExecuteAsync(
            "finance.SP_UpdatePaymentStatus",
            new
            {
                tenant_id            = _ctx.TenantId,
                transaction_id       = (Guid?)null,
                mollie_payment_id    = molliePaymentId,
                status_code          = statusCode,
                mollie_payment_id_set = (string?)null,
                checkout_url         = (string?)null,
            },
            cancellationToken);

        return JsonSerializer.Serialize(new { updated = true, molliePaymentId, statusCode });
    }

    private sealed record InvoiceAmountRow(decimal TotalAmountEur, string StatusCode);

    private sealed record PaymentTransactionRow(
        Guid    TransactionId,
        Guid    InvoiceId,
        string? MolliePaymentId,
        string? CheckoutUrl,
        decimal AmountEur,
        string  StatusCode,
        string? PaymentMethod,
        DateTime CreatedAtUtc,
        DateTime? PaidAtUtc);
}
