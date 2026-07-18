using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Müşteri şikayet yönetimi — FSMA Circulaire 2012-17 uyumlu.
/// 15 iş günü (≈21 takvim günü) çözüm süresi izlenir.
/// </summary>
[McpServerToolType]
public sealed class ComplaintTools
{
    private readonly IReadRepository  _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext  _ctx;

    public ComplaintTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read  = read;
        _write = write;
        _ctx   = ctx;
    }

    [McpServerTool, Description(
        "Yeni müşteri şikayeti kaydet. / Nieuwe klacht registreren.\n" +
        "channel: EMAIL | PHONE | POST | IN_PERSON | ONLINE | SOCIAL\n" +
        "priority: LOW | NORMAL | HIGH | URGENT\n" +
        "fsmaReportable=true → FSMA yıllık raporuna dahil edilir.")]
    public async Task<string> RegisterComplaint(
        [Description("Şikayetçi kişinin UUID'i (person_id)")] Guid personId,
        [Description("Şikayet konusu (max 200 karakter)")] string subject,
        [Description("Şikayet açıklaması")] string description,
        [Description("Kanal: EMAIL (varsayılan), PHONE, POST, IN_PERSON, ONLINE, SOCIAL")] string channel = "EMAIL",
        [Description("Öncelik: LOW, NORMAL (varsayılan), HIGH, URGENT")] string priority = "NORMAL",
        [Description("İlgili sözleşme UUID'i (opsiyonel)")] Guid? contractId = null,
        [Description("İlgili hasar UUID'i (opsiyonel)")] Guid? claimId = null,
        [Description("FSMA'ya raporlanacak mı? (varsayılan: false)")] bool fsmaReportable = false,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<ComplaintResult>(
            "communication.SP_RegisterComplaint",
            new
            {
                tenant_id       = _ctx.TenantId,
                person_id       = personId,
                contract_id     = contractId,
                claim_id        = claimId,
                channel_code    = channel.ToUpperInvariant(),
                subject,
                description,
                priority_code   = priority.ToUpperInvariant(),
                fsma_reportable = fsmaReportable
            }, ct);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "Şikayet kaydedilemedi." });

        return JsonSerializer.Serialize(new
        {
            success     = true,
            complaintId = row.ComplaintId,
            statusCode  = row.StatusCode,
            receivedDate = row.ReceivedDate,
            fsmaReportable = row.FsmaReportable,
            message     = "Şikayet başarıyla kaydedildi. 21 takvim günü içinde çözülmelidir."
        });
    }

    [McpServerTool, Description(
        "Şikayet durumunu güncelle. / Klachtstatus bijwerken.\n" +
        "newStatus: OPEN | IN_PROGRESS | RESOLVED | ESCALATED | CLOSED\n" +
        "ESCALATED → otomatik olarak fsma_reportable=true yapılır.")]
    public async Task<string> UpdateComplaintStatus(
        [Description("Şikayet UUID'i")] Guid complaintId,
        [Description("Yeni durum: OPEN, IN_PROGRESS, RESOLVED, ESCALATED, CLOSED")] string newStatus,
        [Description("Çözüm notu (RESOLVED/CLOSED durumunda zorunlu önerilir)")] string? resolutionNotes = null,
        [Description("Atanan kullanıcı UUID'i (opsiyonel)")] Guid? assignedUserId = null,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<ComplaintStatusResult>(
            "communication.SP_UpdateComplaintStatus",
            new
            {
                complaint_id      = complaintId,
                tenant_id         = _ctx.TenantId,
                new_status        = newStatus.ToUpperInvariant(),
                resolution_notes  = resolutionNotes,
                assigned_user_id  = assignedUserId
            }, ct);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "Şikayet bulunamadı veya güncellenemedi." });

        return JsonSerializer.Serialize(new
        {
            success      = true,
            complaintId  = row.ComplaintId,
            statusCode   = row.StatusCode,
            resolvedDate = row.ResolvedDate,
            fsmaReportable = row.FsmaReportable
        });
    }

    [McpServerTool, Description(
        "Şikayet özet gösterge tablosu. / Klachtendashboard ophalen.\n" +
        "Açık, devam eden, gecikmiş ve FSMA bekleyen şikayet sayılarını döner.\n" +
        "Gecikmiş = 21 takvim günü aşılmış (FSMA 15 iş günü sınırı).")]
    public async Task<string> GetComplaintDashboard(
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<DashboardRow>(
            "communication.SP_GetComplaintDashboard",
            new { tenant_id = _ctx.TenantId }, ct);

        var d = rows.FirstOrDefault();
        if (d is null)
            return JsonSerializer.Serialize(new { openCount = 0, inProgressCount = 0 });

        return JsonSerializer.Serialize(new
        {
            openCount        = d.OpenCount,
            inProgressCount  = d.InProgressCount,
            escalatedCount   = d.EscalatedCount,
            closedCount      = d.ClosedCount,
            fsmaPendingCount = d.FsmaPendingCount,
            overdueCount     = d.OverdueCount,
            avgResolutionDays = d.AvgResolutionDays,
            complianceStatus = d.OverdueCount == 0 ? "COMPLIANT" : $"WARNING: {d.OverdueCount} gecikmiş şikayet"
        });
    }

    [McpServerTool, Description(
        "Tenant şikayet listesi. / Klachtenlijst ophalen.\n" +
        "status: OPEN, IN_PROGRESS, RESOLVED, ESCALATED, CLOSED (boş = tümü)")]
    public async Task<string> GetComplaints(
        [Description("Durum filtresi (boş = tümü)")] string? status = null,
        [Description("Maksimum kayıt sayısı (varsayılan 100)")] int limit = 100,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<ComplaintListRow>(
            "communication.SP_GetComplaintsByTenant",
            new
            {
                tenant_id   = _ctx.TenantId,
                status_code = string.IsNullOrWhiteSpace(status) ? null : status.ToUpperInvariant(),
                top_n       = Math.Clamp(limit, 1, 500)
            }, ct);

        return JsonSerializer.Serialize(new { count = rows.Count, complaints = rows });
    }

    [McpServerTool, Description(
        "FSMA şikayet raporu. / FSMA-klachtenrapport genereren.\n" +
        "Yalnızca fsma_reportable=true şikayetleri, belirtilen yılı kapsar.\n" +
        "year boş bırakılırsa mevcut yıl alınır.")]
    public async Task<string> GetFsmaComplaintReport(
        [Description("Rapor yılı (boş = bu yıl)")] int? year = null,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<FsmaRow>(
            "reporting.SP_FsmaComplaintReport",
            new { tenant_id = _ctx.TenantId, year }, ct);

        var exceeded = rows.Count(r => r.ExceededDeadline);
        return JsonSerializer.Serialize(new
        {
            reportYear       = year ?? DateTime.UtcNow.Year,
            totalFsma        = rows.Count,
            exceededDeadline = exceeded,
            complianceRate   = rows.Count > 0 ? Math.Round(100.0 * (rows.Count - exceeded) / rows.Count, 1) : 100.0,
            complaints       = rows
        });
    }

    // -------------------------------------------------------------------------
    private sealed record ComplaintResult(
        Guid     ComplaintId,
        string   StatusCode,
        DateTime ReceivedDate,
        bool     FsmaReportable);

    private sealed record ComplaintStatusResult(
        Guid      ComplaintId,
        string    StatusCode,
        DateTime? ResolvedDate,
        bool      FsmaReportable);

    private sealed record DashboardRow
    {
        public int  OpenCount         { get; init; }
        public int  InProgressCount   { get; init; }
        public int  EscalatedCount    { get; init; }
        public int  ClosedCount       { get; init; }
        public int  FsmaPendingCount  { get; init; }
        public int  OverdueCount      { get; init; }
        public int? AvgResolutionDays { get; init; }
    }

    private sealed record ComplaintListRow(
        Guid      ComplaintId,
        Guid      PersonId,
        string    PersonName,
        Guid?     ContractId,
        Guid?     ClaimId,
        DateTime  ReceivedDate,
        string    ChannelCode,
        string    Subject,
        string    StatusCode,
        string    PriorityCode,
        bool      FsmaReportable,
        DateTime? ResolvedDate,
        int       DaysOpen);

    private sealed record FsmaRow
    {
        public Guid      ComplaintId      { get; init; }
        public DateTime  ReceivedDate     { get; init; }
        public string    Channel          { get; init; } = string.Empty;
        public string    Subject          { get; init; } = string.Empty;
        public string    Status           { get; init; } = string.Empty;
        public string    Priority         { get; init; } = string.Empty;
        public DateTime? ResolvedDate     { get; init; }
        public int       DaysToResolve    { get; init; }
        public bool      ExceededDeadline { get; init; }
        public string    ClientName       { get; init; } = string.Empty;
    }
}
