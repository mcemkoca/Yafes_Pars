using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Operationele melding-tools. Maak taken aan voor achterstallige facturen,
/// open schades en compliance-deadlines. Tenant-scoped.
/// </summary>
[McpServerToolType]
public sealed class NotificationTools
{
    private readonly IReadRepository _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public NotificationTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read = read;
        _write = write;
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Maak taken aan voor achterstallige facturen (OVERDUE). / Gecikmiş faturalar için görev oluştur.\n" +
        "dryRun=true (standaard) toont het aantal; dryRun=false maakt de taken echt aan.")]
    public async Task<string> CreateOverdueInvoiceTasks(
        [Description("true = alleen tellen (standaard), false = taken aanmaken")] bool dryRun = true,
        [Description("Prioriteit: LOW, NORMAL, HIGH (standaard: HIGH)")] string priority = "HIGH",
        CancellationToken ct = default)
    {
        var countSql = """
            SELECT COUNT(*) AS cnt
            FROM finance.Invoices
            WHERE TenantId   = @tenantId
              AND StatusCode = N'OVERDUE'
            """;

        var rows = await _read.QueryAsync<dynamic>(countSql, new { tenantId = _ctx.TenantId }, ct);
        int count = (int)(rows[0].cnt ?? 0);

        if (dryRun || count == 0)
            return JsonSerializer.Serialize(new
            {
                dryRun,
                overdueCount = count,
                message = dryRun
                    ? $"Dry-run: {count} achterstallige factuur/facturen gevonden. Roep aan met dryRun=false om taken aan te maken."
                    : "Geen achterstallige facturen."
            }, JsonOpts.Default);

        var invoiceSql = """
            SELECT InvoiceId, ContractId, DueDate, Amount
            FROM finance.Invoices
            WHERE TenantId   = @tenantId
              AND StatusCode = N'OVERDUE'
            """;

        var invoices = await _read.QueryAsync<dynamic>(invoiceSql, new { tenantId = _ctx.TenantId }, ct);
        int created = 0;

        foreach (var inv in invoices)
        {
            try
            {
                await _write.ExecuteAsync(
                    """
                    DECLARE @id UNIQUEIDENTIFIER;
                    EXEC tasking.SP_CreateTask
                        @tenant_id            = @tenantId,
                        @title                = @title,
                        @description          = @description,
                        @related_entity_type  = N'INVOICE',
                        @related_entity_id    = @invoiceId,
                        @task_priority_code   = @priority,
                        @created_task_id      = @id OUTPUT;
                    """,
                    new
                    {
                        tenantId = _ctx.TenantId,
                        title = $"Achterstallige factuur EUR {inv.Amount:F2} (vervaldatum {inv.DueDate:d})",
                        description = $"Invoice {inv.InvoiceId} op contract {inv.ContractId} is achterstallig.",
                        invoiceId = inv.InvoiceId,
                        priority
                    },
                    ct);
                created++;
            }
            catch (SqlException) { /* Sla over bij dubbele taken */ }
        }

        return JsonSerializer.Serialize(new
        {
            success = true,
            tasksCreated = created,
            message = $"{created} taak/taken aangemaakt voor achterstallige facturen."
        }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Maak een compliance-melding aan (FSMA-deadline, IDD-verplichting, GDPR-actie). / Uyumluluk bildirimi oluştur.\n" +
        "Wordt aangemaakt als taak met hoge prioriteit voor de operator.")]
    public async Task<string> CreateComplianceAlert(
        [Description("Titel van de melding / Bildirim başlığı")] string title,
        [Description("Omschrijving / Açıklama")] string description,
        [Description("Deadline UTC (yyyy-MM-ddTHH:mm:ss, optioneel)")] DateTime? dueAtUtc = null,
        [Description("Prioriteit: NORMAL, HIGH, URGENT (standaard: HIGH)")] string priority = "HIGH",
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(title))
            return "Fout: titel is verplicht.";

        try
        {
            await _write.ExecuteAsync(
                """
                DECLARE @id UNIQUEIDENTIFIER;
                EXEC tasking.SP_CreateTask
                    @tenant_id           = @tenantId,
                    @title               = @title,
                    @description         = @description,
                    @related_entity_type = N'COMPLIANCE',
                    @task_priority_code  = @priority,
                    @due_at_utc          = @dueAtUtc,
                    @created_task_id     = @id OUTPUT;
                """,
                new { tenantId = _ctx.TenantId, title, description, priority, dueAtUtc },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                message = $"Compliance-melding aangemaakt: '{title}'."
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Toon openstaande operator-meldingen (taken met hoge prioriteit). / Açık operatör bildirimlerini göster.\n" +
        "Geeft OPEN/IN_PROGRESS taken gesorteerd op prioriteit en vervaldatum.")]
    public async Task<string> GetPendingAlerts(
        [Description("Max aantal (standaard 25)")] int limit = 25,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT TOP (@limit)
                t.task_id, t.title, t.description,
                t.task_priority_code, t.task_status_code,
                t.related_entity_type, t.related_entity_id,
                t.due_at_utc, t.created_at_utc
            FROM tasking.Task t
            WHERE t.tenant_id = @tenantId
              AND t.task_status_code IN (N'OPEN', N'IN_PROGRESS')
              AND t.task_priority_code IN (N'HIGH', N'URGENT')
              AND t.is_deleted = 0
            ORDER BY
                CASE t.task_priority_code WHEN N'URGENT' THEN 0 ELSE 1 END,
                t.due_at_utc ASC,
                t.created_at_utc DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new { tenantId = _ctx.TenantId, limit }, ct);

        return rows.Count == 0
            ? "Geen openstaande meldingen. / Açık bildirim yok."
            : JsonSerializer.Serialize(new { count = rows.Count, alerts = rows }, JsonOpts.Default);
    }
}
