using System.ComponentModel;
using System.Text;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// FSMA-rapportage tools voor periodieke regelgevende rapportage aan de
/// Autoriteit voor Financiële Diensten en Markten (FSMA — België).
/// </summary>
[McpServerToolType]
public sealed class FsmaExportTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public FsmaExportTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx  = ctx;
    }

    [McpServerTool, Description(
        "Genereer een FSMA-rapport voor een rapportageperiode als CSV-tekst. / Belirli bir dönem için FSMA raporu oluştur (CSV).\n" +
        "Bevat: actieve polissen per tak, provisietotalen per maand, vervallen facturen.")]
    public async Task<string> ExportFsmaReport(
        [Description("Startdatum van de rapportageperiode (ISO 8601: YYYY-MM-DD).")] string periodStart,
        [Description("Einddatum van de rapportageperiode (ISO 8601: YYYY-MM-DD).")] string periodEnd,
        [Description("Uitvoerformaat: 'csv' of 'json' (standaard 'csv').")] string format = "csv",
        CancellationToken cancellationToken = default)
    {
        if (!DateOnly.TryParse(periodStart, out var start))
            return JsonSerializer.Serialize(new { error = "Ongeldig periodStart-formaat. Gebruik YYYY-MM-DD." });

        if (!DateOnly.TryParse(periodEnd, out var end))
            return JsonSerializer.Serialize(new { error = "Ongeldig periodEnd-formaat. Gebruik YYYY-MM-DD." });

        if (end < start)
            return JsonSerializer.Serialize(new { error = "periodEnd mag niet voor periodStart liggen." });

        var rows = await _read.QueryAsync<FsmaRow>(
            "reporting.SP_FsmaExport",
            new
            {
                tenant_id    = _ctx.TenantId,
                period_start = start.ToString("yyyy-MM-dd"),
                period_end   = end.ToString("yyyy-MM-dd"),
            },
            cancellationToken);

        if (!rows.Any())
            return format.Equals("json", StringComparison.OrdinalIgnoreCase)
                ? JsonSerializer.Serialize(new { rows = Array.Empty<object>() })
                : "section;branche;aantal_polissen;totaal_premie_eur;periode_van;periode_tot\r\n";

        return format.Equals("json", StringComparison.OrdinalIgnoreCase)
            ? JsonSerializer.Serialize(new { generatedAt = DateTime.UtcNow, periodStart, periodEnd, rows })
            : BuildCsv(rows, periodStart, periodEnd);
    }

    [McpServerTool, Description(
        "Controleer of er FSMA-rapportagegegevens beschikbaar zijn voor een periode (preview / controle). / Bir dönem için FSMA rapor verilerinin mevcut olup olmadığını kontrol et.")]
    public async Task<string> PreviewFsmaReport(
        [Description("Startdatum (YYYY-MM-DD).")] string periodStart,
        [Description("Einddatum (YYYY-MM-DD).")] string periodEnd,
        CancellationToken cancellationToken = default)
    {
        if (!DateOnly.TryParse(periodStart, out var start) || !DateOnly.TryParse(periodEnd, out var end))
            return JsonSerializer.Serialize(new { error = "Ongeldig datumformaat." });

        var rows = await _read.QueryAsync<FsmaRow>(
            "reporting.SP_FsmaExport",
            new
            {
                tenant_id    = _ctx.TenantId,
                period_start = start.ToString("yyyy-MM-dd"),
                period_end   = end.ToString("yyyy-MM-dd"),
            },
            cancellationToken);

        var totalPolicies    = rows.Where(r => r.Section == "policy_summary")    .Sum(r => r.AantalPolissen);
        var totalCommissions = rows.Where(r => r.Section == "commission_summary").Sum(r => r.TotaalPremieEur);
        var overdueCount     = rows.Where(r => r.Section == "overdue_invoices")  .Sum(r => r.AantalPolissen);

        return JsonSerializer.Serialize(new
        {
            periodStart,
            periodEnd,
            totalActivePolicies   = totalPolicies,
            totalCommissionEur    = totalCommissions,
            overdueInvoicesCount  = overdueCount,
            rowCount              = rows.Count(),
        });
    }

    private static string BuildCsv(IEnumerable<FsmaRow> rows, string periodStart, string periodEnd)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"# FSMA Export — {periodStart} t/m {periodEnd} — gegenereerd op {DateTime.UtcNow:yyyy-MM-ddTHH:mm:ssZ}");
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
