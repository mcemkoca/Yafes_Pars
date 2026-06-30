using System.Security.Claims;
using System.Text.Json;
using YafesPars.Application.Abstractions;
using YafesPars.Application.ReadModels;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class PaymentEndpoints
{
    public static IEndpointRouteBuilder MapPaymentEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/payments")
            .WithTags("Payments");

        // Authenticated endpoints
        var auth = api.MapGroup("")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("tenant");

        auth.MapGet("", ListPaymentsAsync);
        auth.MapPost("", CreatePaymentAsync)
            .RequireRateLimiting("write");

        // Mollie webhook: geen JWT-auth (Mollie-server stuurt dit).
        // Mollie stuurt application/x-www-form-urlencoded met 'id' parameter.
        api.MapPost("/webhook", HandleWebhookAsync)
            .Accepts<IFormCollection>("application/x-www-form-urlencoded")
            .DisableAntiforgery();

        return app;
    }

    private static async Task<IResult> ListPaymentsAsync(
        ClaimsPrincipal user,
        Guid? invoiceId,
        string? status,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var limit    = Math.Clamp(take.GetValueOrDefault(50), 1, 200);

        var rows = await repository.QueryAsync<PaymentTransactionRow>(
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
              AND (@invoiceId IS NULL OR invoice_id  = @invoiceId)
              AND (@status    IS NULL OR status_code = @status)
            ORDER BY created_at_utc DESC
            """,
            new { tenantId, invoiceId, status, limit },
            cancellationToken);

        return Results.Ok(rows);
    }

    private sealed record CreatePaymentRequest(
        Guid    InvoiceId,
        string? Description,
        string? ReturnUrl,
        string? WebhookUrl);

    private static async Task<IResult> CreatePaymentAsync(
        ClaimsPrincipal user,
        CreatePaymentRequest body,
        IReadRepository read,
        IWriteRepository write,
        IMolliePaymentService mollie,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        // Haal factuurbedrag op.
        var invoices = await read.QueryAsync<InvoiceRow>(
            """
            SELECT TOP 1
                Amount     AS TotalAmountEur,
                StatusCode
            FROM finance.Invoices
            WHERE InvoiceId = @invoiceId AND TenantId = @tenantId
            """,
            new { invoiceId = body.InvoiceId, tenantId },
            cancellationToken);
        var invoice = invoices.FirstOrDefault();

        if (invoice is null)
            return Results.NotFound(new { error = "Factuur niet gevonden." });

        if (invoice.StatusCode == "PAID")
            return Results.Conflict(new { error = "Factuur is al betaald." });

        var desc     = body.Description ?? $"Verzekeringspremie {body.InvoiceId:N}";
        var redirect = body.ReturnUrl   ?? "https://app.yafespars.be/betaling/terugkeer";
        var webhook  = body.WebhookUrl  ?? "https://app.yafespars.be/api/payments/webhook";

        // Maak transactierecord aan.
        var transactionId = await write.ExecuteScalarAsync<Guid>(
            "finance.SP_CreatePaymentTransaction",
            new
            {
                tenant_id   = tenantId,
                invoice_id  = body.InvoiceId,
                amount_eur  = invoice.TotalAmountEur,
                description = desc,
                return_url  = redirect,
                webhook_url = webhook,
            },
            cancellationToken);

        // Roep Mollie aan.
        MolliePaymentResult mollieResult;
        try
        {
            mollieResult = await mollie.CreatePaymentAsync(
                invoice.TotalAmountEur, desc, redirect, webhook, cancellationToken);
        }
        catch (Exception ex)
        {
            return Results.Problem(
                detail: ex.Message,
                title: "Mollie API fout",
                statusCode: 502);
        }

        // Sla Mollie-ID + URL op.
        await write.ExecuteAsync(
            "finance.SP_UpdatePaymentStatus",
            new
            {
                tenant_id             = tenantId,
                transaction_id        = transactionId,
                mollie_payment_id     = (string?)null,
                status_code           = "PENDING",
                mollie_payment_id_set = mollieResult.MolliePaymentId,
                checkout_url          = mollieResult.CheckoutUrl,
            },
            cancellationToken);

        return Results.Created(
            $"/api/payments?invoiceId={body.InvoiceId}",
            new
            {
                transactionId    = transactionId,
                molliePaymentId  = mollieResult.MolliePaymentId,
                checkoutUrl      = mollieResult.CheckoutUrl,
                amountEur        = invoice.TotalAmountEur,
            });
    }

    private static async Task<IResult> HandleWebhookAsync(
        IFormCollection form,
        IWriteRepository write,
        IMolliePaymentService mollie,
        CancellationToken cancellationToken)
    {
        // Mollie stuurt application/x-www-form-urlencoded met één veld: id=tr_xxxx.
        var mollieId = form["id"].FirstOrDefault();
        if (string.IsNullOrWhiteSpace(mollieId))
            return Results.BadRequest();

        // Status ophalen bij Mollie; geef 5xx terug zodat Mollie blijft herproberen.
        string mollieStatus;
        try
        {
            mollieStatus = await mollie.GetPaymentStatusAsync(mollieId, cancellationToken);
        }
        catch
        {
            return Results.StatusCode(503); // Mollie herprobeert bij non-2xx.
        }

        var statusCode = mollieStatus switch
        {
            "paid"      => "PAID",
            "failed"    => "FAILED",
            "canceled"  => "CANCELLED",
            "expired"   => "EXPIRED",
            _           => "PENDING",
        };

        // Update betalingsstatus + factuur (tenant-agnostisch op mollie_payment_id).
        try
        {
            await write.ExecuteAsync(
                """
                UPDATE finance.PaymentTransaction
                SET status_code     = @statusCode,
                    paid_at_utc     = CASE WHEN @statusCode = 'PAID' THEN SYSUTCDATETIME() ELSE paid_at_utc END,
                    updated_at_utc  = SYSUTCDATETIME()
                WHERE mollie_payment_id = @mollieId AND is_deleted = 0;

                IF @statusCode = 'PAID'
                BEGIN
                    UPDATE finance.Invoices
                    SET StatusCode = 'PAID', UpdatedAt = SYSUTCDATETIME()
                    FROM finance.Invoices i
                    INNER JOIN finance.PaymentTransaction pt ON pt.invoice_id = i.InvoiceId
                    WHERE pt.mollie_payment_id = @mollieId AND pt.is_deleted = 0;
                END
                """,
                new { mollieId, statusCode },
                cancellationToken);
        }
        catch
        {
            return Results.StatusCode(500); // Mollie herprobeert.
        }

        return Results.Ok();
    }

    private sealed record InvoiceRow(decimal TotalAmountEur, string StatusCode);
}
