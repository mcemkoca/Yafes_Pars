using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// E-mailtools voor transactionele notificaties aan verzekeringsnemers.
/// Alle e-mails worden gelogd in communication.EmailLog voor compliance-trail.
/// </summary>
[McpServerToolType]
public sealed class EmailTools
{
    private readonly IReadRepository  _read;
    private readonly IWriteRepository _write;
    private readonly IEmailService    _email;
    private readonly OperatorContext  _ctx;

    public EmailTools(IReadRepository read, IWriteRepository write,
        IEmailService email, OperatorContext ctx)
    {
        _read  = read;
        _write = write;
        _email = email;
        _ctx   = ctx;
    }

    [McpServerTool, Description(
        "Verstuur een herinneringsmail voor openstaande/vervallen facturen (OVERDUE). / Vadesi geçmiş faturalar için hatırlatma e-postası gönder.\n" +
        "Controleert automatisch alle OVERDUE facturen binnen de tenant en verstuurt een herinnering per klant.")]
    public async Task<string> SendOverdueReminders(
        [Description("Maximum aantal facturen om te verwerken (standaard 50, max 200).")] int limit = 50,
        [Description("Dry-run: berekent hoeveel mails verstuurd zouden worden zonder ze echt te sturen.")] bool dryRun = false,
        CancellationToken cancellationToken = default)
    {
        var invoices = await _read.QueryAsync<OverdueInvoiceRow>(
            """
            SELECT TOP (@limit)
                i.InvoiceId         AS InvoiceId,
                i.Amount            AS Amount,
                i.DueDate           AS DueDate,
                p.email_address     AS RecipientEmail,
                p.first_name        AS FirstName,
                p.last_name         AS LastName
            FROM finance.Invoices i
            INNER JOIN person.NaturalPerson p
                ON p.tenant_id = i.TenantId
            WHERE i.TenantId  = @tenantId
              AND i.StatusCode = N'OVERDUE'
            ORDER BY i.DueDate ASC
            """,
            new { tenantId = _ctx.TenantId, limit = Math.Clamp(limit, 1, 200) },
            cancellationToken);

        if (!invoices.Any())
            return JsonSerializer.Serialize(new { sent = 0, message = "Geen vervallen facturen gevonden." });

        if (dryRun)
            return JsonSerializer.Serialize(new { dryRun = true, wouldSend = invoices.Count() });

        var results = new List<object>();
        foreach (var inv in invoices)
        {
            var subject = $"Herinnering: openstaande factuur van €{inv.Amount:F2} — vervaldatum {inv.DueDate:d}";
            var html    = BuildOverdueHtml(inv);
            var msg     = new EmailMessage(inv.RecipientEmail, $"{inv.FirstName} {inv.LastName}", subject, html);
            var result  = await _email.SendAsync(msg, cancellationToken);

            await _write.ExecuteAsync(
                "communication.SP_LogEmail",
                new
                {
                    tenant_id            = _ctx.TenantId,
                    recipient_email      = inv.RecipientEmail,
                    recipient_name       = $"{inv.FirstName} {inv.LastName}",
                    subject,
                    template_code        = "OVERDUE_REMINDER",
                    related_entity_type  = "Invoice",
                    related_entity_id    = inv.InvoiceId,
                    status_code          = result.Success ? "SENT" : "FAILED",
                    provider_message_id  = result.ProviderMessageId,
                    error_message        = result.ErrorMessage,
                },
                cancellationToken);

            results.Add(new { invoiceId = inv.InvoiceId, success = result.Success, email = inv.RecipientEmail });
        }

        return JsonSerializer.Serialize(new { sent = results.Count(r => (bool)((dynamic)r).success), results });
    }

