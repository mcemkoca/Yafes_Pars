using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class TaskTools
{
    private readonly IWriteRepository _write;
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public TaskTools(IWriteRepository write, IReadRepository read, OperatorContext ctx)
    {
        _write = write;
        _read = read;
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Haal openstaande taken op voor de operatoren. / Bekleyen operatör görevlerini getir.\n" +
        "Gesorteerd op prioriteit en vervaldatum. Statussen: OPEN, IN_PROGRESS.")]
    public async Task<string> GetPendingTasks(
        [Description("Max resultaten (standaard 15)")] int limit = 15,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT TOP (@limit)
                t.task_id, t.task_type_code, t.subject, t.description,
                t.priority_code, t.task_status_code,
                t.related_entity_type, t.related_entity_id,
                t.due_at_utc, t.created_at_utc
            FROM tasking.Task t
            WHERE t.tenant_id = @tenantId
              AND t.task_status_code IN ('OPEN', 'IN_PROGRESS')
              AND t.is_deleted = 0
            ORDER BY
                CASE t.priority_code WHEN 'URGENT' THEN 1 WHEN 'HIGH' THEN 2 WHEN 'MEDIUM' THEN 3 ELSE 4 END,
                t.due_at_utc ASC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new { tenantId = _ctx.TenantId, limit }, ct);

        return rows.Count == 0
            ? "Geen openstaande taken. / Bekleyen görev yok."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Maak een nieuwe taak aan voor een operator. / Operatör görevi oluştur.\n" +
        "Prioriteitscodes: URGENT, HIGH, MEDIUM, LOW.\n" +
        "Entiteittypes: POLICY, CLAIM, PERSON, RISK_OBJECT.\n" +
        "Gebruik dit om opvolgingstaken te registreren vanuit een gesprek met de klant.")]
    public async Task<string> CreateTask(
        [Description("Onderwerp van de taak / Görev konusu")] string subject = "",
        [Description("Prioriteit: URGENT, HIGH, MEDIUM (standaard), LOW")] string priorityCode = "MEDIUM",
        [Description("Taaktype bijv. FOLLOW_UP, DOCUMENT_REQUEST, INSPECTION")] string taskTypeCode = "FOLLOW_UP",
        [Description("Gerelateerde entiteit: POLICY, CLAIM, PERSON")] string? relatedEntityType = null,
        [Description("ID van de gerelateerde entiteit (UUID)")] Guid? relatedEntityId = null,
        [Description("Vervaldatum (YYYY-MM-DD) / Son tarih")] DateTime? dueAt = null,
        [Description("Beschrijving / Açıklama")] string? description = null,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(subject))
            return "Fout: onderwerp is verplicht.";

        try
        {
            var taskId = await _write.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC tasking.sp_CreateTask " +
                "@tenant_id, @task_type_code, @subject, @description, @priority_code, @related_entity_type, @related_entity_id, @due_at_utc, NULL, @id OUTPUT; " +
                "SELECT @id;",
                new
                {
                    tenant_id = _ctx.TenantId,
                    task_type_code = taskTypeCode,
                    subject,
                    description,
                    priority_code = priorityCode,
                    related_entity_type = relatedEntityType,
                    related_entity_id = relatedEntityId,
                    due_at_utc = dueAt
                },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                taskId,
                message = $"Taak aangemaakt: '{subject}' (prioriteit: {priorityCode}, ID: {taskId})."
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Voeg een opmerking toe aan een taak. / Göreve yorum ekle.\n" +
        "Gebruik dit om voortgang of klantinformatie te documenteren.")]
    public async Task<string> AddTaskComment(
        [Description("Taak-ID (UUID)")] Guid taskId = default,
        [Description("Opmerkingstekst / Yorum metni")] string comment = "",
        CancellationToken ct = default)
    {
        if (taskId == default || string.IsNullOrWhiteSpace(comment))
            return "Fout: taskId en commentaar zijn verplicht.";

        try
        {
            await _write.ExecuteAsync(
                "EXEC tasking.sp_AddTaskComment @tenant_id, @task_id, @comment_text, NULL;",
                new { tenant_id = _ctx.TenantId, task_id = taskId, comment_text = comment },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                message = $"Opmerking toegevoegd aan taak {taskId}."
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }
}
