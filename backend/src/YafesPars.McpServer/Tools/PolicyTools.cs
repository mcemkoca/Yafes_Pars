using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.Application.ReadModels;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class PolicyTools
{
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;

    public PolicyTools(IReadRepository read, OperatorContext ctx)
    {
        _read = read;
        _ctx = ctx;
    }

    [McpServerTool, Description("Zoek verzekeringspolissen op nummer, status of type. / Poliçe ara.")]
    public async Task<string> SearchContracts(
        [Description("Polisnummer (gedeeltelijk, bijv. '2026/AUTO/001') / Poliçe numarası")] string? contractNumber = null,
        [Description("Status: ACTIVE, EXPIRED, CANCELLED, PENDING")] string? statusCode = null,
        [Description("Max resultaten (standaard 20)")] int limit = 20,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT TOP (@limit)
                c.contract_id, c.contract_number, c.contract_status_code,
                c.contract_domain_code, c.contract_type_code,
                c.start_date, c.end_date,
                i.name AS company_name,
                (SELECT COUNT(*) FROM policy.ContractVersion cv WHERE cv.contract_id = c.contract_id) AS latest_version_no,
                (SELECT COUNT(*) FROM policy.ContractParty  cp WHERE cp.contract_id = c.contract_id) AS party_count,
                (SELECT COUNT(*) FROM policy.ContractObject co WHERE co.contract_id = c.contract_id) AS object_count
            FROM policy.Contract c
            LEFT JOIN institution.Institution i ON i.institution_id = c.company_id
            WHERE c.tenant_id = @tenantId
              AND c.is_deleted = 0
              AND (@contractNumber IS NULL OR c.contract_number LIKE '%' + @contractNumber + '%')
              AND (@statusCode IS NULL OR c.contract_status_code = @statusCode)
            ORDER BY c.created_at_utc DESC
            """;

        var rows = await _read.QueryAsync<PolicySummary>(sql,
            new { tenantId = _ctx.TenantId, contractNumber, statusCode, limit }, ct);

        return rows.Count == 0
            ? "Geen polis gevonden. / Poliçe bulunamadı."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }

    [McpServerTool, Description("Lijst alle polissen van een persoon. / Bir kişinin poliçelerini listele.")]
    public async Task<string> GetContractsByPerson(
        [Description("Persoon-ID (UUID) / Kişi ID")] Guid personId,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT c.contract_id, c.contract_number, c.contract_status_code,
                   c.contract_type_code, c.start_date, c.end_date,
                   cp.contract_party_role_code
            FROM policy.ContractParty cp
            INNER JOIN policy.Contract c ON c.contract_id = cp.contract_id
            WHERE c.tenant_id = @tenantId AND cp.person_id = @personId AND c.is_deleted = 0
            ORDER BY c.start_date DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql,
            new { tenantId = _ctx.TenantId, personId }, ct);

        return rows.Count == 0
            ? "Geen polis voor deze persoon. / Bu kişiye ait poliçe yok."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }
}
