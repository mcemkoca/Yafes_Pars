using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class AuditQueryTests
{
    private readonly SqlServerFixture _fx;
    public AuditQueryTests(SqlServerFixture fx) => _fx = fx;

    private AuditQueryTools Audit => new(_fx.Read, _fx.Operator);

    [SkippableFact]
    public async Task QueryAuditLog_ReturnsJsonArray()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Audit.QueryAuditLog(limit: 10);
        using var doc = JsonDocument.Parse(res);
        Assert.Equal(JsonValueKind.Array, doc.RootElement.ValueKind);
    }

    [SkippableFact]
    public async Task QueryAuditLog_FilterByActionType_OnlyMatchingRows()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Audit.QueryAuditLog(actionType: "INSERT", limit: 20);
        using var doc = JsonDocument.Parse(res);
        foreach (var element in doc.RootElement.EnumerateArray())
        {
            if (element.TryGetProperty("ActionType", out var at))
                Assert.Equal("INSERT", at.GetString());
        }
    }

    [SkippableFact]
    public async Task GetEntityHistory_UnknownEntity_ReturnsEmptyArray()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Audit.GetEntityHistory("policy", "Contract", Guid.NewGuid().ToString());
        using var doc = JsonDocument.Parse(res);
        Assert.Equal(JsonValueKind.Array, doc.RootElement.ValueKind);
        Assert.Equal(0, doc.RootElement.GetArrayLength());
    }

    [SkippableFact]
    public async Task GetGdprDataAccessReport_UnknownPerson_ReturnsError()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Audit.GetGdprDataAccessReport(Guid.NewGuid());
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("error", out _),
            "Bilinmeyen kişi için hata mesajı bekleniyor.");
    }

    [SkippableFact]
    public async Task GetDeletionAuditTrail_ReturnsObjectWithCount()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);
        var res = await Audit.GetDeletionAuditTrail(limit: 10);
        using var doc = JsonDocument.Parse(res);
        Assert.True(doc.RootElement.TryGetProperty("deletionCount", out _));
        Assert.True(doc.RootElement.TryGetProperty("records", out _));
    }
}
