using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using YafesPars.Application.Abstractions;

namespace YafesPars.Infrastructure.Email;

/// <summary>
/// Verstuurt transactionele e-mails via de SendGrid Web API v3.
/// Wanneer SendGrid:ApiKey ontbreekt → stub-modus: log en retourneer succesvol
/// zodat development-omgevingen zonder externe configuratie werken.
/// </summary>
internal sealed class SendGridEmailService : IEmailService
{
    private readonly IHttpClientFactory _httpFactory;
    private readonly IConfiguration     _config;
    private readonly ILogger<SendGridEmailService> _log;

    public SendGridEmailService(
        IHttpClientFactory httpFactory,
        IConfiguration config,
        ILogger<SendGridEmailService> log)
    {
        _httpFactory = httpFactory;
        _config      = config;
        _log         = log;
    }

    public async Task<EmailSendResult> SendAsync(EmailMessage message, CancellationToken ct = default)
    {
        var apiKey   = _config["SendGrid:ApiKey"];
        var fromAddr = _config["SendGrid:FromAddress"] ?? "noreply@yafespars.be";
        var fromName = _config["SendGrid:FromName"]    ?? "Yafes Pars";

        if (string.IsNullOrWhiteSpace(apiKey))
        {
            _log.LogWarning("SendGrid:ApiKey ontbreekt — stub-modus; e-mail NIET verstuurd naar {To}: {Subject}",
                message.ToAddress, message.Subject);
            return new EmailSendResult(true, $"stub_{Guid.NewGuid():N}", null);
        }

        var payload = new
        {
            personalizations = new[]
            {
                new
                {
                    to = new[] { new { email = message.ToAddress, name = message.ToName ?? string.Empty } }
                }
            },
            from    = new { email = fromAddr, name = fromName },
            subject = message.Subject,
            content = new object[]
            {
                new { type = "text/plain", value = message.PlainTextBody ?? StripHtml(message.HtmlBody) },
                new { type = "text/html",  value = message.HtmlBody }
            }
        };

        using var client = _httpFactory.CreateClient("SendGrid");
        client.DefaultRequestHeaders.Authorization =
            new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", apiKey);

        using var resp = await client.PostAsJsonAsync("mail/send", payload, ct);

        if (resp.IsSuccessStatusCode)
        {
            resp.Headers.TryGetValues("X-Message-Id", out var ids);
            return new EmailSendResult(true, ids?.FirstOrDefault(), null);
        }

        var body = await resp.Content.ReadAsStringAsync(ct);
        _log.LogError("SendGrid fout {Status}: {Body}", resp.StatusCode, body);
        return new EmailSendResult(false, null, $"HTTP {(int)resp.StatusCode}: {body}");
    }

    private static string StripHtml(string html)
    {
        return System.Text.RegularExpressions.Regex.Replace(html, "<[^>]+>", " ").Trim();
    }
}
