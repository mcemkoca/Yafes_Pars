using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Sözleşme yenileme pipeline araçları.
/// Belçika: yenileme bildirimi yasal olarak 3 ay (90 gün) önceden yapılmalı.
/// </summary>
[McpServerToolType]
public sealed class RenewalTools
{
    private readonly IReadRepository  _read;
    private readonly IEmailService    _email;
    private readonly OperatorContext  _ctx;

    public RenewalTools(IReadRepository read, IEmailService email, OperatorContext ctx)
    {
        _read  = read;
        _email = email;
        _ctx   = ctx;
    }

    [McpServerTool, Description(
        "Yaklaşan yenileme kuyruğunu getir. / Vernieuwingswachtrij ophalen.\n" +
        "daysAhead: kaç gün içinde süresi dolacak sözleşmeler (varsayılan 90).\n" +
        "status: PENDING | NOTICE_SENT | RENEWED | DECLINED | EXPIRED (boş = tümü).\n" +
        "Yeni sözleşmeler otomatik kuyruğa eklenir (idempotent).")]
    public async Task<string> GetRenewalQueue(
        [Description("Kaç gün içinde bitecek sözleşmeler (varsayılan 90)")] int daysAhead = 90,
        [Description("Durum filtresi (boş = tümü)")] string? status = null,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<RenewalRow>(
            "policy.SP_GetRenewalQueue",
            new
            {
                tenant_id   = _ctx.TenantId,
                days_ahead  = Math.Clamp(daysAhead, 1, 365),
                status_code = string.IsNullOrWhiteSpace(status) ? null : status.ToUpperInvariant()
            }, ct);

        var urgent  = rows.Count(r => r.DaysUntilExpiry <= 30);
        var warning = rows.Count(r => r.DaysUntilExpiry is > 30 and <= 60);

        return JsonSerializer.Serialize(new
        {
            count        = rows.Count,
            urgentCount  = urgent,
            warningCount = warning,
            renewals     = rows
        });
    }

