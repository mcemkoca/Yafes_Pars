using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Xunit;
using YafesPars.McpServer;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

/// <summary>
/// Voert de echte MCP-tool schrijfpaden uit tegen een live SQL Server.
/// Dekt regressie voor C1-C7 (SP-signatuur uitlijning) + Belgische dekkingscatalogus.
/// Deze tests zouden de oorspronkelijke bugs hebben gevangen die CI miste.
/// </summary>
[Collection("sqlserver")]
public sealed class WriteFlowTests
{
    private readonly SqlServerFixture _fx;
    public WriteFlowTests(SqlServerFixture fx) => _fx = fx;

    private sealed record ContractRow(string contract_number, string contract_status_code);
    private sealed record ClaimRow(string claim_number, decimal? reserved_amount);

    private PersonWriteTools Persons => new(_fx.Write, _fx.Operator);
    private PolicyWriteTools Policies => new(_fx.Write, _fx.Operator);
    private RiskTools Risks => new(_fx.Read, _fx.Write, _fx.Operator);
    private ClaimTools Claims => new(_fx.Read, _fx.Write, _fx.Operator);
    private TaskTools Tasks => new(_fx.Write, _fx.Read, _fx.Operator);

    private DocumentTools Documents
    {
        get
        {
            var cfg = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["AzureStorage:ConnectionString"] = "",
                ["AzureStorage:ContainerName"] = "documents"
            }).Build();
            return new DocumentTools(_fx.Write, _fx.Read, _fx.Operator, new BlobStorageService(cfg));
        }
    }

    private static Guid ExtractGuid(string json, string prop)
    {
        using var doc = JsonDocument.Parse(json);
        return Guid.Parse(doc.RootElement.GetProperty(prop).GetString()!);
    }

    private static void AssertNoError(string result)
    {
        Assert.False(
            result.StartsWith("Fout", StringComparison.OrdinalIgnoreCase)
            || result.StartsWith("Databasefout", StringComparison.OrdinalIgnoreCase)
            || result.StartsWith("Onbekend", StringComparison.OrdinalIgnoreCase),
            $"Tool gaf een fout terug: {result}");
    }

    private async Task<long> CountAsync(string sql, object param)
        => (await _fx.Read.QueryAsync<long>(sql, param)).Single();

    private async Task<Guid> NewPolicyAsync()
    {
        var res = await Policies.CreatePolicy("MOTOR", "AUTO_BA", new DateOnly(2026, 1, 1));
        AssertNoError(res);
        return ExtractGuid(res, "contractId");
    }

    // ── C2: legal_name werd nooit opgeslagen (kolom bestond niet) ───────────────
    [SkippableFact]
    public async Task CreateLegalPerson_PersistsLegalName()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var res = await Persons.CreateLegalPerson("Acme Verzekeringen NV", "NV", "BE0123456789", "0123456789");
        AssertNoError(res);
        var personId = ExtractGuid(res, "personId");

        var names = await _fx.Read.QueryAsync<string>(
            "SELECT legal_name FROM person.LegalPerson WHERE person_id = @id", new { id = personId });

        Assert.Equal("Acme Verzekeringen NV", names.Single());
    }

    // ── C2b: natuurlijke persoon ───────────────────────────────────────────────
    [SkippableFact]
    public async Task CreateNaturalPerson_PersistsName()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var res = await Persons.CreateNaturalPerson("Jan", "Janssens", "NL");
        AssertNoError(res);
        var personId = ExtractGuid(res, "personId");

        var last = await _fx.Read.QueryAsync<string>(
            "SELECT last_name FROM person.NaturalPerson WHERE person_id = @id", new { id = personId });
        Assert.Equal("Janssens", last.Single());
    }

    // ── C1: contractnummer + status werden niet correct gezet ───────────────────
    [SkippableFact]
    public async Task CreatePolicy_AutoGeneratesNumberAndActiveStatus()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var contractId = await NewPolicyAsync();

        var row = (await _fx.Read.QueryAsync<ContractRow>(
            "SELECT contract_number, contract_status_code FROM policy.Contract WHERE contract_id = @id",
            new { id = contractId })).Single();

        Assert.False(string.IsNullOrWhiteSpace(row.contract_number));
        Assert.Equal("ACTIVE", row.contract_status_code);
    }

    // ── Catalogusbug: BA_AUTO ontbrak in coverage.CoverageType ──────────────────
    [SkippableFact]
    public async Task AddCoverageItem_AcceptsBelgianCode_BA_AUTO()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var contractId = await NewPolicyAsync();
        var res = await Policies.AddCoverageItem(contractId, "BA_AUTO", 250000m, null, "EUR");
        AssertNoError(res);

        var count = await CountAsync(
            "SELECT COUNT_BIG(*) FROM coverage.ContractCoverageItem WHERE contract_id = @id AND coverage_type_code = 'BA_AUTO'",
            new { id = contractId });
        Assert.Equal(1, count);
    }

    // ── C4: named+positionele mix maakte RegisterVehicle ongeldige SQL ──────────
    [SkippableFact]
    public async Task RegisterVehicle_PersistsViaNamedParams()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var plate = "1-XYZ-" + Random.Shared.Next(100, 999);
        var res = await Risks.RegisterVehicle(plate, "Volkswagen", "Golf", 2022, "WVWZZZ123", 18000m, "EUR");
        AssertNoError(res);

        var count = await CountAsync(
            "SELECT COUNT_BIG(*) FROM risk.InsurableVehicle WHERE license_plate = @p", new { p = plate });
        Assert.Equal(1, count);
    }

    // ── C5: SP_CreateClaim signatuur + reserved_amount ──────────────────────────
    [SkippableFact]
    public async Task CreateClaim_AutoNumberAndReservedAmount()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var contractId = await NewPolicyAsync();
        var res = await Claims.CreateClaim(contractId, new DateOnly(2026, 6, 20), "Aanrijding", "OMNIUM", 1500m);
        AssertNoError(res);
        var claimId = ExtractGuid(res, "claimId");

        var row = (await _fx.Read.QueryAsync<ClaimRow>(
            "SELECT claim_number, reserved_amount FROM claim.Claim WHERE claim_id = @id", new { id = claimId })).Single();

        Assert.False(string.IsNullOrWhiteSpace(row.claim_number));
        Assert.Equal(1500m, row.reserved_amount);
    }

    // ── C6/C7: SP_CreateTask volgorde + SP_AddTaskComment OUTPUT ────────────────
    [SkippableFact]
    public async Task CreateTaskAndComment_Succeeds()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var taskRes = await Tasks.CreateTask("Opvolging klant", "HIGH", "FOLLOW_UP");
        AssertNoError(taskRes);
        var taskId = ExtractGuid(taskRes, "taskId");

        var commentRes = await Tasks.AddTaskComment(taskId, "Klant gebeld, wacht op documenten.");
        AssertNoError(commentRes);

        var count = await CountAsync(
            "SELECT COUNT_BIG(*) FROM tasking.Task WHERE task_id = @id", new { id = taskId });
        Assert.Equal(1, count);
    }

    // ── document.sp_CreateDocument (021 owner-param versie) ──────────────────────
    [SkippableFact]
    public async Task UploadDocument_PersistsWithOwner()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var contractId = await NewPolicyAsync();
        var res = await Documents.UploadDocument(
            "polis.pdf", "POLICY_DOCUMENT", "POLICY", contractId,
            "application/pdf", null, null, 1024, "Testpolis");
        AssertNoError(res);
        var documentId = ExtractGuid(res, "documentId");

        var count = await CountAsync(
            "SELECT COUNT_BIG(*) FROM document.Document WHERE document_id = @id", new { id = documentId });
        Assert.Equal(1, count);
    }
}
