using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Üretim hazırlık ve ortam yönetimi araçları. Admin rolü gerektirir.
/// DB migration durumu, ortam ayarları ve hazırlık puanı.
/// </summary>
[McpServerToolType]
public sealed class ProductionReadinessTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public ProductionReadinessTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx  = ctx;
    }

    [McpServerTool, Description(
        "Üretim hazırlık durumunu kontrol et — migration sayısı, ortam ayarı, tenant/kullanıcı. / Prodüksiyon hazırlık raporu.\n" +
        "ReadinessStatus: READY, WARNING, NOT_READY.\n" +
        "DemoWarning=true ise PROD ortamında demo verisi bulunuyor demektir — temizlenmelidir.")]
    public async Task<string> CheckProductionReadiness(
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<ReadinessRow>(
            "core.SP_ProductionReadinessCheck",
            null,
            cancellationToken);

        var row = rows.FirstOrDefault();
        if (row is null)
            return JsonSerializer.Serialize(new { error = "Hazırlık kontrolü çalıştırılamadı." });

        return JsonSerializer.Serialize(row);
    }

    [McpServerTool, Description(
        "Tüm başarılı migration kayıtlarını listele. / Migration geçmişini gör.\n" +
        "core.SchemaMigration tablosundan migration_name ve execution_status listesini döner.")]
    public async Task<string> GetMigrationHistory(
        CancellationToken cancellationToken = default)
    {
        var rows = await _read.QueryAsync<MigrationRow>(
            "SELECT migration_name AS MigrationName, execution_status AS ExecutionStatus, " +
            "executed_at_utc AS AppliedAtUtc FROM core.SchemaMigration ORDER BY migration_name",
            null,
            cancellationToken);

        return JsonSerializer.Serialize(new { count = rows.Count, migrations = rows });
    }

    private sealed record ReadinessRow(
        string   Environment,
        int      AppliedMigrations,
        int      ActiveTenants,
        int      ActiveUsers,
        int      ActiveContracts,
        int      OpenClaims,
        int      OverdueInvoices,
        bool     IsProduction,
        string?  DemoDataSeeded,
        bool     DemoWarning,
        int      ReadinessIssues,
        string   ReadinessStatus,
        DateTime CheckedAtUtc);

    private sealed record MigrationRow(
        string   MigrationName,
        string   ExecutionStatus,
        DateTime AppliedAtUtc);
}
