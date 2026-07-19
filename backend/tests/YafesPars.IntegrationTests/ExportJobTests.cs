using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class ExportJobTests
{
    private readonly SqlServerFixture _fx;
    public ExportJobTests(SqlServerFixture fx) => _fx = fx;

    private ExportJobTools Jobs => new(_fx.Read, _fx.Operator);

    [SkippableFact]
    public async Task ExportJobTables_ExistInSchema()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var tables = await _fx.Read.QueryAsync<string>(
            """
            SELECT name FROM sys.tables
            WHERE schema_id = SCHEMA_ID(N'import')
              AND name IN (N'ExportJob', N'ExportJobFile')
            ORDER BY name
            """,
            null,
            default);

        Assert.Equal(2, tables.Count);
    }

    [SkippableFact]
    public async Task CreateExportJob_ReturnsJobId()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var res = await Jobs.CreateExportJob(
            exportTypeCode: "FSMA",
            periodStart: new DateOnly(9997, 1, 1),
            periodEnd:   new DateOnly(9997, 12, 31));

        Assert.DoesNotContain("error", res, StringComparison.OrdinalIgnoreCase);

        var doc = JsonDocument.Parse(res).RootElement;
        var jobId = doc.GetProperty("JobId").GetString();
        Assert.False(string.IsNullOrEmpty(jobId));
        Assert.Equal("PENDING", doc.GetProperty("StatusCode").GetString());
    }

    [SkippableFact]
    public async Task CreateAndComplete_ExportJob_FullLifecycle()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        // Create
        var createRes = await Jobs.CreateExportJob(
            exportTypeCode: "LEDGER",
            periodStart: new DateOnly(9997, 1, 1),
            periodEnd:   new DateOnly(9997, 12, 31));

        var createDoc = JsonDocument.Parse(createRes).RootElement;
        var jobIdStr  = createDoc.GetProperty("JobId").GetString()!;
        var jobId     = Guid.Parse(jobIdStr);

        // Complete as SUCCESS
        var completeRes = await Jobs.CompleteExportJob(
            jobId:      jobId,
            statusCode: "SUCCESS",
            rowCount:   42);

        Assert.DoesNotContain("error", completeRes, StringComparison.OrdinalIgnoreCase);

        var completeDoc = JsonDocument.Parse(completeRes).RootElement;
        Assert.Equal("SUCCESS", completeDoc.GetProperty("StatusCode").GetString());
        Assert.Equal(42, completeDoc.GetProperty("RowCount").GetInt32());
    }

    [SkippableFact]
    public async Task GetExportJobQueue_RunsWithoutError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var res = await Jobs.GetExportJobQueue(limit: 10);

        Assert.DoesNotContain("error", res, StringComparison.OrdinalIgnoreCase);
        var doc = JsonDocument.Parse(res).RootElement;
        Assert.True(doc.TryGetProperty("count", out _));
        Assert.True(doc.TryGetProperty("jobs", out _));
    }

    [SkippableFact]
    public async Task CreateExportJob_InvalidType_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var res = await Jobs.CreateExportJob(exportTypeCode: "INVALID_TYPE");

        Assert.Contains("error", res, StringComparison.OrdinalIgnoreCase);
    }
}
