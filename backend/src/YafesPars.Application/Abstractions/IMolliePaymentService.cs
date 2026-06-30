namespace YafesPars.Application.Abstractions;

public interface IMolliePaymentService
{
    /// <summary>Maakt een Mollie-betaling aan en retourneert de checkout-URL en Mollie-ID.</summary>
    Task<MolliePaymentResult> CreatePaymentAsync(
        decimal amountEur,
        string description,
        string returnUrl,
        string webhookUrl,
        CancellationToken cancellationToken = default);

    /// <summary>Haalt de huidige status op van een Mollie-betaling.</summary>
    Task<string> GetPaymentStatusAsync(string molliePaymentId, CancellationToken cancellationToken = default);
}

public sealed record MolliePaymentResult(
    string MolliePaymentId,
    string CheckoutUrl,
    string Status);
