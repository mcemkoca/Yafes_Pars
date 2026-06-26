using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class ClaimTools
{
    private readonly IReadRepository _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public ClaimTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read = read;
        _write = write;
        _ctx = ctx;
    }

    [McpServerTool, Description("Bir poliçenin hasar dosyalarını listele.")]
    public async Task<string> GetClaims(
        [Description("Poliçe ID'si (UUID)")] Guid contractId,
        [Description("Durum filtresi: OPEN, CLOSED, PENDING, IN_PROGRESS")] string? statusCode = null,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT cl.claim_id, cl.claim_number, cl.claim_status_code,
                   cl.incident_date, cl.reported_date, cl.closed_date,
                   cl.paid_amount, cl.reserved_amount,
                   c.contract_number
            FROM claim.Claim cl
            INNER JOIN policy.Contract c ON c.contract_id = cl.contract_id
            WHERE cl.tenant_id = @tenantId
              AND cl.contract_id = @contractId
              AND (@statusCode IS NULL OR cl.claim_status_code = @statusCode)
            ORDER BY cl.reported_date DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql,
            new { tenantId = _ctx.TenantId, contractId, statusCode }, ct);

        return rows.Count == 0
            ? "Bu poliçeye ait hasar dosyası bulunamadı."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }

    [McpServerTool, Description("Yeni hasar bildirimi oluştur.")]
    public async Task<string> CreateClaim(
        [Description("Poliçe ID'si (UUID)")] Guid contractId,
        [Description("Hasar tarihi (yyyy-MM-dd)")] DateOnly incidentDate,
        [Description("Hasar açıklaması")] string description,
        [Description("Teminat kodu (örn: KASKO, TRAFIK)")] string? coverageCode = null,
        [Description("Tahmini hasar tutarı")] decimal? reservedAmount = null,
        CancellationToken ct = default)
    {
        var claimNumber = $"H{DateTime.UtcNow:yyyyMMdd}-{Random.Shared.Next(1000, 9999)}";

        var sql = """
            INSERT INTO claim.Claim
                (tenant_id, contract_id, claim_number, claim_status_code,
                 coverage_code, incident_date, reported_date, reserved_amount)
            OUTPUT inserted.claim_id
            VALUES
                (@tenantId, @contractId, @claimNumber, 'OPEN',
                 @coverageCode, @incidentDate, CAST(SYSUTCDATETIME() AS DATE), @reservedAmount);
            """;

        var id = await _write.ExecuteScalarAsync<Guid>(sql,
            new { tenantId = _ctx.TenantId, contractId, claimNumber, coverageCode, incidentDate, reservedAmount }, ct);

        return $"Hasar bildirimi oluşturuldu. ClaimId: {id} — Numara: {claimNumber}";
    }

    [McpServerTool, Description("Operatör görevlerini listele. Bekleyen ve süresi dolan görevler önce gelir.")]
    public async Task<string> GetPendingTasks(
        [Description("Döndürülecek maksimum kayıt sayısı (varsayılan 15)")] int limit = 15,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT TOP (@limit)
                t.task_id, t.title, t.task_priority_code, t.task_status_code,
                t.related_entity_type, t.related_entity_id,
                t.due_at_utc,
                u.display_name AS assigned_to_name
            FROM tasking.Task t
            LEFT JOIN core.AppUser u ON u.user_id = t.assigned_to_user_id
            WHERE t.tenant_id = @tenantId
              AND t.task_status_code IN ('OPEN', 'IN_PROGRESS')
            ORDER BY
                CASE t.task_priority_code WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 ELSE 3 END,
                t.due_at_utc ASC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql,
            new { tenantId = _ctx.TenantId, limit }, ct);

        return rows.Count == 0
            ? "Bekleyen görev yok."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }
}
