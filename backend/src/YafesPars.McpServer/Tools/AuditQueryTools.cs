using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Denetim ve GDPR uyum araçları. Yalnızca Auditor ve Admin rolleri kullanabilir.
/// Audit.AuditLog üzerinden değişiklik geçmişi ve GDPR veri erişim raporu sağlar.
/// </summary>
[McpServerToolType]
public sealed class AuditQueryTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public AuditQueryTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx  = ctx;
    }

    [McpServerTool, Description(
        "Audit log sorgula: tablo, varlık, işlem tipi ve zaman aralığına göre filtrele. / Audit logu sorgula.\n" +
        "actionType: INSERT, UPDATE veya DELETE. Boş bırakılırsa tüm tipler döner.")]
    public async Task<string> QueryAuditLog(
        [Description("Şema adı (örn. policy, finance, person) — isteğe bağlı.")] string? schemaName = null,
        [Description("Tablo adı (örn. Contract, Invoices) — isteğe bağlı.")] string? tableName = null,
        [Description("Varlık ID'si (GUID veya string) — isteğe bağlı.")] string? entityId = null,
        [Description("İşlem tipi: INSERT, UPDATE, DELETE — isteğe bağlı.")] string? actionType = null,
        [Description("Başlangıç tarihi UTC (YYYY-MM-DD) — isteğe bağlı.")] string? fromDate = null,
        [Description("Bitiş tarihi UTC (YYYY-MM-DD) — isteğe bağlı.")] string? toDate = null,
        [Description("Maksimum sonuç sayısı (varsayılan 100, maks 1000).")] int limit = 100,
        CancellationToken cancellationToken = default)
    {
        DateTime? fromUtc = fromDate is not null && DateTime.TryParse(fromDate, out var f) ? f : null;
        DateTime? toUtc   = toDate   is not null && DateTime.TryParse(toDate,   out var t) ? t.AddDays(1).AddSeconds(-1) : null;

        var rows = await _read.QueryAsync<AuditLogRow>(
            "audit.SP_QueryAuditLog",
            new
            {
                tenant_id   = _ctx.TenantId,
                schema_name = schemaName,
                table_name  = tableName,
                entity_id   = entityId,
                action_type = actionType,
                from_utc    = fromUtc,
                to_utc      = toUtc,
                limit       = Math.Clamp(limit, 1, 1000),
            },
            cancellationToken);

        return JsonSerializer.Serialize(rows);
    }

    [McpServerTool, Description(
        "Belirli bir varlığın tüm değişiklik geçmişini kolon bazlı göster. / Bir varlığın değişiklik geçmişini getir.\n" +
        "Örnek: schemaName='policy', tableName='Contract', entityId='<contract_id>'")]
    public async Task<string> GetEntityHistory(
        [Description("Şema adı (örn. policy, finance, person).")] string schemaName,
        [Description("Tablo adı (örn. Contract, Invoices, NaturalPerson).")] string tableName,
        [Description("Varlık ID'si (GUID string).")] string entityId,
        [Description("Maksimum sonuç sayısı (varsayılan 50).")] int limit = 50,
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<EntityHistoryRow>(
            "audit.SP_GetEntityHistory",
            new
            {
                tenant_id   = _ctx.TenantId,
                schema_name = schemaName,
                table_name  = tableName,
                entity_id   = entityId,
                limit       = Math.Clamp(limit, 1, 500),
            },
            cancellationToken);

        return JsonSerializer.Serialize(rows);
    }

    [McpServerTool, Description(
        "GDPR Madde 15 — kişiye ait tüm veriler özeti (inzagerecht). / GDPR veri erişim raporu oluştur.\n" +
        "Kişinin tüm kişisel verilerini (e-posta, telefon, adres, poliçe, audit kayıtları) listeler.\n" +
        "Bu rapor müşteriye verilebilecek yasal GDPR belgesidir.")]
    public async Task<string> GetGdprDataAccessReport(
        [Description("Kişi ID'si (GUID) — GDPR talebi yapan kişi.")] Guid personId,
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<GdprDataRow>(
            "audit.SP_GdprDataAccessReport",
            new
            {
                tenant_id = _ctx.TenantId,
                person_id = personId,
            },
            cancellationToken);

        if (!rows.Any())
            return JsonSerializer.Serialize(new { error = "Kişi bulunamadı veya bu tenant'a ait değil." });

        return JsonSerializer.Serialize(new
        {
            personId,
            generatedAt    = DateTime.UtcNow,
            gdprArticle    = "Article 15 GDPR — Recht van inzage",
            dataCategories = rows.GroupBy(r => r.DataCategory)
                .Select(g => new
                {
                    category = g.Key,
                    count    = g.Count(),
                    records  = g,
                }),
        });
    }

    [McpServerTool, Description(
        "Tenant'taki tüm silme (DELETE) ve anonimleştirme işlemlerini listele — denetim için. / Silme işlemlerini denetle.")]
    public async Task<string> GetDeletionAuditTrail(
        [Description("Başlangıç tarihi (YYYY-MM-DD) — isteğe bağlı.")] string? fromDate = null,
        [Description("Bitiş tarihi (YYYY-MM-DD) — isteğe bağlı.")] string? toDate = null,
        [Description("Maksimum sonuç sayısı (varsayılan 100).")] int limit = 100,
        CancellationToken cancellationToken = default)
    {
        DateTime? fromUtc = fromDate is not null && DateTime.TryParse(fromDate, out var f) ? f : null;
        DateTime? toUtc   = toDate   is not null && DateTime.TryParse(toDate,   out var t) ? t.AddDays(1).AddSeconds(-1) : null;

        var rows = await _read.QueryAsync<AuditLogRow>(
            "audit.SP_QueryAuditLog",
            new
            {
                tenant_id   = _ctx.TenantId,
                schema_name = (string?)null,
                table_name  = (string?)null,
                entity_id   = (string?)null,
                action_type = "DELETE",
                from_utc    = fromUtc,
                to_utc      = toUtc,
                limit       = Math.Clamp(limit, 1, 1000),
            },
            cancellationToken);

        return JsonSerializer.Serialize(new { deletionCount = rows.Count(), records = rows });
    }

    private sealed record AuditLogRow(
        long     AuditLogId,
        string   SchemaName,
        string   TableName,
        string   EntityId,
        string   ActionType,
        DateTime ChangedAtUtc,
        string?  ChangedByName,
        string?  OldValuesJson,
        string?  NewValuesJson,
        string?  SourceSystem,
        Guid?    CorrelationId);

    private sealed record EntityHistoryRow(
        long     AuditLogId,
        string   ActionType,
        DateTime ChangedAtUtc,
        string?  ChangedByName,
        string   ColumnName,
        string?  OldValue,
        string?  NewValue);

    private sealed record GdprDataRow(
        string    DataCategory,
        string    Label,
        Guid?     EntityId,      // audit satırları için NULL (audit_log_id BIGINT)
        string?   Detail1,
        string?   Detail2,
        string?   CreatedAt,
        string?   UpdatedAt,
        bool      IsAnonymised);
}
