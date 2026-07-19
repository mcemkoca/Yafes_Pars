using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// GDPR / compliance + assurance tools.
/// ErasePersonData is irreversible. Scan tools write findings but do not modify business data.
/// </summary>
[McpServerToolType]
public sealed class ComplianceTools
{
    private readonly IReadRepository  _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext  _ctx;

    public ComplianceTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read  = read;
        _write = write;
        _ctx   = ctx;
    }

    [McpServerTool, Description(
        "GDPR recht-op-vergetelheid: anonimiseer alle persoonsgegevens (PII) van een klant. / " +
        "Müşterinin tüm kişisel verilerini anonimleştir (GDPR silme hakkı).\n" +
        "ONOMKEERBAAR. Naam, RRN, geboortedatum, contacten en bankgegevens worden gewist. " +
        "Polissen/schades blijven bestaan (transactiegegevens, wettelijke bewaarplicht).")]
    public async Task<string> ErasePersonData(
        [Description("Persoon-ID (UUID) van de te anonimiseren klant")] Guid personId = default,
        [Description("Reden / juridische grondslag (optioneel, voor audit)")] string? reason = null,
        CancellationToken ct = default)
    {
        if (personId == default)
            return "Fout: personId is verplicht.";

        try
        {
            var erased = await _write.ExecuteScalarAsync<int>(
                "DECLARE @n INT; " +
                "EXEC core.SP_ErasePersonData @tenant_id = @tenant_id, @person_id = @person_id, " +
                "@reason = @reason, @erased_fields = @n OUTPUT; " +
                "SELECT @n;",
                new { tenant_id = _ctx.TenantId, person_id = personId, reason },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                personId,
                erasedRecords = erased,
                message = $"Persoonsgegevens geanonimiseerd ({erased} records). Polissen/schades blijven intact."
            }, JsonOpts.Default);
        }
        catch (SqlException ex) when (ex.Number == 51950)
        {
            return $"Persoon {personId} niet gevonden voor deze tenant.";
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    // -------------------------------------------------------------------------
    // Assurance — SQL review
    // -------------------------------------------------------------------------

    [McpServerTool, Description(
        "SQL-wijziging indienen voor assurance-review. / SQL değişikliği gözden geçirme için gönder.\n" +
        "Omgeving PROD krijgt automatisch risicoscore + PENDING_APPROVAL status.\n" +
        "environmentCode: DEV | TEST | ACC | PROD")]
    public async Task<string> SubmitSqlReviewRequest(
        [Description("Doelomgeving: DEV | TEST | ACC | PROD")] string environmentCode,
        [Description("Naam van de doeldatabase (bijv. YafesPars_Prod)")] string targetDatabase,
        [Description("Naam / beschrijving van het script (max 200 tekens)")] string scriptName,
        [Description("Te reviewen SQL-tekst")] string submittedSql,
        [Description("Rollback-SQL (optioneel maar aanbevolen voor PROD)")] string? rollbackSql = null,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<SqlReviewRow>(
            "assurance.SP_CreateSqlReviewRequest",
            new
            {
                tenant_id             = _ctx.TenantId,
                environment_code      = environmentCode.ToUpperInvariant(),
                target_database       = targetDatabase,
                script_name           = scriptName,
                submitted_sql         = submittedSql,
                rollback_sql          = rollbackSql,
                submitted_by_user_id  = (Guid?)null
            }, ct);

        return JsonSerializer.Serialize(new { success = true, review = rows.FirstOrDefault() }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Lopende SQL-review aanvragen ophalen. / Açık SQL gözden geçirme taleplerini listele.\n" +
        "Toont de meest recente aanvragen (standaard 100).")]
    public async Task<string> GetSqlReviewRequests(
        [Description("Maksimum kayıt sayısı (varsayılan: 100)")] int limit = 100,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<SqlReviewRow>(
            "assurance.SP_GetSqlReviewRequests",
            new { tenant_id = _ctx.TenantId, limit }, ct);

        return JsonSerializer.Serialize(new { count = rows.Count, requests = rows }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "SQL-risicoanalyse bevindingen ophalen. / SQL risk bulgularını getir.\n" +
        "sqlReviewRequestId leeg = alle bevindingen voor de tenant.")]
    public async Task<string> GetSqlRiskFindings(
        [Description("SQL review UUID (boş = tenant'ın tüm bulguları)")] Guid? sqlReviewRequestId = null,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<SqlRiskFindingRow>(
            "assurance.SP_GetSqlRiskFindings",
            new { tenant_id = _ctx.TenantId, sql_review_request_id = sqlReviewRequestId }, ct);

        return JsonSerializer.Serialize(new { count = rows.Count, findings = rows }, JsonOpts.Default);
    }

    // -------------------------------------------------------------------------
    // Assurance — compliance scans
    // -------------------------------------------------------------------------

    [McpServerTool, Description(
        "PII-kolommen scannen in de database. / Veritabanındaki PII sütunlarını tara.\n" +
        "Scant sys.columns op bekende PII-patronen (naam, BSN, e-mail, IBAN…) " +
        "en schrijft bevindingen naar assurance.SensitiveColumnFinding.")]
    public async Task<string> RunSensitiveColumnScan(CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<SensitiveColumnRow>(
            "assurance.SP_RunSensitiveColumnScan",
            new { tenant_id = _ctx.TenantId }, ct);

        return JsonSerializer.Serialize(new
        {
            success  = true,
            scanned  = rows.Count,
            findings = rows
        }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "GDPR / ISO-27001 nalevingsscan uitvoeren. / GDPR ve ISO 27001 uyumluluk taraması çalıştır.\n" +
        "Controleert retentiebeleid, verwijdering, toegangsbeheer en versleuteling. " +
        "Schrijft ComplianceScanRun met summary_json.")]
    public async Task<string> RunComplianceScan(CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<ComplianceScanRow>(
            "assurance.SP_RunComplianceScan",
            new { tenant_id = _ctx.TenantId }, ct);

        return JsonSerializer.Serialize(new { success = true, scan = rows.FirstOrDefault() }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Compliance-bevindingen ophalen na een scan. / Uyumluluk tarama bulgularını listele.\n" +
        "Toont bevindingen van de meest recente nalevingsscan (standaard 200).")]
    public async Task<string> GetComplianceFindings(
        [Description("Maksimum kayıt sayısı (varsayılan: 200)")] int limit = 200,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<ComplianceFindingRow>(
            "assurance.SP_GetComplianceFindings",
            new { tenant_id = _ctx.TenantId, limit }, ct);

        return JsonSerializer.Serialize(new { count = rows.Count, findings = rows }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Rechtendrift scannen: gebruikers zonder rollen. / İzin kayması taraması: rolsüz kullanıcılar.\n" +
        "Zoekt naar actieve gebruikers zonder gekoppelde rol en schrijft PermissionDriftFinding.")]
    public async Task<string> RunPermissionDriftScan(CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<PermissionDriftRow>(
            "assurance.SP_RunPermissionDriftScan",
            new { tenant_id = _ctx.TenantId }, ct);

        return JsonSerializer.Serialize(new
        {
            success  = true,
            drifted  = rows.Count,
            findings = rows
        }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Rechtendrift-bevindingen ophalen. / İzin kayması bulgularını listele.\n" +
        "Geeft gebruikers terug die geen gekoppelde rol hebben.")]
    public async Task<string> GetPermissionDriftFindings(CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<PermissionDriftRow>(
            "assurance.SP_GetPermissionDriftFindings",
            new { tenant_id = _ctx.TenantId }, ct);

        return JsonSerializer.Serialize(new { count = rows.Count, findings = rows }, JsonOpts.Default);
    }

    // -------------------------------------------------------------------------
    private sealed record SqlReviewRow(
        Guid   SqlReviewRequestId,
        string EnvironmentCode,
        string TargetDatabase,
        string ScriptName,
        string Status,
        int?   RiskScore,
        DateTime CreatedAtUtc);

    private sealed record SqlRiskFindingRow(
        Guid   FindingId,
        Guid   SqlReviewRequestId,
        string RiskCategory,
        string RiskLevel,
        string Description,
        string? AffectedObject);

    private sealed record SensitiveColumnRow(
        string SchemaName,
        string TableName,
        string ColumnName,
        string PiiCategory,
        bool   IsEncrypted);

    private sealed record ComplianceScanRow(
        Guid     ScanRunId,
        DateTime ScannedAtUtc,
        int      TotalChecks,
        int      PassedChecks,
        int      FailedChecks,
        string?  SummaryJson);

    private sealed record ComplianceFindingRow(
        Guid   FindingId,
        string Framework,
        string ControlCode,
        string ControlDescription,
        string Status,
        string? Recommendation);

    private sealed record PermissionDriftRow(
        Guid   UserId,
        string Email,
        bool   IsActive,
        int    RoleCount,
        DateTime? LastLoginAtUtc);
}
