using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Tenant yönetim araçları. Yalnızca Admin rolü kullanabilir.
/// Tenant listeleme, onboarding, deaktivasyon ve sistem ayarları.
/// </summary>
[McpServerToolType]
public sealed class TenantManagementTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public TenantManagementTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx  = ctx;
    }

    [McpServerTool, Description(
        "Sistemdeki tüm tenant'ları listele (Admin). / Tenant listesini getir.\n" +
        "includeInactive=true ile deaktif tenant'lar da listelenir.")]
    public async Task<string> GetTenants(
        [Description("Deaktif tenant'ları da listele (varsayılan false).")] bool includeInactive = false,
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<TenantRow>(
            "core.SP_GetTenants",
            new { include_inactive = includeInactive ? 1 : 0 },
            cancellationToken);

        return JsonSerializer.Serialize(new { count = rows.Count, tenants = rows });
    }

    [McpServerTool, Description(
        "Yeni tenant ekle ve ilk admin kullanıcısını oluştur (Admin). / Tenant provisioning yap.\n" +
        "Zorunlu: tenantCode (örn. 'BE-BROKER-01'), legalName, adminEmail.\n" +
        "Opsiyonel: displayName, vatNumber (Belçika: BE + 10 rakam), adminDisplayName.")]
    public async Task<string> ProvisionTenant(
        [Description("Benzersiz tenant kodu (örn. 'BE-BROKER-01').")] string tenantCode,
        [Description("Şirketin yasal adı.")] string legalName,
        [Description("Admin kullanıcının e-posta adresi.")] string adminEmail,
        [Description("Görünen ad (opsiyonel, legalName'den türetilir).")] string? displayName = null,
        [Description("Belçika KBO/BTW numarası (opsiyonel, örn. BE0123456789).")] string? vatNumber = null,
        [Description("Admin kullanıcının görünen adı (opsiyonel).")] string? adminDisplayName = null,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(tenantCode))
            return JsonSerializer.Serialize(new { error = "tenantCode zorunludur." });
        if (string.IsNullOrWhiteSpace(legalName))
            return JsonSerializer.Serialize(new { error = "legalName zorunludur." });
        if (string.IsNullOrWhiteSpace(adminEmail))
            return JsonSerializer.Serialize(new { error = "adminEmail zorunludur." });

        var rows = await _read.QueryAsync<TenantProvisionRow>(
            "DECLARE @tid UNIQUEIDENTIFIER, @uid UNIQUEIDENTIFIER; " +
            "EXEC core.SP_ProvisionTenant " +
            "@tenant_code=@tenant_code, @legal_name=@legal_name, @display_name=@display_name, " +
            "@vat_number=@vat_number, @admin_email=@admin_email, @admin_display_name=@admin_display_name, " +
            "@admin_external_subject_id=NULL, " +
            "@tenant_id=@tid OUTPUT, @admin_user_id=@uid OUTPUT; " +
            "SELECT @tid AS TenantId, @tenant_code AS TenantCode, @uid AS AdminUserId, @admin_email AS AdminEmail;",
            new
            {
                tenant_code    = tenantCode.Trim().ToUpperInvariant(),
                legal_name     = legalName.Trim(),
                display_name   = displayName?.Trim(),
                vat_number     = vatNumber?.Trim(),
                admin_email    = adminEmail.Trim().ToLowerInvariant(),
                admin_display_name = adminDisplayName?.Trim(),
            },
            cancellationToken);

        var provision = rows.FirstOrDefault();
        if (provision is null)
            return JsonSerializer.Serialize(new { error = "Provisioning SP gaf geen rij terug." });

        return JsonSerializer.Serialize(provision);
    }

    [McpServerTool, Description(
        "Tenant'ı deaktive et (Admin). Veriler silinmez, sadece erişim kapatılır. / Tenant'ı pasife al.\n" +
        "Bu işlem geri alınabilir — tenant yeniden aktive etmek için DB'de is_active=1 yapılmalıdır.")]
    public async Task<string> DeactivateTenant(
        [Description("Deaktive edilecek tenant ID (GUID).")] Guid tenantId,
        [Description("Deaktivasyon nedeni (opsiyonel, audit log'a yazılır).")] string? reason = null,
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<TenantStatusRow>(
            "core.SP_DeactivateTenant",
            new { tenant_id = tenantId, reason },
            cancellationToken);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "Tenant bulunamadı veya zaten deaktif." });

        return JsonSerializer.Serialize(row);
    }

    [McpServerTool, Description(
        "Tüm sistem ayarlarını listele (Admin). / SystemSetting tablosunu oku.\n" +
        "environment, demo_data_seeded gibi operasyonel ayarları içerir.")]
    public async Task<string> GetSystemSettings(
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<SystemSettingRow>(
            "core.SP_GetSystemSettings",
            null,
            cancellationToken);

        return JsonSerializer.Serialize(rows);
    }

    [McpServerTool, Description(
        "Sistem ayarı ekle veya güncelle (Admin). / SystemSetting upsert.\n" +
        "Örnek: settingKey='maintenance_mode', settingValue='true'\n" +
        "Dikkat: 'environment' ayarı üretim kontrollerini etkiler.")]
    public async Task<string> UpsertSystemSetting(
        [Description("Ayar anahtarı (örn. 'maintenance_mode').")] string settingKey,
        [Description("Ayar değeri.")] string settingValue,
        [Description("Açıklama (opsiyonel).")] string? description = null,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(settingKey))
            return JsonSerializer.Serialize(new { error = "settingKey zorunludur." });

        var rows = await _read.QueryAsync<SystemSettingRow>(
            "core.SP_UpsertSystemSetting",
            new { setting_key = settingKey.Trim(), setting_value = settingValue, description },
            cancellationToken);

        var setting = rows.FirstOrDefault();
        if (setting is null)
            return JsonSerializer.Serialize(new { error = "Upsert SP gaf geen rij terug." });

        return JsonSerializer.Serialize(setting);
    }

    [McpServerTool, Description(
        "Tenant-isolatie controleren voor een tabel. / Bir tablo için tenant izolasyonunu kontrol et.\n" +
        "Telt rijen per tenant_id en detecteert cross-tenant lekkage in de opgegeven tabel.\n" +
        "Gebruik voor assurance-controles; schrijft niets.")]
    public async Task<string> CheckTenantIsolation(
        [Description("Schemanaam (bijv. 'coverage')")] string schemaName,
        [Description("Tabelnaam (bijv. 'ContractCoverageItem')")] string tableName,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<IsolationRow>(
            "core.SP_TenantIsolationCheck",
            new { schema_name = schemaName, table_name = tableName }, ct);

        return JsonSerializer.Serialize(new
        {
            schemaName,
            tableName,
            tenantCount = rows.Count,
            breakdown   = rows
        }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Demo-data verwijderen vóór productie-go-live. / Canlıya geçmeden önce demo verisini temizle.\n" +
        "ONOMKEERBAAR. Vereist confirmToken = 'PURGE-DEMO-DATA-CONFIRM'. " +
        "Werkt alleen als core.SystemSetting 'demo_data_seeded' = '1' én environment ≠ PROD.")]
    public async Task<string> PurgeDemoData(
        [Description("Bevestigingstoken: typ exact 'PURGE-DEMO-DATA-CONFIRM'")] string confirmToken,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<PurgeResultRow>(
            "core.SP_PurgeDemoData",
            new { confirm_token = confirmToken }, ct);

        return JsonSerializer.Serialize(new { success = true, result = rows.FirstOrDefault() }, JsonOpts.Default);
    }

    private sealed record IsolationRow(Guid TenantId, int RowCount);

    // SP_PurgeDemoData returns: Result (NVARCHAR), RowsPurged (INT)
    private sealed record PurgeResultRow(string Result, int RowsPurged);

    private sealed record TenantRow(
        Guid     TenantId,
        string   TenantCode,
        string   LegalName,
        string?  DisplayName,
        string?  VatNumber,
        bool     IsActive,
        DateTime CreatedAtUtc,
        int      ActiveUserCount,
        int      ActiveContractCount);

    private sealed record TenantProvisionRow(
        Guid    TenantId,
        string  TenantCode,
        Guid    AdminUserId,
        string  AdminEmail);

    private sealed record TenantStatusRow(
        Guid   TenantId,
        string TenantCode,
        string LegalName,
        bool   IsActive);

    private sealed record SystemSettingRow(
        string   SettingKey,
        string?  SettingValue,
        string?  Description,
        DateTime UpdatedAtUtc);
}
