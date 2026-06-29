using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Audit-log query tools. Read-only, tenant-scoped.
/// </summary>
[McpServerToolType]
public sealed class AuditTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public AuditTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Toon het audit-log van de tenant. / Tenant denetim günlüğünü göster.\n" +
        "Filteerbaar op tabel, actie (INSERT/UPDATE/DELETE) en tijdvenster. Gesorteerd nieuwste eerst.")]
    public async Task<string> GetAuditLog(
        [Description("Tabelnaam filter (optioneel, bv. 'Contract')")] string? tableName = null,
        [Description("Actie filter: INSERT, UPDATE, DELETE (optioneel)")] string? actionType = null,
        [Description("Startdatum UTC (yyyy-MM-dd, optioneel)")] DateTime? fromUtc = null,
        [Description("Max aantal regels (standaard 50)")] int limit = 50,
        CancellationToken ct = default)
    {
        var sql = $"""
            SELECT TOP (@limit)
                al.audit_log_id,
                al.schema_name,
                al.table_name,
                al.primary_key_value,
                al.action_type,
                al.changed_at_utc,
                al.changed_by_name,
                al.changed_by_user_id,
                al.source_system,
                al.correlation_id
            FROM audit.AuditLog al
            WHERE al.tenant_id = @tenantId
              {(tableName is not null ? "AND al.table_name = @tableName" : "")}
              {(actionType is not null ? "AND al.action_type = @actionType" : "")}
              {(fromUtc.HasValue ? "AND al.changed_at_utc >= @fromUtc" : "")}
            ORDER BY al.changed_at_utc DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new
        {
            tenantId = _ctx.TenantId,
            tableName,
            actionType,
            fromUtc,
            limit
        }, ct);

        return rows.Count == 0
            ? "Geen audit-records gevonden. / Denetim kaydı bulunamadı."
            : JsonSerializer.Serialize(new { count = rows.Count, log = rows }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Toon de volledige wijzigingshistorie van één entiteit (record). / Tek bir kaydın değişim geçmişini göster.\n" +
        "Geeft alle audit-regels inclusief old/new JSON-waarden en kolomwijzigingen.")]
    public async Task<string> GetEntityHistory(
        [Description("Schemanaam (bv. 'policy')")] string schemaName,
        [Description("Tabelnaam (bv. 'Contract')")] string tableName,
        [Description("Primaire sleutel (UUID als string)")] string primaryKeyValue,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT
                al.audit_log_id,
                al.action_type,
                al.changed_at_utc,
                al.changed_by_name,
                al.old_values_json,
                al.new_values_json,
                al.source_system,
                ecs.column_name,
                ecs.old_value,
                ecs.new_value
            FROM audit.AuditLog al
            LEFT JOIN audit.EntityChangeSet ecs
                ON ecs.audit_log_id = al.audit_log_id
            WHERE al.tenant_id = @tenantId
              AND al.schema_name = @schemaName
              AND al.table_name  = @tableName
              AND al.primary_key_value = @primaryKeyValue
            ORDER BY al.changed_at_utc DESC, ecs.column_name
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new
        {
            tenantId = _ctx.TenantId,
            schemaName,
            tableName,
            primaryKeyValue
        }, ct);

        return rows.Count == 0
            ? $"Geen wijzigingshistorie gevonden voor {schemaName}.{tableName} [{primaryKeyValue}]."
            : JsonSerializer.Serialize(new
            {
                entity = $"{schemaName}.{tableName}",
                primaryKeyValue,
                count = rows.Count,
                history = rows
            }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Recente wijzigingen door een specifieke gebruiker. / Belirli bir kullanıcının son değişikliklerini göster.\n" +
        "Handig voor operationale controle en toegangsbeheer.")]
    public async Task<string> GetUserActivity(
        [Description("Gebruiker-ID (UUID)")] Guid userId,
        [Description("Aantal uren terug (standaard 24)")] int hoursBack = 24,
        [Description("Max aantal regels (standaard 50)")] int limit = 50,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT TOP (@limit)
                al.audit_log_id,
                al.schema_name,
                al.table_name,
                al.primary_key_value,
                al.action_type,
                al.changed_at_utc,
                al.source_system
            FROM audit.AuditLog al
            WHERE al.tenant_id = @tenantId
              AND al.changed_by_user_id = @userId
              AND al.changed_at_utc >= DATEADD(HOUR, -@hoursBack, SYSUTCDATETIME())
            ORDER BY al.changed_at_utc DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new
        {
            tenantId = _ctx.TenantId,
            userId,
            hoursBack,
            limit
        }, ct);

        return rows.Count == 0
            ? $"Geen activiteit gevonden voor gebruiker {userId} in de laatste {hoursBack} uur."
            : JsonSerializer.Serialize(new
            {
                userId,
                hoursBack,
                count = rows.Count,
                activity = rows
            }, JsonOpts.Default);
    }
}