    [McpServerTool, Description(
        "Yenileme durumunu güncelle. / Vernieuwingsstatus bijwerken.\n" +
        "newStatus: PENDING | NOTICE_SENT | RENEWED | DECLINED | EXPIRED")]
    public async Task<string> ProcessRenewal(
        [Description("Yenileme kaydı UUID'i")] Guid renewalId,
        [Description("Yeni durum")] string newStatus,
        [Description("Yenilenen yeni sözleşme UUID'i (RENEWED durumunda)")] Guid? renewedContractId = null,
        [Description("Not")] string? notes = null,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<RenewalProcessResult>(
            "policy.SP_ProcessRenewal",
            new
            {
                tenant_id            = _ctx.TenantId,
                renewal_id           = renewalId,
                new_status           = newStatus.ToUpperInvariant(),
                renewed_contract_id  = renewedContractId,
                notes
            }, ct);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "Yenileme kaydı bulunamadı." });

        return JsonSerializer.Serialize(new { success = true, renewal = row });
    }

    [McpServerTool, Description(
        "Toplu yenileme bildirimleri gönder. / Bulkmailing vernieuwingsherinneringen.\n" +
        "daysAhead gün içinde bitecek ve henüz bildirim gönderilmemiş (PENDING) sözleşmelere e-posta gönderir.\n" +
        "dryRun=true ile kaç mail gönderileceğini görebilirsin.")]
    public async Task<string> SendRenewalNotices(
        [Description("Gün filtresi (varsayılan 90)")] int daysAhead = 90,
        [Description("true = saymak, false = gerçekten gönder")] bool dryRun = true,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<RenewalRow>(
            "policy.SP_GetRenewalQueue",
            new
            {
                tenant_id   = _ctx.TenantId,
                days_ahead  = Math.Clamp(daysAhead, 1, 365),
                status_code = "PENDING"
            }, ct);

        var withEmail = rows.Where(r => !string.IsNullOrWhiteSpace(r.HolderEmail)).ToList();

        if (dryRun)
            return JsonSerializer.Serialize(new
            {
                dryRun   = true,
                total    = rows.Count,
                withEmail = withEmail.Count,
                noEmail  = rows.Count - withEmail.Count,
                message  = "dryRun=false ile gerçekten göndermek için tekrar çağır."
            });

        int sent = 0, failed = 0;
        foreach (var r in withEmail)
        {
            var html = BuildRenewalEmail(r);
            var result = await _email.SendAsync(new EmailMessage(
                r.HolderEmail!,
                r.HolderName,
                $"Polis yenileme bildirimi — {r.ContractNumber} ({r.ContractEndDate:dd/MM/yyyy})",
                html), ct);

            if (result.Success)
            {
                await _read.QueryAsync<dynamic>(
                    "policy.SP_ProcessRenewal",
                    new
                    {
                        tenant_id           = _ctx.TenantId,
                        renewal_id          = r.RenewalId,
                        new_status          = "NOTICE_SENT",
                        renewed_contract_id = (Guid?)null,
                        notes               = $"Otomatik bildirim gönderildi: {result.ProviderMessageId}"
                    }, ct);
                sent++;
            }
            else
                failed++;
        }

        return JsonSerializer.Serialize(new
        {
            dryRun = false,
            sent,
            failed,
            skippedNoEmail = rows.Count - withEmail.Count,
            message = $"{sent} bildirim gönderildi, {failed} başarısız."
        });
    }

    [McpServerTool, Description(
        "Yenileme performans metrikleri. / Vernieuwingsperformance ophalen.\n" +
        "Yenileme oranı, gecikmiş ve bekleyen sayılar.")]
    public async Task<string> GetRenewalMetrics(
        [Description("Yıl (boş = bu yıl)")] int? year = null,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<MetricsRow>(
            "policy.SP_GetRenewalMetrics",
            new { tenant_id = _ctx.TenantId, year }, ct);

        var m = rows.FirstOrDefault();
        if (m is null)
            return JsonSerializer.Serialize(new { totalCount = 0 });

        return JsonSerializer.Serialize(new
        {
            year          = year ?? DateTime.UtcNow.Year,
            pendingCount  = m.PendingCount,
            noticeSentCount = m.NoticeSentCount,
            renewedCount  = m.RenewedCount,
            declinedCount = m.DeclinedCount,
            expiredCount  = m.ExpiredCount,
            totalCount    = m.TotalCount,
            renewalRatePct = m.RenewalRatePct,
            overdueCount  = m.OverdueCount,
            performanceLabel = m.RenewalRatePct switch
            {
                >= 85 => "EXCELLENT",
                >= 70 => "GOOD",
                >= 50 => "AVERAGE",
                _      => "BELOW_TARGET"
            }
        });
    }

    // -------------------------------------------------------------------------
    private static string BuildRenewalEmail(RenewalRow r) => $"""
        <html><body>
        <p>Geachte {r.HolderName},</p>
        <p>Uw polis <strong>{r.ContractNumber}</strong> verloopt op <strong>{r.ContractEndDate:dd/MM/yyyy}</strong>
        ({r.DaysUntilExpiry} dagen resterend).</p>
        <p>Neem contact op met uw makelaar om uw dekking te verlengen.</p>
        <p>Met vriendelijke groeten,<br/>Yafes Pars</p>
        </body></html>
        """;

    private sealed record RenewalRow(
        Guid     RenewalId,
        Guid     ContractId,
        string   ContractNumber,
        string   DomainCode,
        DateOnly ContractEndDate,
        int      DaysUntilExpiry,
        string   StatusCode,
        DateTime? NoticeSentAt,
        int      NoticeCount,
        string?  HolderName,
        string?  HolderEmail);

    private sealed record RenewalProcessResult(
        Guid     RenewalId,
        Guid     ContractId,
        string   StatusCode,
        int      NoticeCount,
        Guid?    RenewedContractId,
        DateTime UpdatedAtUtc);

    private sealed record MetricsRow
    {
        public int    PendingCount    { get; init; }
        public int    NoticeSentCount { get; init; }
        public int    RenewedCount    { get; init; }
        public int    DeclinedCount   { get; init; }
        public int    ExpiredCount    { get; init; }
        public int    TotalCount      { get; init; }
        public double? RenewalRatePct { get; init; }
        public int    OverdueCount    { get; init; }
    }
}
