using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using YafesPars.Application.Abstractions;

namespace YafesPars.Infrastructure.Mollie;

/// <summary>
/// HttpClient-implementatie van Mollie REST API v2.
/// Wanneer MOLLIE_API_KEY leeg is, retourneert dit een stub-resultaat (development/test).
/// </summary>
internal sealed class MolliePaymentService : IMolliePaymentService
{
    private const string MollieBaseUrl = "https://api.mollie.com/v2/";

    private readonly HttpClient _http;
    private readonly string? _apiKey;

    public MolliePaymentService(IHttpClientFactory httpClientFactory, IConfiguration config)
    {
        _http   = httpClientFactory.CreateClient("Mollie");
        _apiKey = config["Mollie:ApiKey"];
    }

    public async Task<MolliePaymentResult> CreatePaymentAsync(
        decimal amountEur,
        string description,
        string returnUrl,
        string webhookUrl,
        CancellationToken cancellationToken = default)
    {
        // Stub voor development wanneer geen API key aanwezig is.
        if (string.IsNullOrWhiteSpace(_apiKey))
            return new MolliePaymentResult(
                $"tr_stub_{Guid.NewGuid():N}",
                $"{returnUrl}?stub=1",
                "open");

        var body = JsonSerializer.Serialize(new
        {
            amount      = new { currency = "EUR", value = amountEur.ToString("F2") },
            description,
            redirectUrl = returnUrl,
            webhookUrl,
        });

        using var request = new HttpRequestMessage(HttpMethod.Post, "payments")
        {
            Content = new StringContent(body, Encoding.UTF8, "application/json"),
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _apiKey);

        var response = await _http.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();

        await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var doc = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);
        var root = doc.RootElement;

        return new MolliePaymentResult(
            root.GetProperty("id").GetString()!,
            root.GetProperty("_links").GetProperty("checkout").GetProperty("href").GetString()!,
            root.GetProperty("status").GetString()!);
    }

    public async Task<string> GetPaymentStatusAsync(string molliePaymentId, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_apiKey))
            return "open";

        using var request = new HttpRequestMessage(HttpMethod.Get, $"payments/{molliePaymentId}");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _apiKey);

        var response = await _http.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();

        await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var doc = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);
        return doc.RootElement.GetProperty("status").GetString()!;
    }
}
