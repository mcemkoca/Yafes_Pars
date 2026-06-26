using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class DashboardTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public DashboardTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx = ctx;
    }

    [McpServerTool, Description("Operatör dashboard özeti: aktif poliçe sayısı, açık hasar, bekleyen görev, vadesi gelen faturalar.")]
    public async Task<string> GetDashboard(CancellationToken ct = default)
    {
        var sql = """
            SELECT
                (SELECT COUNT(*) FROM policy.Contract
                 WHERE tenant_id = @t AND is_deleted = 0 AND contract_status_code = 'ACTIVE')           AS active_contracts,
                (SELECT COUNT(*) FROM claim.Claim
                 WHERE tenant_id = @t AND claim_status_code IN ('OPEN','IN_PROGRESS'))                   AS open_claims,
                (SELECT COUNT(*) FROM tasking.Task
                 WHERE tenant_id = @t AND task_status_code IN ('OPEN','IN_PROGRESS'))                    AS pending_tasks,
                (SELECT COUNT(*) FROM finance.Invoices
                 WHERE TenantId = @t AND StatusCode = 'PENDING' AND DueDate <= CAST(GETUTCDATE() AS DATE)) AS overdue_invoices,
                (SELECT ISNULL(SUM(Amount),0) FROM finance.Invoices
                 WHERE TenantId = @t AND StatusCode = 'PENDING')                                          AS total_pending_amount,
                (SELECT COUNT(*) FROM person.Person
                 WHERE tenant_id = @t AND is_deleted = 0)                                                AS total_customers
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new { t = _ctx.TenantId }, ct);
        return JsonSerializer.Serialize(rows[0], JsonOpts.Default);
    }

    [McpServerTool, Description("Bu ayki prim ve ödeme özetini getir.")]
    public async Task<string> GetMonthlyFinancialSummary(
        [Description("Yıl (varsayılan: bu yıl)")] int? year = null,
        [Description("Ay (1-12, varsayılan: bu ay)")] int? month = null,
        CancellationToken ct = default)
    {
        var y = year  ?? DateTime.UtcNow.Year;
        var m = month ?? DateTime.UtcNow.Month;

        var sql = """
            SELECT
                COUNT(*)                       AS invoice_count,
                ISNULL(SUM(i.Amount), 0)      AS total_invoiced,
                ISNULL(SUM(p.paid), 0)        AS total_paid,
                ISNULL(SUM(i.Amount), 0)
                    - ISNULL(SUM(p.paid), 0)  AS outstanding
            FROM finance.Invoices i
            OUTER APPLY (
                SELECT SUM(Amount) AS paid
                FROM finance.Payments
                WHERE InvoiceId = i.InvoiceId
            ) p
            WHERE i.TenantId = @tenantId
              AND YEAR(i.IssueDate)  = @year
              AND MONTH(i.IssueDate) = @month
            """;

        var rows = await _read.QueryAsync<dynamic>(sql,
            new { tenantId = _ctx.TenantId, year = y, month = m }, ct);

        return JsonSerializer.Serialize(new { period = $"{y:D4}-{m:D2}", summary = rows[0] }, JsonOpts.Default);
    }
}
