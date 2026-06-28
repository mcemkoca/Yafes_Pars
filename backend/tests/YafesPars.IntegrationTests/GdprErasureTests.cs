using System.Text.Json;
using Xunit;
using YafesPars.McpServer.Tools;

namespace YafesPars.IntegrationTests;

[Collection("sqlserver")]
public sealed class GdprErasureTests
{
    private readonly SqlServerFixture _fx;
    public GdprErasureTests(SqlServerFixture fx) => _fx = fx;

    private PersonWriteTools Persons => new(_fx.Write, _fx.Operator);
    private ComplianceTools Compliance => new(_fx.Write, _fx.Operator);

    private static Guid ExtractGuid(string json, string prop)
    {
        using var doc = JsonDocument.Parse(json);
        return Guid.Parse(doc.RootElement.GetProperty(prop).GetString()!);
    }

    [SkippableFact]
    public async Task ErasePersonData_AnonymisesPiiButKeepsPerson()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        // Klant met PII aanmaken
        var created = await Persons.CreateNaturalPerson(
            firstName: "Sophie", lastName: "Dubois", languageCode: "FR",
            nationality: "BE", birthDate: new DateOnly(1985, 3, 12), rrn: "85031212345");
        Assert.True(created.TrimStart().StartsWith("{"), $"CreateNaturalPerson gaf geen JSON terug: {created}");
        var personId = ExtractGuid(created, "personId");

        // Anonimiseren
        var erased = await Compliance.ErasePersonData(personId, "Verzoek betrokkene art. 17 AVG");
        Assert.DoesNotContain("Fout", erased);
        Assert.DoesNotContain("Databasefout", erased);

        // PII is gewist
        var row = (await _fx.Read.QueryAsync<Np>(
            "SELECT first_name, last_name, rrn, birth_date FROM person.NaturalPerson WHERE person_id = @id",
            new { id = personId })).Single();
        Assert.Equal("GEWIST", row.first_name);
        Assert.Equal("GEWIST", row.last_name);
        Assert.Null(row.rrn);
        Assert.Null(row.birth_date);

        // Person bestaat nog (referentiële integriteit)
        var stillExists = (await _fx.Read.QueryAsync<long>(
            "SELECT COUNT_BIG(*) FROM person.Person WHERE person_id = @id AND tenant_id = @t",
            new { id = personId, t = SqlServerFixture.TenantId })).Single();
        Assert.Equal(1, stillExists);
    }

    [SkippableFact]
    public async Task ErasePersonData_RejectsUnknownPerson()
    {
        Skip.IfNot(_fx.Available, _fx.SkipReason);

        var res = await Compliance.ErasePersonData(Guid.NewGuid(), "test");
        Assert.Contains("niet gevonden", res);
    }

    private sealed record Np(string first_name, string last_name, string? rrn, DateTime? birth_date);
}
