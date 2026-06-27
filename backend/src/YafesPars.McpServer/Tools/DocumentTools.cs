using System.ComponentModel;
using System.Text.Json;
using Microsoft.Data.SqlClient;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class DocumentTools
{
    private readonly IWriteRepository _write;
    private readonly IReadRepository _read;
    private readonly OperatorContext _ctx;
    private readonly BlobStorageService _blob;

    public DocumentTools(IWriteRepository write, IReadRepository read, OperatorContext ctx, BlobStorageService blob)
    {
        _write = write;
        _read = read;
        _ctx = ctx;
        _blob = blob;
    }

    [McpServerTool, Description(
        "Registreer een document en sla de inhoud op. / Belge kaydet ve içeriği yükle.\n" +
        "Geef bestandsinhoud mee als base64 of als opslagpad (Azure Blob URI).\n" +
        "Eigenaartypes: POLICY (polis), CLAIM (schade), PERSON (klant), RISK_OBJECT (object).\n" +
        "Documenttypes: CONTRACT, ID_CARD, INVOICE, DAMAGE_REPORT, PHOTO, OTHER.")]
    public async Task<string> UploadDocument(
        [Description("Bestandsnaam met extensie bijv. polis_2024.pdf / Dosya adı")] string fileName = "",
        [Description("Documenttype: CONTRACT, ID_CARD, INVOICE, DAMAGE_REPORT, PHOTO, OTHER")] string documentTypeCode = "OTHER",
        [Description("Eigenaartype: POLICY, CLAIM, PERSON, RISK_OBJECT")] string ownerEntityType = "POLICY",
        [Description("Eigenaar-ID (UUID van de polis, klant, schade, ...) / Sahip ID")] Guid ownerEntityId = default,
        [Description("MIME-type bijv. application/pdf, image/jpeg")] string? mimeType = null,
        [Description("Bestandsinhoud als base64 (optioneel bij URI) / Base64 içerik")] string? contentBase64 = null,
        [Description("Azure Blob Storage URI (alternatief voor base64) / Depolama adresi")] string? storageUri = null,
        [Description("Bestandsgrootte in bytes / Dosya boyutu")] long? fileSizeBytes = null,
        [Description("Beschrijving / Açıklama")] string? description = null,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(fileName))
            return "Fout: bestandsnaam is verplicht.";
        if (ownerEntityId == default)
            return "Fout: eigenaar-ID (ownerEntityId) is verplicht.";

        var resolvedUri = storageUri;
        var resolvedSize = fileSizeBytes;

        if (!string.IsNullOrWhiteSpace(contentBase64) && string.IsNullOrWhiteSpace(storageUri))
        {
            byte[] bytes;
            try { bytes = Convert.FromBase64String(contentBase64); }
            catch { return "Fout: ongeldige base64-inhoud."; }

            if (_blob.IsConfigured)
            {
                try
                {
                    var (uri, size) = await _blob.UploadAsync(fileName, bytes, mimeType, _ctx.TenantId, ct);
                    resolvedUri  = uri;
                    resolvedSize = size;
                }
                catch (Exception ex)
                {
                    return $"Azure Blob upload mislukt: {ex.Message}";
                }
            }
            else
            {
                resolvedSize ??= bytes.Length;
                resolvedUri = $"local://{_ctx.TenantId}/{Guid.NewGuid()}/{fileName}";
            }
        }

        try
        {
            var documentId = await _write.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC document.sp_CreateDocument " +
                "@tenant_id, @document_type_code, @file_name, @mime_type, @file_size_bytes, @storage_uri, @description, NULL, @owner_entity_type, @owner_entity_id, @id OUTPUT; " +
                "SELECT @id;",
                new
                {
                    tenant_id = _ctx.TenantId,
                    document_type_code = documentTypeCode,
                    file_name = fileName,
                    mime_type = mimeType,
                    file_size_bytes = resolvedSize,
                    storage_uri = resolvedUri,
                    description,
                    owner_entity_type = ownerEntityType,
                    owner_entity_id = ownerEntityId
                },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                documentId,
                message = $"Document '{fileName}' geregistreerd (ID: {documentId})."
            }, JsonOpts.Default);
        }
        catch (SqlException ex) when (ex.Number == 51812)
        {
            return $"Ongeldig eigenaartype: '{ownerEntityType}'. Gebruik POLICY, CLAIM, PERSON of RISK_OBJECT.";
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Koppel een bestaand document aan een extra entiteit. / Mevcut belgeyi ek bir varlığa bağla.\n" +
        "Bijv. één document koppelen aan zowel een polis als een schadedossier.")]
    public async Task<string> LinkDocument(
        [Description("Document-ID (UUID)")] Guid documentId = default,
        [Description("Entiteittype: POLICY, CLAIM, PERSON, RISK_OBJECT")] string entityType = "",
        [Description("Entiteit-ID (UUID)")] Guid entityId = default,
        CancellationToken ct = default)
    {
        if (documentId == default || string.IsNullOrWhiteSpace(entityType) || entityId == default)
            return "Fout: documentId, entityType en entityId zijn verplicht.";

        try
        {
            await _write.ExecuteAsync(
                "EXEC document.sp_LinkDocument @tenant_id, @document_id, @entity_type, @entity_id;",
                new
                {
                    tenant_id = _ctx.TenantId,
                    document_id = documentId,
                    entity_type = entityType,
                    entity_id = entityId
                },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                message = $"Document {documentId} gekoppeld aan {entityType} {entityId}."
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Archiveer (deactiveer) een document. / Belgeyi arşivle.\n" +
        "Gearchiveerde documenten zijn niet meer zichtbaar in standaard zoekopdrachten.")]
    public async Task<string> ArchiveDocument(
        [Description("Document-ID om te archiveren (UUID)")] Guid documentId = default,
        CancellationToken ct = default)
    {
        if (documentId == default)
            return "Fout: documentId is verplicht.";

        try
        {
            await _write.ExecuteAsync(
                "EXEC document.sp_ArchiveDocument @tenant_id, @document_id, NULL;",
                new { tenant_id = _ctx.TenantId, document_id = documentId },
                ct);

            return JsonSerializer.Serialize(new
            {
                success = true,
                message = $"Document {documentId} gearchiveerd."
            }, JsonOpts.Default);
        }
        catch (SqlException ex)
        {
            return $"Databasefout {ex.Number}: {ex.Message}";
        }
    }

    [McpServerTool, Description(
        "Zoek documenten op basis van eigenaar of type. / Belge ara.\n" +
        "Filter op entiteittype+ID of documenttype.")]
    public async Task<string> SearchDocuments(
        [Description("Eigenaartype: POLICY, CLAIM, PERSON, RISK_OBJECT (optioneel)")] string? ownerEntityType = null,
        [Description("Eigenaar-ID (UUID, optioneel)")] Guid? ownerEntityId = null,
        [Description("Documenttype: CONTRACT, ID_CARD, INVOICE, enz. (optioneel)")] string? documentTypeCode = null,
        [Description("Max resultaten (standaard 20)")] int limit = 20,
        CancellationToken ct = default)
    {
        var sql = """
            SELECT TOP (@limit)
                d.document_id, d.document_type_code, d.file_name, d.mime_type,
                d.file_size_bytes, d.storage_uri, d.description,
                d.owner_entity_type, d.owner_entity_id,
                d.created_at_utc
            FROM document.Document d
            WHERE d.tenant_id = @tenantId
              AND d.is_archived = 0
              AND (@ownerEntityType IS NULL OR d.owner_entity_type = @ownerEntityType)
              AND (@ownerEntityId   IS NULL OR d.owner_entity_id   = @ownerEntityId)
              AND (@docType         IS NULL OR d.document_type_code = @docType)
            ORDER BY d.created_at_utc DESC
            """;

        var rows = await _read.QueryAsync<dynamic>(sql,
            new { tenantId = _ctx.TenantId, ownerEntityType, ownerEntityId, docType = documentTypeCode, limit }, ct);

        return rows.Count == 0
            ? "Geen documenten gevonden. / Belge bulunamadı."
            : JsonSerializer.Serialize(rows, JsonOpts.Default);
    }
}
