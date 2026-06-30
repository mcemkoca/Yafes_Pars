using System.Security.Claims;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class TenantManagementEndpoints
{
    public static IEndpointRouteBuilder MapTenantManagementEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/admin/tenants")
            .WithTags("Admin - Tenant Management")
            .RequireAuthorization("Admin")
            .RequireRateLimiting("write");

        api.MapGet("",                   GetTenantsAsync);
        api.MapPost("",                  ProvisionTenantAsync);
        api.MapDelete("{tenantId:guid}", DeactivateTenantAsync);

        var settings = app.MapGroup("/api/admin/settings")
            .WithTags("Admin - System Settings")
            .RequireAuthorization("Admin")
            .RequireRateLimiting("write");

        settings.MapGet("",  GetSystemSettingsAsync);
        settings.MapPut("{key}", UpsertSystemSettingAsync);

        return app;
    }

    /// <summary>GET /api/admin/tenants?includeInactive=false</summary>
    private static async Task<IResult> GetTenantsAsync(
        bool? includeInactive,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<TenantRow>(
            "core.SP_GetTenants",
            new { include_inactive = (includeInactive ?? false) ? 1 : 0 },
            cancellationToken);

        return Results.Ok(new { count = rows.Count, tenants = rows });
    }

    /// <summary>POST /api/admin/tenants</summary>
    private static async Task<IResult> ProvisionTenantAsync(
        ProvisionRequest request,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.TenantCode))
            return Results.BadRequest(new { error = "tenantCode zorunludur." });
        if (string.IsNullOrWhiteSpace(request.LegalName))
            return Results.BadRequest(new { error = "legalName zorunludur." });
        if (string.IsNullOrWhiteSpace(request.AdminEmail))
            return Results.BadRequest(new { error = "adminEmail zorunludur." });

        var rows = await repository.QueryAsync<TenantProvisionRow>(
            "DECLARE @tid UNIQUEIDENTIFIER, @uid UNIQUEIDENTIFIER; " +
            "EXEC core.SP_ProvisionTenant " +
            "@tenant_code=@tenant_code, @legal_name=@legal_name, @display_name=@display_name, " +
            "@vat_number=@vat_number, @admin_email=@admin_email, @admin_display_name=@admin_display_name, " +
            "@admin_external_subject_id=NULL, " +
            "@tenant_id=@tid OUTPUT, @admin_user_id=@uid OUTPUT; " +
            "SELECT @tid AS TenantId, @tenant_code AS TenantCode, @uid AS AdminUserId, @admin_email AS AdminEmail;",
            new
            {
                tenant_code        = request.TenantCode.Trim().ToUpperInvariant(),
                legal_name         = request.LegalName.Trim(),
                display_name       = request.DisplayName?.Trim(),
                vat_number         = request.VatNumber?.Trim(),
                admin_email        = request.AdminEmail.Trim().ToLowerInvariant(),
                admin_display_name = request.AdminDisplayName?.Trim(),
            },
            cancellationToken);

        var result = rows.FirstOrDefault();
        if (result is null)
            return Results.Problem("Tenant oluşturulamadı.", statusCode: 500);

        return Results.Created($"/api/admin/tenants/{result.TenantId}", result);
    }

    /// <summary>DELETE /api/admin/tenants/{tenantId}</summary>
    private static async Task<IResult> DeactivateTenantAsync(
        Guid tenantId,
        string? reason,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<TenantStatusRow>(
            "core.SP_DeactivateTenant",
            new { tenant_id = tenantId, reason },
            cancellationToken);

        var row = rows.FirstOrDefault();
        if (row is null)
            return Results.NotFound(new { error = "Tenant bulunamadı veya zaten deaktif." });

        return Results.Ok(row);
    }

    /// <summary>GET /api/admin/settings</summary>
    private static async Task<IResult> GetSystemSettingsAsync(
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var rows = await repository.QueryAsync<SystemSettingRow>(
            "core.SP_GetSystemSettings",
            null,
            cancellationToken);

        return Results.Ok(rows);
    }

    /// <summary>PUT /api/admin/settings/{key}</summary>
    private static async Task<IResult> UpsertSystemSettingAsync(
        string key,
        UpsertSettingRequest request,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(key))
            return Results.BadRequest(new { error = "settingKey zorunludur." });

        var rows = await repository.QueryAsync<SystemSettingRow>(
            "core.SP_UpsertSystemSetting",
            new { setting_key = key.Trim(), setting_value = request.Value, description = request.Description },
            cancellationToken);

        return Results.Ok(rows.FirstOrDefault());
    }

    private sealed record ProvisionRequest(
        string  TenantCode,
        string  LegalName,
        string  AdminEmail,
        string? DisplayName      = null,
        string? VatNumber        = null,
        string? AdminDisplayName = null);

    private sealed record UpsertSettingRequest(string Value, string? Description = null);

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
        Guid   TenantId,
        string TenantCode,
        Guid   AdminUserId,
        string AdminEmail);

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
