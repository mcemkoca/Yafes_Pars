using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class NotificationImportTests
{
    private readonly SqlServerFixture _fx;
    public NotificationImportTests(SqlServerFixture fx) => _fx = fx;

    private NotificationTools Notif => new(_fx.Read, _fx.Write, _fx.Operator);
    private ImportTools Import => new(_fx.Read, _fx.Write, _fx.Operator);

    // --- Notification ---

    [SkippableFact]
    public async Task CreateOverdueInvoiceTasks_DryRun_ReturnsCount()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Notif.CreateOverdueInvoiceTasks(dryRun: true);
        Assert.DoesNotContain("Databasefout", res);
        Assert.Contains("Dry-run", res);
    }

    [SkippableFact]
    public async Task GetPendingAlerts_RunsWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Notif.GetPendingAlerts(10);
        Assert.DoesNotContain("Databasefout", res);
    }

    [SkippableFact]
    public async Task CreateComplianceAlert_EmptyTitle_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Notif.CreateComplianceAlert("", "Omschrijving");
        Assert.Contains("Fout", res);
    }

    // --- Import ---

    [SkippableFact]
    public async Task StageImportRows_InvalidJson_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Import.StageImportRows("not-json");
        Assert.Contains("Fout", res);
    }

    [SkippableFact]
    public async Task StageAndValidate_ValidRow_ReturnsValid()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var rows = JsonSerializer.Serialize(new[]
        {
            new
            {
                contract_number = "TEST-2026-001",
                contract_domain_code = "AUTO",
                contract_type_code = "BA_AUTO",
                start_date = "2026-01-01",
                end_date = "2027-01-01",
                policyholder_name = "Jan Janssen",
                gross_premium = "1200.00",
                currency_code = "EUR"
            }
        });

        var stageRes = await Import.StageImportRows(rows);
        Assert.Contains("batchId", stageRes);

        var doc = JsonDocument.Parse(stageRes);
        var batchId = Guid.Parse(doc.RootElement.GetProperty("batchId").GetString()!);

        var validateRes = await Import.ValidateImportBatch(batchId);
        Assert.DoesNotContain("Databasefout", validateRes);
        Assert.Contains("validRows", validateRes);
    }

    [SkippableFact]
    public async Task StageAndValidate_InvalidRow_ReturnsInvalid()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var rows = JsonSerializer.Serialize(new[]
        {
            new { contract_domain_code = "AUTO", start_date = "geen-datum" }
        });

        var stageRes = await Import.StageImportRows(rows);
        var doc = JsonDocument.Parse(stageRes);
        var batchId = Guid.Parse(doc.RootElement.GetProperty("batchId").GetString()!);

        var validateRes = await Import.ValidateImportBatch(batchId);
        Assert.Contains("invalidRows", validateRes);
    }
}
