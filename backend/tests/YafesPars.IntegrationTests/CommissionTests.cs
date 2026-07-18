using System.Text.Json;
using Microsoft.Data.SqlClient;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class CommissionTests
{
    private readonly SqlServerFixture _fx;
    public CommissionTests(SqlServerFixture fx) => _fx = fx;

    private CommissionTools Commissions => new(_fx.Read, _fx.Write, _fx.Operator);

    [SkippableFact]
    public async Task GetCommissions_RunsWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Commissions.GetCommissions(limit: 10);
        Assert.DoesNotContain("Databasefout", res);
    }

    [SkippableFact]
    public async Task RecordCommission_InvalidRate_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Commissions.RecordCommission(
            contractId: Guid.NewGuid(),
            commissionDate: DateOnly.FromDateTime(DateTime.UtcNow),
            grossPremiumEur: 1000m,
            ratePct: 1.5m); // ongeldig: > 1
        Assert.Contains("Ongeldig tarief", res);
    }

    [SkippableFact]
    public async Task GetCommissionReport_QueriesViewWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Commissions.GetCommissionReport(limit: 50);
        Assert.DoesNotContain("Databasefout", res);
    }

    // Verifies migration 046: FK_Commissions_Contract, FK_Commissions_BrokerPerson,
    // FK_Commissions_BrokerInstitution, FK_LedgerEntry_Commission constraints exist.
    [SkippableFact]
    public async Task CommissionFkConstraints_ExistInSchema()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var fks = await _fx.Read.QueryAsync<string>(
            """
            SELECT name FROM sys.foreign_keys
            WHERE name IN (
                N'FK_Commissions_Contract',
                N'FK_Commissions_BrokerPerson',
                N'FK_Commissions_BrokerInstitution',
                N'FK_LedgerEntry_Commission'
            )
            ORDER BY name
            """,
            null,
            default);

        Assert.Equal(4, fks.Count);
    }

    // Verifies migration 046: composite (tenant_id, commission_date) index exists.
    [SkippableFact]
    public async Task CommissionTenantDateIndex_Exists()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var rows = await _fx.Read.QueryAsync<string>(
            """
            SELECT name FROM sys.indexes
            WHERE name = N'IX_Commissions_Tenant_Date'
              AND object_id = OBJECT_ID(N'finance.Commissions')
            """,
            null,
            default);

        Assert.Single(rows);
    }

    // Verifies SP_FsmaExport CANCELLED filter: a CANCELLED commission must not
    // appear in the export result set.
    [SkippableFact]
    public async Task FsmaExport_ExcludesCancelledCommissions()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        // Get a real contract to satisfy the FK constraint.
        var contractRows = await _fx.Read.QueryAsync<Guid>(
            "SELECT TOP 1 contract_id FROM policy.Contract WHERE tenant_id = @tenantId AND is_deleted = 0",
            new { tenantId = _fx.Operator.TenantId },
            default);

        if (contractRows.Count == 0)
            return; // No contract in DEV — skip behavioural check.

        var contractId = contractRows[0];

        // Insert a CANCELLED commission directly (SP only creates PENDING).
        await _fx.Write.ExecuteAsync(
            """
            INSERT INTO finance.Commissions
                (tenant_id, contract_id, commission_type_code, commission_date,
                 gross_premium_eur, rate_pct, commission_eur, status_code)
            VALUES
                (@tenantId, @contractId, N'PRODUCTIE', CONVERT(DATE, SYSUTCDATETIME()),
                 1000, 0.10, 100, N'CANCELLED')
            """,
            new { tenantId = _fx.Operator.TenantId, contractId },
            default);

        // Export today's range.
        var today = DateTime.UtcNow.ToString("yyyy-MM-dd");
        var rows = await _fx.Read.QueryAsync<dynamic>(
            """
            EXEC reporting.SP_FsmaExport
                @tenant_id    = @tenantId,
                @period_start = @today,
                @period_end   = @today
            """,
            new { tenantId = _fx.Operator.TenantId, today },
            default);

        // commission_summary section must have 0 rows (cancelled was excluded).
        int cancelledInExport = 0;
        foreach (var row in rows)
        {
            var section = (string?)row.Section;
            if (section == "commission_summary")
                cancelledInExport++;
        }

        Assert.Equal(0, cancelledInExport);
    }
}