    [McpServerTool, Description(
        "Verstuur een betalingsbevestiging voor een betaalde factuur. / Ödenen fatura için ödeme onayı e-postası gönder.")]
    public async Task<string> SendPaymentConfirmation(
        [Description("Factuur-ID (GUID) waarvoor de betaling bevestigd wordt.")] Guid invoiceId,
        [Description("Betaalbedrag in EUR (optioneel, wordt opgehaald uit DB als niet opgegeven).")] decimal? amountEur = null,
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<InvoicePersonRow>(
            """
            SELECT TOP 1
                i.Amount            AS Amount,
                i.StatusCode        AS StatusCode,
                p.email_address     AS RecipientEmail,
                p.first_name        AS FirstName,
                p.last_name         AS LastName
            FROM finance.Invoices i
            INNER JOIN person.NaturalPerson p ON p.tenant_id = i.TenantId
            WHERE i.InvoiceId = @invoiceId AND i.TenantId = @tenantId
            """,
            new { invoiceId, tenantId = _ctx.TenantId },
            cancellationToken);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "Factuur niet gevonden." });

        var amount  = amountEur ?? row.Amount;
        var subject = $"Betaling ontvangen: €{amount:F2} — bedankt!";
        var html    = $"""
            <p>Beste {row.FirstName} {row.LastName},</p>
            <p>Wij bevestigen ontvangst van uw betaling van <strong>€{amount:F2}</strong> voor factuur {invoiceId:D}.</p>
            <p>Met vriendelijke groeten,<br/>Yafes Pars Verzekeringen</p>
            """;

        var result = await _email.SendAsync(
            new EmailMessage(row.RecipientEmail, $"{row.FirstName} {row.LastName}", subject, html),
            cancellationToken);

        await _write.ExecuteAsync(
            "communication.SP_LogEmail",
            new
            {
                tenant_id           = _ctx.TenantId,
                recipient_email     = row.RecipientEmail,
                recipient_name      = $"{row.FirstName} {row.LastName}",
                subject,
                template_code       = "PAYMENT_CONFIRM",
                related_entity_type = "Invoice",
                related_entity_id   = invoiceId,
                status_code         = result.Success ? "SENT" : "FAILED",
                provider_message_id = result.ProviderMessageId,
                error_message       = result.ErrorMessage,
            },
            cancellationToken);

        return JsonSerializer.Serialize(new { success = result.Success, invoiceId, email = row.RecipientEmail });
    }

    [McpServerTool, Description(
        "Verstuur een verlengingsherinnering voor een polis die binnenkort afloopt. / Yakında sona erecek poliçe için yenileme hatırlatması gönder.")]
    public async Task<string> SendRenewalNotice(
        [Description("Contract-ID (GUID) van de polis die verlengd moet worden.")] Guid contractId,
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<ContractPersonRow>(
            """
            SELECT TOP 1
                c.contract_number   AS ContractNumber,
                c.end_date          AS EndDate,
                c.insurance_domain  AS Domain,
                p.email_address     AS RecipientEmail,
                p.first_name        AS FirstName,
                p.last_name         AS LastName
            FROM policy.Contract c
            INNER JOIN person.NaturalPerson p ON p.tenant_id = c.tenant_id
            WHERE c.contract_id = @contractId AND c.tenant_id = @tenantId AND c.is_deleted = 0
            """,
            new { contractId, tenantId = _ctx.TenantId },
            cancellationToken);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "Contract niet gevonden." });

        var subject = $"Uw polis {row.ContractNumber} loopt af op {row.EndDate:d}";
        var html    = $"""
            <p>Beste {row.FirstName} {row.LastName},</p>
            <p>Uw <strong>{row.Domain}</strong>-polis (nr. {row.ContractNumber}) loopt af op <strong>{row.EndDate:d}</strong>.</p>
            <p>Neem contact op met uw adviseur om uw dekking te verlengen.</p>
            <p>Met vriendelijke groeten,<br/>Yafes Pars Verzekeringen</p>
            """;

        var result = await _email.SendAsync(
            new EmailMessage(row.RecipientEmail, $"{row.FirstName} {row.LastName}", subject, html),
            cancellationToken);

        await _write.ExecuteAsync(
            "communication.SP_LogEmail",
            new
            {
                tenant_id           = _ctx.TenantId,
                recipient_email     = row.RecipientEmail,
                recipient_name      = $"{row.FirstName} {row.LastName}",
                subject,
                template_code       = "RENEWAL_NOTICE",
                related_entity_type = "Contract",
                related_entity_id   = contractId,
                status_code         = result.Success ? "SENT" : "FAILED",
                provider_message_id = result.ProviderMessageId,
                error_message       = result.ErrorMessage,
            },
            cancellationToken);

        return JsonSerializer.Serialize(new { success = result.Success, contractId, email = row.RecipientEmail });
    }

    [McpServerTool, Description(
        "Haal de e-maillog op voor audit en compliance. / Denetim ve uyumluluk için e-posta günlüğünü getir.")]
    public async Task<string> GetEmailLog(
        [Description("Filter op template: OVERDUE_REMINDER, PAYMENT_CONFIRM, RENEWAL_NOTICE (optioneel).")] string? templateCode = null,
        [Description("Filter op status: QUEUED, SENT, FAILED, SKIPPED (optioneel).")] string? statusCode = null,
        [Description("Maximum aantal resultaten (standaard 50).")] int limit = 50,
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<EmailLogRow>(
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
                error_message       AS ErrorMessage,
                sent_at_utc         AS SentAtUtc,
                created_at_utc      AS CreatedAtUtc
            FROM communication.EmailLog
            WHERE tenant_id  = @tenantId
              AND is_deleted  = 0
              AND (@templateCode IS NULL OR template_code = @templateCode)
              AND (@statusCode   IS NULL OR status_code   = @statusCode)
            ORDER BY created_at_utc DESC
            """,
            new
            {
                tenantId     = _ctx.TenantId,
                templateCode,
                statusCode,
                limit        = Math.Clamp(limit, 1, 200),
            },
            cancellationToken);

        return JsonSerializer.Serialize(rows);
    }

    private static string BuildOverdueHtml(OverdueInvoiceRow inv) => $"""
        <p>Beste {inv.FirstName} {inv.LastName},</p>
        <p>Wij wijzen u erop dat factuur {inv.InvoiceId:D} van <strong>€{inv.Amount:F2}</strong>
        vervallen was op <strong>{inv.DueDate:d}</strong> en nog onbetaald is.</p>
        <p>Gelieve dit bedrag zo spoedig mogelijk te voldoen om uw verzekeringsdekking te behouden.</p>
        <p>Met vriendelijke groeten,<br/>Yafes Pars Verzekeringen</p>
        """;

    private sealed record OverdueInvoiceRow(Guid InvoiceId, decimal Amount, DateOnly DueDate,
        string RecipientEmail, string FirstName, string LastName);
    private sealed record InvoicePersonRow(decimal Amount, string StatusCode,
        string RecipientEmail, string FirstName, string LastName);
    private sealed record ContractPersonRow(string ContractNumber, DateOnly EndDate, string Domain,
        string RecipientEmail, string FirstName, string LastName);
    private sealed record EmailLogRow(Guid EmailLogId, string RecipientEmail, string Subject,
        string TemplateCode, string? EntityType, Guid? EntityId, string StatusCode,
        string? ProviderMessageId, string? ErrorMessage, DateTime? SentAtUtc, DateTime CreatedAtUtc);
}
