using System.Security.Claims;
using System.Text;
using System.Text.Json;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class ReportingEndpoints
{
    public static IEndpointRouteBuilder MapReportingEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/reports")
            .WithTags("Reporting")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("tenant");

        api.MapGet("/fsma", FsmaExportAsync);

        return app;
    }

    /// <summary>
    /// GET /api/reports/fsma?periodStart=2026-01-01&amp;periodEnd=2026-06-30&amp;format=csv
    /// Retourneert een FSMA-rapport als CSV (standaard) of JSON.
    /// </summary>
    private static async Task<IResult> FsmaExportAsync(
        ClaimsPrincipal user,
        string periodStart,
        string periodEnd,
        string? format,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        if (!DateOnly.TryParse(periodStart, out var start))
            return Results.BadRequest(new { error = "Ongeldig periodStart. Gebruik YYYY-MM-DD." });

        if (!DateOnly.TryParse(periodEnd, out var end))
            return Results.BadRequest(new { error = "Ongeldig periodEnd. Gebruik YYYY-MM-DD." });

        if (end < start)
            return Results.BadRequest(new { error = "periodEnd mag niet voor periodStart liggen." });

        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<FsmaRow>(
            "reporting.SP_FsmaExport",
            new
            {
                tenant_id    = tenantId,
                period_start = start.ToString("yyyy-MM-dd"),
                period_end   = end.ToString("yyyy-MM-dd"),
            },
            cancellationToken);

        var asJson = string.Equals(format, "json", StringComparison.OrdinalIgnoreCase);

        if (asJson)
        {
            return Results.Ok(new
            {
                generatedAt = DateTime.UtcNow,
                periodStart,
                periodEnd,
                rows,
            });
        }

        // Standaard: CSV met BOM zodat Excel op Windows correct opent.
        var csv = BuildCsv(rows, periodStart, periodEnd);
        var bom = Encoding.UTF8.GetPreamble();
        var body = bom.Concat(Encoding.UTF8.GetBytes(csv)).ToArray();

        return Results.File(
            body,
            contentType: "text/csv; charset=utf-8",
            fileDownloadName: $"fsma_{periodStart}_{periodEnd}.csv");
    }

    private static string BuildCsv(IEnumerable<FsmaRow> rows, string periodStart, string periodEnd)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"# FSMA Export — {periodStart} t/m {periodEnd} — {DateTime.UtcNow:yyyy-MM-ddTHH:mm:ssZ}");
        sb.AppendLine("section;branche;aantal_polissen;totaal_premie_eur;periode_van;periode_tot");

        foreach (var r in rows)
        {
            sb.Append(CsvField(r.Section)).Append(';')
              .Append(CsvField(r.Branche)).Append(';')
              .Append(r.AantalPolissen).Append(';')
              .Append(r.TotaalPremieEur.ToString("F4", System.Globalization.CultureInfo.InvariantCulture)).Append(';')
              .Append(CsvField(r.PeriodeVan)).Append(';')
              .AppendLine(CsvField(r.PeriodeTot));
        }

        return sb.ToString();
    }

    private static string CsvField(string? value)
    {
        if (value is null) return string.Empty;
        if (value.Contains(';') || value.Contains('"') || value.Contains('\n'))
            return $"\"{value.Replace("\"", "\"\"")}\"";
        return value;
    }

    private sealed record FsmaRow(
        string  Section,
        string  Branche,
        int     AantalPolissen,
        decimal TotaalPremieEur,
        string  PeriodeVan,
        string  PeriodeTot);
}
