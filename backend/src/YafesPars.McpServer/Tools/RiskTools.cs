using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class RiskTools
{
    private readonly IReadRepository _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext _ctx;

    public RiskTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read = read;
        _write = write;
        _ctx = ctx;
    }

    [McpServerTool, Description("Registreer een voertuig. / Araç kaydı yap. Kentekenplaat is verplicht.")]
    public async Task<string> RegisterVehicle(
        [Description("Nummerplaat bijv. 1-ABC-123 / Plaka")] string plateNumber,
        [Description("Merk bijv. Volkswagen / Marka")] string? brand = null,
        [Description("Model bijv. Golf / Model")] string? model = null,
        [Description("Bouwjaar bijv. 2022 / Model yılı")] int? modelYear = null,
        [Description("Chassisnummer / Şasi numarası")] string? chassisNumber = null,
        [Description("Marktwaarde / Piyasa değeri")] decimal? marketValue = null,
        [Description("Valuta (standaard: EUR)")] string currencyCode = "EUR",
        CancellationToken ct = default)
    {
        var sql = """
            DECLARE @id UNIQUEIDENTIFIER;
            EXEC risk.sp_CreateVehicle
                @tenant_id   = @tenantId,
                @plate_number = @plateNumber,
                @brand        = @brand,
                @model        = @model,
                @model_year   = @modelYear,
                @chassis_number = @chassisNumber,
                @market_value = @marketValue,
                @currency_code = @currencyCode,
                @insurable_object_id = @id OUTPUT;
            SELECT @id;
            """;

        var id = await _write.ExecuteScalarAsync<Guid>(sql,
            new { tenantId = _ctx.TenantId, plateNumber, brand, model, modelYear, chassisNumber, marketValue, currencyCode }, ct);

        return $"Araç kaydedildi. InsurableObjectId: {id} — Plaka: {plateNumber}";
    }

    [McpServerTool, Description("Registreer een eigendom (woning, handelspand). / Taşınmaz kaydı yap.")]
    public async Task<string> RegisterProperty(
        [Description("Adres van het eigendom / Taşınmaz adresi")] string? address = null,
        [Description("Type: HOUSE, APARTMENT, COMMERCIAL, LAND (standaard: HOUSE)")] string propertyTypeCode = "HOUSE",
        [Description("Bewoonbare oppervlakte (m²) / İnşaat alanı")] decimal? constructionArea = null,
        [Description("Bouwjaar / İnşaat yılı")] int? constructionYear = null,
        [Description("Verzekerde waarde / Sigortalı değer")] decimal? insuredValue = null,
        [Description("Valuta (standaard: EUR)")] string currencyCode = "EUR",
        CancellationToken ct = default)
    {
        var sql = """
            DECLARE @id UNIQUEIDENTIFIER;
            EXEC risk.sp_CreateProperty
                @tenant_id          = @tenantId,
                @property_address   = @address,
                @property_type_code = @propertyTypeCode,
                @construction_area  = @constructionArea,
                @construction_year  = @constructionYear,
                @insured_value      = @insuredValue,
                @currency_code      = @currencyCode,
                @insurable_object_id = @id OUTPUT;
            SELECT @id;
            """;

        var id = await _write.ExecuteScalarAsync<Guid>(sql,
            new { tenantId = _ctx.TenantId, address, propertyTypeCode, constructionArea, constructionYear, insuredValue, currencyCode }, ct);

        return $"Taşınmaz kaydedildi. InsurableObjectId: {id}";
    }

    [McpServerTool, Description("Koppel een risico-object (voertuig/eigendom) aan een polis. / Riski poliçeye bağla.")]
    public async Task<string> LinkRiskToContract(
        [Description("Polis-ID (UUID)")] Guid contractId,
        [Description("Object-ID (UUID — uit RegisterVehicle/RegisterProperty)")] Guid insurableObjectId,
        CancellationToken ct = default)
    {
        await _write.ExecuteAsync(
            "EXEC risk.sp_LinkRiskToContract @tenant_id, @contract_id, @insurable_object_id;",
            new { tenant_id = _ctx.TenantId, contract_id = contractId, insurable_object_id = insurableObjectId }, ct);

        return $"Risk nesnesi poliçeye bağlandı. ContractId: {contractId} — ObjectId: {insurableObjectId}";
    }

    [McpServerTool, Description("Zoek een voertuig op nummerplaat. / Plaka ile araç ara.")]
    public async Task<string> FindVehicleByPlate(
        [Description("Nummerplaat (gedeeltelijke match) / Plaka")] string plate,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT o.insurable_object_id, o.object_type_code, o.status_code,
                   v.license_plate, v.brand, v.model, v.build_year, v.chassis_number
            FROM risk.InsurableObject  o
            INNER JOIN risk.InsurableVehicle v ON v.insurable_object_id = o.insurable_object_id
            WHERE o.tenant_id = @tenantId
              AND o.is_deleted = 0
              AND v.license_plate LIKE '%' + @plate + '%'
            ORDER BY o.created_at_utc DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql,
            new { tenantId = _ctx.TenantId, plate }, ct);

        return rows.Count == 0
            ? $"'{plate}' plakalı araç bulunamadı."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }
}
