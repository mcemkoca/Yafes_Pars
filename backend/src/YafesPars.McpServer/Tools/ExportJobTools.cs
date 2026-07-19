using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Export job lifecycle tools. Tenant-scoped.
/// Tracks bulk data exports (FSMA, portfolio, claims, ledger) from creation to delivery.
/// </summary>
[McpServerToolType]
public sealed class ExportJobTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public ExportJobTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx  = ctx;
    }

    [McpServerTool, Description(
        "Yeni bir export job kaydı oluştur ve job_id döndür. / Maak een nieuw exportjob aan.\n" +
        "ExportTypeCodes: FSMA, PORTFOLIO, CLAIMS, LEDGER, CUSTOM.\n" +
        "Döndürür: JobId, StatusCode=PENDING, CreatedAtUtc.")]
    public async Task<string> CreateExportJob(
        [Description("Export tipi: FSMA | PORTFOLIO | CLAIMS | LEDGER | CUSTOM")] string exportTypeCode,
        [Description("Rapor dönemi başlangıcı (YYYY-MM-DD, opsiyonel)")] DateOnly? periodStart = null,
        [Description("Rapor dönemi bitişi (YYYY-MM-DD, opsiyonel)")]   DateOnly? periodEnd   = null,
        CancellationToken ct = default)
    {
        try
        {
            var rows = await _read.QueryAsync<ExportJobRow>(
                """
                EXEC import.SP_CreateExportJob
                    @tenant_id           = @tenantId,
                    @export_type_code    = @exportTypeCode,
                    @period_start        = @periodStart,
                    @period_end          = @periodEnd
                """,
                new
                {
                    tenantId      = _ctx.TenantId,
                    exportTypeCode,
                    periodStart,
                    periodEnd
                },
                ct);

            var row = rows.FirstOrDefault();
            if (row is null)
                return JsonSerializer.Serialize(new { error = "Export job aanmaken mislukt." });

            return JsonSerializer.Serialize(row);
        }
        catch (Exception ex)
        {
            return JsonSerializer.Serialize(new { error = ex.Message });
        }
    }

    [McpServerTool, Description(
        "Export job'ı tamamlandı olarak işaretle (SUCCESS / FAILED / CANCELLED). / Markeer exportjob als voltooid.\n" +
        "Döndürür: güncel job durumu.")]
    public async Task<string> CompleteExportJob(
        [Description("Job ID (UUID)")] Guid jobId,
        [Description("Sonuç: SUCCESS | FAILED | CANCELLED")] string statusCode,
        [Description("İşlenen satır sayısı (opsiyonel)")] int? rowCount = null,
        [Description("Hata mesajı (FAILED durumunda)")] string? errorMessage = null,
        CancellationToken ct = default)
    {
        try
        {
            var rows = await _read.QueryAsync<ExportJobResultRow>(
                """
                EXEC import.SP_CompleteExportJob
                    @job_id        = @jobId,
                    @tenant_id     = @tenantId,
                    @status_code   = @statusCode,
                    @row_count     = @rowCount,
                    @error_message = @errorMessage
                """,
                new
                {
                    jobId,
                    tenantId     = _ctx.TenantId,
                    statusCode,
                    rowCount,
                    errorMessage
                },
                ct);

            var row = rows.FirstOrDefault();
            if (row is null)
                return JsonSerializer.Serialize(new { error = "Job niet gevonden of kan niet worden bijgewerkt." });

            return JsonSerializer.Serialize(row);
        }
        catch (Exception ex)
        {
            return JsonSerializer.Serialize(new { error = ex.Message });
        }
    }

    [McpServerTool, Description(
        "Bir export job'ın durum ve dosya listesini getir. / Haal jobstatus + bestandenlijst op.\n" +
        "İki result set döner: job header + bağlı dosyalar.")]
    public async Task<string> GetExportJobStatus(
        [Description("Job ID (UUID)")] Guid jobId,
        CancellationToken ct = default)
    {
        try
        {
            var jobs = await _read.QueryAsync<ExportJobDetailRow>(
                """
                SELECT
                    j.job_id AS JobId, j.export_type_code AS ExportTypeCode,
                    j.status_code AS StatusCode, j.period_start AS PeriodStart,
                    j.period_end AS PeriodEnd, j.row_count AS RowCount,
                    j.started_at_utc AS StartedAtUtc,
                    j.completed_at_utc AS CompletedAtUtc,
                    j.error_message AS ErrorMessage,
                    j.created_at_utc AS CreatedAtUtc
                FROM import.ExportJob j
                WHERE j.job_id = @jobId AND j.tenant_id = @tenantId
                """,
                new { jobId, tenantId = _ctx.TenantId },
                ct);

            if (jobs.Count == 0)
                return JsonSerializer.Serialize(new { error = "Job niet gevonden." });

            var files = await _read.QueryAsync<ExportJobFileRow>(
                """
                SELECT
                    f.file_id AS FileId, f.file_name AS FileName,
                    f.file_format_code AS FileFormatCode,
                    f.byte_size AS ByteSize, f.row_count AS RowCount,
                    f.storage_path AS StoragePath,
                    f.created_at_utc AS CreatedAtUtc
                FROM import.ExportJobFile f
                WHERE f.job_id = @jobId
                ORDER BY f.created_at_utc
                """,
                new { jobId },
                ct);

            return JsonSerializer.Serialize(new { job = jobs[0], files });
        }
        catch (Exception ex)
        {
            return JsonSerializer.Serialize(new { error = ex.Message });
        }
    }

    [McpServerTool, Description(
        "Son export job'ları listele (en yeni önce). / Recente exportjobs ophalen.\n" +
        "ExportTypeCodes: FSMA, PORTFOLIO, CLAIMS, LEDGER, CUSTOM (boş = tümü).\n" +
        "StatusCodes: PENDING, RUNNING, SUCCESS, FAILED, CANCELLED (boş = tümü).")]
    public async Task<string> GetExportJobQueue(
        [Description("Export tipi filtresi (opsiyonel)")] string? exportTypeCode = null,
        [Description("Durum filtresi (opsiyonel)")]       string? statusCode     = null,
        [Description("Max satır (varsayılan 50)")]        int     limit          = 50,
        CancellationToken ct = default)
    {
        try
        {
            var rows = await _read.QueryAsync<ExportJobQueueRow>(
                "import.SP_GetExportJobQueue",
                new
                {
                    tenant_id        = _ctx.TenantId,
                    export_type_code = exportTypeCode,
                    status_code      = statusCode,
                    limit
                },
                ct);

            return JsonSerializer.Serialize(new { count = rows.Count, jobs = rows });
        }
        catch (Exception ex)
        {
            return JsonSerializer.Serialize(new { error = ex.Message });
        }
    }

    // -------------------------------------------------------------------------
    // Private record types (Dapper positional mapping — PascalCase column aliases)
    // -------------------------------------------------------------------------
    private sealed record ExportJobRow(
        Guid     JobId,
        Guid     TenantId,
        string   ExportTypeCode,
        string   StatusCode,
        DateTime CreatedAtUtc);

    private sealed record ExportJobResultRow(
        Guid      JobId,
        string    ExportTypeCode,
        string    StatusCode,
        int?      RowCount,
        DateTime? StartedAtUtc,
        DateTime? CompletedAtUtc,
        string?   ErrorMessage);

    private sealed record ExportJobDetailRow(
        Guid      JobId,
        string    ExportTypeCode,
        string    StatusCode,
        DateOnly? PeriodStart,
        DateOnly? PeriodEnd,
        int?      RowCount,
        DateTime? StartedAtUtc,
        DateTime? CompletedAtUtc,
        string?   ErrorMessage,
        DateTime  CreatedAtUtc);

    private sealed record ExportJobFileRow(
        Guid      FileId,
        string    FileName,
        string    FileFormatCode,
        long?     ByteSize,
        int?      RowCount,
        string?   StoragePath,
        DateTime  CreatedAtUtc);

    private sealed record ExportJobQueueRow(
        Guid      JobId,
        string    ExportTypeCode,
        string    StatusCode,
        DateOnly? PeriodStart,
        DateOnly? PeriodEnd,
        int?      RowCount,
        DateTime? StartedAtUtc,
        DateTime? CompletedAtUtc,
        DateTime  CreatedAtUtc);
}
