using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Operasyonel izleme araçları. Poliçe/hasar/fatura metrikleri ve tenant sağlık skoru.
/// Admin ve Operator rolleri kullanabilir.
/// </summary>
[McpServerToolType]
public sealed class OperationalMonitoringTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public OperationalMonitoringTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx  = ctx;
    }

    [McpServerTool, Description(
        "Operasyonel dashboard: poliçe, hasar, fatura ve komisyon metriklerini döner. / Operasyonel özet göster.\n" +
        "daysBack: kaç günlük periyot analiz edilsin (varsayılan 30, maks 365).")]
    public async Task<string> GetOperationalDashboard(
        [Description("Analiz periyodu gün sayısı (varsayılan 30).")] int daysBack = 30,
        CancellationToken cancellationToken = default)
    {
        daysBack = Math.Clamp(daysBack, 1, 365);

        var rows = await _read.QueryAsync<DashboardMetricRow>(
            "reporting.SP_OperationalDashboard",
            new { tenant_id = _ctx.TenantId, days_back = daysBack },
            cancellationToken);

        return JsonSerializer.Serialize(new
        {
            tenantId  = _ctx.TenantId,
            daysBack,
            asOfUtc   = DateTime.UtcNow,
            metrics   = rows.GroupBy(r => r.MetricCategory)
                .Select(g => new
                {
                    category = g.Key,
                    items    = g.Select(r => new
                    {
                        dimension   = r.Dimension,
                        count       = r.MetricValue,
                        amount      = r.MetricAmount,
                        asOfDate    = r.AsOfDate,
                    }),
                }),
        });
    }

    [McpServerTool, Description(
        "Tenant sağlık skoru (0-100) ve SLA uyum durumu. / Tenant sağlık durumunu değerlendir.\n" +
        "HEALTHY (≥80), WARNING (60-79), CRITICAL (<60). " +
        "Gecikmiş fatura oranı, hasar oranı ve yaklaşan yenilemeler temel alınır.")]
    public async Task<string> GetTenantHealthScore(
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<HealthScoreRow>(
            "reporting.SP_TenantHealthScore",
            new { tenant_id = _ctx.TenantId },
            cancellationToken);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "Sağlık skoru hesaplanamadı." });

        return JsonSerializer.Serialize(row);
    }

    [McpServerTool, Description(
        "Son N saatte gerçekleşen işlem aktivitesini özetler (schema/tablo/işlem tipine göre). / Son aktiviteyi izle.\n" +
        "hoursBack: kaç saatlik geriye bakılsın (varsayılan 24, maks 168).")]
    public async Task<string> GetRecentActivity(
        [Description("Geriye bakılacak saat sayısı (varsayılan 24, maks 168).")] int hoursBack = 24,
        CancellationToken cancellationToken = default)
    {
        hoursBack = Math.Clamp(hoursBack, 1, 168);

        var rows = await _read.QueryAsync<ActivityRow>(
            "reporting.SP_RecentActivity",
            new { tenant_id = _ctx.TenantId, hours_back = hoursBack },
            cancellationToken);

        return JsonSerializer.Serialize(new
        {
            tenantId = _ctx.TenantId,
            hoursBack,
            asOfUtc  = DateTime.UtcNow,
            totalEvents = rows.Sum(r => r.EventCount),
            activity = rows,
        });
    }

    private sealed record DashboardMetricRow(
        string   MetricCategory,
        string   Dimension,
        int      MetricValue,
        decimal? MetricAmount,
        DateOnly AsOfDate);

    private sealed record HealthScoreRow(
        int      HealthScore,
        int      ActiveContracts,
        int      OpenClaims,
        int      OverdueInvoices,
        int      ExpiringSoon,
        decimal  OverdueRatePct,
        decimal  ClaimRatePct,
        DateOnly AsOfDate,
        string   Status);

    private sealed record ActivityRow(
        string   SchemaName,
        string   TableName,
        string   ActionType,
        int      EventCount,
        DateTime LastEventUtc);
}
