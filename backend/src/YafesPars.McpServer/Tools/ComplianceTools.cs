using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

/// <summary>
/// GDPR / compliance-tools. Anonimisering is onomkeerbaar; polissen en schades
/// blijven referentieel intact (person_id behouden) voor de wettelijke bewaarplicht.
/// </summary>
[McpServerToolType]
public sealed class ComplianceTools
{
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public ComplianceTools(IWriteRepository write, OperatorContext ctx)
    {
        _write = write;
        _ctx = ctx;
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
}
