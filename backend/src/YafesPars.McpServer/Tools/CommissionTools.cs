using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// Makelaarscourtage (commissie) tools. Tenant-scoped.
/// </summary>
[McpServerToolType]
public sealed class CommissionTools
{
    private readonly IReadRepository _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public CommissionTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read = read;
        _write = write;
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Lijst de commissies van een polis of makelaar. / Bir poliçe veya aracının komisyonlarını listele.\n" +
        "Geeft pending en betaalde commissies terug, gesorteerd op datum.")]
    public async Task<string> GetCommissions(
        [Description("Polis-ID (UUID, optioneel)")] Guid? contractId = null,
        [Description("Makelaar persoon-ID (UUID, optioneel)")] Guid? brokerPersonId = null,
        [Description("Status: PENDING, PAID, CANCELLED (optioneel, alle indien leeg)")] string? statusCode = null,
        [Description("Max aantal regels (standaard 50)")] int limit = 50,
        CancellationToken ct = default)
    {
        var sql = $"""
            SELECT TOP (@limit)
                commission_id, commission_date, commission_type_code, status_code,
                contract_id, broker_person_id, broker_institution_id,
                gross_premium_eur, rate_pct, commission_eur, paid_date, notes
            FROM finance.Commissions
            WHERE tenant_id = @tenantId
              AND is_deleted = 0
              {(contractId.HasValue ? "AND contract_id = @contractId" : "")}
              {(brokerPersonId.HasValue ? "AND broker_person_id = @brokerPersonId" : "")}
              {(statusCode is not null ? "AND status_code = @statusCode" : "")}
            ORDER BY commission_date DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new
        {
            tenantId = _ctx.TenantId,
            contractId,
            brokerPersonId,
            statusCode,
            limit
        }, ct);

        return rows.Count == 0
            ? "Geen commissies gevonden. / Komisyon bulunamadı."
            : JsonSerializer.Serialize(new { count = rows.Count, commissions = rows }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Registreer een makelaarscommissie op een polis. / Bir poliçeye aracı komisyonu kaydet.\n" +
        "rate_pct is een decimaal getal tussen 0 en 1 (bv. 0.15 = 15%).")]
    public async Task<string> RecordCommission(
        [Description("Polis-ID (UUID)")] Guid contractId,
        [Description("Commissiedatum (yyyy-MM-dd)")] DateOnly commissionDate,
        [Description("Bruto premie in EUR")] decimal grossPremiumEur,
        [Description("Commissietarief (0–1, bv. 0.15)")] decimal ratePct,
        [Description("Type: PRODUCTIE, VERLENGING, REGULARISATIE (standaard: PRODUCTIE)")] string commissionTypeCode = "PRODUCTIE",
        [Description("Makelaar persoon-ID (UUID, optioneel)")] Guid? brokerPersonId = null,
        [Description("Makelaar kantoor institution-ID (UUID, optioneel)")] Guid? brokerInstitutionId = null,
        [Description("Notitie (optioneel)")] string? notes = null,
        CancellationToken ct = default)
    {
        try
        {
            var id = await _write.ExecuteScalarAsync<Guid>(
                """
                DECLARE @id UNIQUEIDENTIFIER;
                EXEC finance.SP_RecordCommission
                    @tenant_id             = @tenantId,
                    @contract_id           = @contractId,
                    @commission_type_code  = @commissionTypeCode,
                    @commission_date       = @commissionDate,
                    @gross_premium_eur     = @grossPremiumEur,
                    @rate_pct              = @ratePct,
                    @broker_person_id      = @brokerPersonId,
                    @broker_institution_id = @brokerInstitutionId,
                    @notes                 = @notes,
                    @commission_id         = @id OUTPUT;
                SELECT @id;
                """,
                new
                {
                    tenantId = _ctx.TenantId,
                    contractId,
                    commissionTypeCode,
                    commissionDate,
                    grossPremiumEur,
                    ratePct,
                    brokerPersonId,
                    brokerInstitutionId,
                    notes
                },
                ct);

            var amount = Math.Round(grossPremiumEur * ratePct, 2);
            return JsonSerializer.Serialize(new
            {
                success = true,
                commissionId = id,
                commissionEur = amount,
                message = $"Commissie geregistreerd: EUR {amount:F2} ({ratePct * 100:F1}% van EUR {grossPremiumEur:F2})."
            }, JsonOpts.Default);
        }
        catch (SqlException ex) when (ex.Number == 51960)
        {
            return "Contract niet gevonden voor deze tenant.";
        }
        catch (SqlException ex) when (ex.Number == 51961)
        {
            return "Ongeldig tarief: rate_pct moet tussen 0 en 1 liggen (bv. 0.15 voor 15%).";
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Commissierapport per makelaar en polis. / Makelaar ve poliçe başına komisyon raporu.\n" +
        "Gebaseerd op reporting.VW_CommissionReport. Belçika FSMA/IDD uyumlu özet.")]
    public async Task<string> GetCommissionReport(
        [Description("Startdatum filter (yyyy-MM-dd, optioneel)")] DateOnly? fromDate = null,
        [Description("Einddatum filter (yyyy-MM-dd, optioneel)")] DateOnly? toDate = null,
        [Description("Max aantal regels (standaard 100)")] int limit = 100,
        CancellationToken ct = default)
    {
        var sql = $"""
            SELECT TOP (@limit)
                commission_date, commission_type_code, status_code,
                contract_number, tak, productcode,
                broker_naam, broker_kantoor,
                gross_premium_eur, rate_pct, commission_eur, paid_date
            FROM reporting.VW_CommissionReport
            WHERE tenant_id = @tenantId
              {(fromDate.HasValue ? "AND commission_date >= @fromDate" : "")}
              {(toDate.HasValue ? "AND commission_date <= @toDate" : "")}
            ORDER BY commission_date DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql, new
        {
            tenantId = _ctx.TenantId,
            fromDate,
            toDate,
            limit
        }, ct);

        if (rows.Count == 0)
            return "Geen commissiegegevens gevonden. / Komisyon verisi bulunamadı.";

        return JsonSerializer.Serialize(new { count = rows.Count, report = rows }, JsonOpts.Default);
    }
}
