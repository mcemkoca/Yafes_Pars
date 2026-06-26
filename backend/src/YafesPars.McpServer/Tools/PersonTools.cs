using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.Application.ReadModels;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class PersonTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public PersonTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx = ctx;
    }

    [McpServerTool, Description("Müşteri ara. Ad, soyad, dosya numarası veya e-posta ile arama yapılabilir.")]
    public async Task<string> SearchPersons(
        [Description("Ad veya soyad (kısmi eşleşme)")] string? name = null,
        [Description("Dosya/dossier numarası")] string? dossier = null,
        [Description("E-posta adresi")] string? email = null,
        [Description("Döndürülecek maksimum kayıt sayısı (varsayılan 20)")] int limit = 20,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT TOP (@limit)
                p.person_id, p.person_kind, p.dossier,
                np.first_name, np.last_name,
                lp.legal_form,
                pc.contact_value AS primary_email,
                pc2.contact_value AS primary_phone,
                p.created_at_utc, p.updated_at_utc
            FROM person.Person p
            LEFT JOIN person.NaturalPerson  np  ON np.person_id  = p.person_id
            LEFT JOIN person.LegalPerson    lp  ON lp.person_id  = p.person_id
            LEFT JOIN person.PersonContact  pc  ON pc.person_id  = p.person_id AND pc.contact_type_code = 'EMAIL'   AND pc.is_primary = 1
            LEFT JOIN person.PersonContact  pc2 ON pc2.person_id = p.person_id AND pc2.contact_type_code = 'MOBILE' AND pc2.is_primary = 1
            WHERE p.tenant_id = @tenantId
              AND p.is_deleted = 0
              AND (@name IS NULL
                   OR np.first_name LIKE '%' + @name + '%'
                   OR np.last_name  LIKE '%' + @name + '%')
              AND (@dossier IS NULL OR p.dossier LIKE '%' + @dossier + '%')
              AND (@email   IS NULL OR pc.contact_value = @email)
            ORDER BY p.created_at_utc DESC
            """;

        var rows = await _read.QueryAsync<CustomerSummary>(sql,
            new { tenantId = _ctx.TenantId, name, dossier, email, limit }, ct);

        return rows.Count == 0
            ? "Müşteri bulunamadı."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }

    [McpServerTool, Description("Belirli bir müşterinin detay bilgilerini getir.")]
    public async Task<string> GetPerson(
        [Description("Müşterinin person_id değeri (UUID)")] Guid personId,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT p.person_id, p.person_kind, p.dossier, p.language_code, p.nationality,
                   np.first_name, np.last_name, np.birth_date, np.gender_code, np.national_id,
                   lp.legal_form, lp.incorporation_date,
                   p.created_at_utc, p.updated_at_utc
            FROM person.Person p
            LEFT JOIN person.NaturalPerson np ON np.person_id = p.person_id
            LEFT JOIN person.LegalPerson   lp ON lp.person_id = p.person_id
            WHERE p.tenant_id = @tenantId AND p.person_id = @personId AND p.is_deleted = 0
            """;

        var rows = await _read.QueryAsync<dynamic>(sql,
            new { tenantId = _ctx.TenantId, personId }, ct);

        return rows.Count == 0
            ? $"Müşteri bulunamadı: {personId}"
            : JsonSerializer.Serialize(rows[0], JsonOpts.Default);
    }
}
