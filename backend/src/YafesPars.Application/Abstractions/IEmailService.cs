namespace YafesPars.Application.Abstractions;

public interface IEmailService
{
    Task<EmailSendResult> SendAsync(EmailMessage message, CancellationToken ct = default);
}

public sealed record EmailMessage(
    string ToAddress,
    string? ToName,
    string Subject,
    string HtmlBody,
    string? PlainTextBody = null);

public sealed record EmailSendResult(
    bool     Success,
    string?  ProviderMessageId,
    string?  ErrorMessage);
