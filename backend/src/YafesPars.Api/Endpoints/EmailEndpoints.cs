using System.Security.Claims;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class EmailEndpoints
{
    public static IEndpointRouteBuilder MapEmailEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/emails")
            .WithTags("Email")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("tenant");

        api.MapGet("", GetEmailLogAsync);
        api.MapPost("/send-overdue-reminders", SendOverdueRemindersAsync)
            .RequireRateLimiting("write");
        api.MapPost("/send-payment-confirmation/{invoiceId:guid}", SendPaymentConfirmationAsync)
            .RequireRateLimiting("write");
        api.MapPost("/send-renewal-notice/{contractId:guid}", SendRenewalNoticeAsync)
            .RequireRateLimiting("write");

        return app;
    }

    private static async Task<IResult> GetEmailLogAsync(
        ClaimsPrincipal user,
        string? templateCode,
        string? statusCode,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var limit    = Math.Clamp(take.GetValueOrDefault(50), 1, 200);

        var rows = await repository.QueryAsync<EmailLogRow>(
            """
            SELECT TOP (@limit)
                email_log_id        AS EmailLogId,
                recipient_email     AS RecipientEmail,
                subject             AS Subject,
                template_code       AS TemplateCode,
                related_entity_type AS EntityType,
                related_entity_id   AS EntityId,
                status_code         AS StatusCode,
                provider_message_id AS ProviderMessageId,
                sent_at_utc         AS SentAtUtc,
                created_at_utc      AS CreatedAtUtc
            FROM communication.EmailLog
            WHERE tenant_id  = @tenantId
              AND is_deleted  = 0
              AND (@templateCode IS NULL OR template_code = @templateCode)
              AND (@statusCode   IS NULL OR status_code   = @statusCode)
            ORDER BY created_at_utc DESC
            """,
            new { tenantId, templateCode, statusCode, limit },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static async Task<IResult> SendOverdueRemindersAsync(
        ClaimsPrincipal user,
        SendOverdueRequest body,
        IReadRepository read,
        IWriteRepository write,
        IEmailService email,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var limit    = Math.Clamp(body.Limit.GetValueOrDefault(50), 1, 200);

        // Email via person.Person (tenant_id) -> person.Email (is_primary)
        // Name via person.NaturalPerson (first_name, last_name)
        var invoices = await read.QueryAsync<OverdueInvoiceRow>(
            """
            SELECT TOP (@limit)
                i.InvoiceId         AS InvoiceId,
                i.Amount            AS Amount,
                i.DueDate           AS DueDate,
                e.email             AS RecipientEmail,
                np.first_name       AS FirstName,
                np.last_name        AS LastName
            FROM finance.Invoices i
            INNER JOIN person.Person p
                ON p.tenant_id = i.TenantId AND p.is_deleted = 0
            INNER JOIN person.Email e
                ON e.person_id = p.person_id AND e.is_primary = 1 AND e.is_deleted = 0
            LEFT JOIN person.NaturalPerson np
                ON np.person_id = p.person_id AND np.is_deleted = 0
            WHERE i.TenantId  = @tenantId AND i.StatusCode = N'OVERDUE'
            ORDER BY i.DueDate ASC
            """,
            new { tenantId, limit },
            cancellationToken);

        if (body.DryRun == true)
            return Results.Ok(new { dryRun = true, wouldSend = invoices.Count() });

        int sent = 0;
        foreach (var inv in invoices)
        {
            var recipientName = $"{inv.FirstName} {inv.LastName}".Trim();
            var subject = $"Herinnering: openstaande factuur van €{inv.Amount:F2} — {inv.DueDate:d}";
            var html    = $"""
                <p>Beste {recipientName},</p>
                <p>Uw factuur van <strong>&euro;{inv.Amount:F2}</strong> (vervaldatum {inv.DueDate:d}) is nog onbetaald.</p>
                <p>Met vriendelijke groeten,<br/>Yafes Pars Verzekeringen</p>
                """;

            var result = await email.SendAsync(
                new EmailMessage(inv.RecipientEmail, recipientName, subject, html),
                cancellationToken);

            await write.ExecuteAsync(
                "communication.SP_LogEmail",
                new
                {
                    tenant_id           = tenantId,
                    recipient_email     = inv.RecipientEmail,
                    recipient_name      = recipientName,
                    subject,
                    template_code       = "OVERDUE_REMINDER",
                    related_entity_type = "Invoice",
                    related_entity_id   = inv.InvoiceId,
                    status_code         = result.Success ? "SENT" : "FAILED",
                    provider_message_id = result.ProviderMessageId,
                    error_message       = result.ErrorMessage,
                },
                cancellationToken);

            if (result.Success) sent++;
        }

        return Results.Ok(new { sent, total = invoices.Count() });
    }

    private static async Task<IResult> SendPaymentConfirmationAsync(
        Guid invoiceId,
        ClaimsPrincipal user,
        IReadRepository read,
        IWriteRepository write,
        IEmailService email,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await read.QueryAsync<InvoicePersonRow>(
            """
            SELECT TOP 1
                i.Amount        AS Amount,
                e.email         AS RecipientEmail,
                np.first_name   AS FirstName,
                np.last_name    AS LastName
            FROM finance.Invoices i
            INNER JOIN person.Person p
                ON p.tenant_id = i.TenantId AND p.is_deleted = 0
            INNER JOIN person.Email e
                ON e.person_id = p.person_id AND e.is_primary = 1 AND e.is_deleted = 0
            LEFT JOIN person.NaturalPerson np
                ON np.person_id = p.person_id AND np.is_deleted = 0
            WHERE i.InvoiceId = @invoiceId AND i.TenantId = @tenantId
            """,
            new { invoiceId, tenantId },
            cancellationToken);

        var row = rows.FirstOrDefault();
        if (row is null) return Results.NotFound(new { error = "Factuur niet gevonden." });

        var recipientName = $"{row.FirstName} {row.LastName}".Trim();
        var subject = $"Betaling ontvangen: €{row.Amount:F2}";
        var html    = $"""
            <p>Beste {recipientName},</p>
            <p>Wij bevestigen ontvangst van uw betaling van <strong>&euro;{row.Amount:F2}</strong>.</p>
            <p>Met vriendelijke groeten,<br/>Yafes Pars Verzekeringen</p>
            """;

        var result = await email.SendAsync(
            new EmailMessage(row.RecipientEmail, recipientName, subject, html),
            cancellationToken);

        await write.ExecuteAsync(
            "communication.SP_LogEmail",
            new
            {
                tenant_id           = tenantId,
                recipient_email     = row.RecipientEmail,
                recipient_name      = recipientName,
                subject,
                template_code       = "PAYMENT_CONFIRM",
                related_entity_type = "Invoice",
                related_entity_id   = invoiceId,
                status_code         = result.Success ? "SENT" : "FAILED",
                provider_message_id = result.ProviderMessageId,
                error_message       = result.ErrorMessage,
            },
            cancellationToken);

        return result.Success
            ? Results.Ok(new { sent = true, email = row.RecipientEmail })
            : Results.Problem("E-mail kon niet worden verstuurd.", statusCode: 502);
    }

    private static async Task<IResult> SendRenewalNoticeAsync(
        Guid contractId,
        ClaimsPrincipal user,
        IReadRepository read,
        IWriteRepository write,
        IEmailService email,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await read.QueryAsync<ContractPersonRow>(
            """
            SELECT TOP 1
                c.contract_number       AS ContractNumber,
                c.end_date              AS EndDate,
                c.contract_domain_code  AS Domain,
                e.email                 AS RecipientEmail,
                np.first_name           AS FirstName,
                np.last_name            AS LastName
            FROM policy.Contract c
            INNER JOIN person.Person p
                ON p.tenant_id = c.tenant_id AND p.is_deleted = 0
            INNER JOIN person.Email e
                ON e.person_id = p.person_id AND e.is_primary = 1 AND e.is_deleted = 0
            LEFT JOIN person.NaturalPerson np
                ON np.person_id = p.person_id AND np.is_deleted = 0
            WHERE c.contract_id = @contractId AND c.tenant_id = @tenantId AND c.is_deleted = 0
            """,
            new { contractId, tenantId },
            cancellationToken);

        var row = rows.FirstOrDefault();
        if (row is null) return Results.NotFound(new { error = "Contract niet gevonden." });

        var recipientName = $"{row.FirstName} {row.LastName}".Trim();
        var subject = $"Verlengingsherinnering: polis {row.ContractNumber} loopt af op {row.EndDate:d}";
        var html    = $"""
            <p>Beste {recipientName},</p>
            <p>Uw <strong>{row.Domain}</strong>-polis (nr. {row.ContractNumber}) loopt af op <strong>{row.EndDate:d}</strong>.</p>
            <p>Neem contact op om uw dekking te verlengen.</p>
            <p>Met vriendelijke groeten,<br/>Yafes Pars Verzekeringen</p>
            """;

        var result = await email.SendAsync(
            new EmailMessage(row.RecipientEmail, recipientName, subject, html),
            cancellationToken);

        await write.ExecuteAsync(
            "communication.SP_LogEmail",
            new
            {
                tenant_id           = tenantId,
                recipient_email     = row.RecipientEmail,
                recipient_name      = recipientName,
                subject,
                template_code       = "RENEWAL_NOTICE",
                related_entity_type = "Contract",
                related_entity_id   = contractId,
                status_code         = result.Success ? "SENT" : "FAILED",
                provider_message_id = result.ProviderMessageId,
                error_message       = result.ErrorMessage,
            },
            cancellationToken);

        return result.Success
            ? Results.Ok(new { sent = true, contractId, email = row.RecipientEmail })
            : Results.Problem("E-mail kon niet worden verstuurd.", statusCode: 502);
    }

    private sealed record SendOverdueRequest(int? Limit, bool? DryRun);
    private sealed record EmailLogRow(Guid EmailLogId, string RecipientEmail, string Subject,
        string TemplateCode, string? EntityType, Guid? EntityId, string StatusCode,
        string? ProviderMessageId, DateTime? SentAtUtc, DateTime CreatedAtUtc);
    private sealed record OverdueInvoiceRow(Guid InvoiceId, decimal Amount, DateOnly DueDate,
        string RecipientEmail, string? FirstName, string? LastName);
    private sealed record InvoicePersonRow(decimal Amount, string RecipientEmail, string? FirstName, string? LastName);
    private sealed record ContractPersonRow(string ContractNumber, DateOnly? EndDate, string Domain,
        string RecipientEmail, string? FirstName, string? LastName);
}
