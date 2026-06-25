using System.Security.Claims;
using Microsoft.Data.SqlClient;
using YafesPars.Api.Security;
using YafesPars.Application.Commands;
using YafesPars.Application.Abstractions;

namespace YafesPars.Api.Endpoints;

public static class DocumentWriteEndpoints
{
    public static IEndpointRouteBuilder MapDocumentWriteEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/documents")
            .WithTags("Documents")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("write");

        api.MapPost("", async (CreateDocumentCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "DECLARE @id UNIQUEIDENTIFIER; " +
                    "EXEC document.sp_CreateDocument @tenant_id, @document_type_code, @file_name, @mime_type, @file_size_bytes, @storage_uri, @description, NULL, @owner_entity_type, @owner_entity_id, @id OUTPUT; " +
                    "SELECT @id;",
                    new { tenant_id = tenantId, document_type_code = cmd.DocumentTypeCode, file_name = cmd.FileName, mime_type = cmd.MimeType, file_size_bytes = cmd.FileSizeBytes, storage_uri = cmd.StorageUri, description = cmd.Description, owner_entity_type = cmd.OwnerEntityType, owner_entity_id = cmd.OwnerEntityId },
                    ct);
                return Results.Created($"/api/documents/{id}", new { documentId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51800 and <= 51830)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/links", async (LinkDocumentCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC document.sp_LinkDocument @tenant_id, @document_id, @entity_type, @entity_id;",
                    new { tenant_id = tenantId, document_id = cmd.DocumentId, entity_type = cmd.EntityType, entity_id = cmd.EntityId },
                    ct);
                return Results.NoContent();
            }
            catch (SqlException ex) when (ex.Number is >= 51800 and <= 51830)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/{documentId:guid}/archive", async (Guid documentId, ArchiveDocumentCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            if (cmd.DocumentId != documentId)
                return Results.BadRequest(new { error = "Route documentId must match body DocumentId." });
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC document.sp_ArchiveDocument @tenant_id, @document_id, @reason;",
                    new { tenant_id = tenantId, document_id = cmd.DocumentId, reason = cmd.Reason },
                    ct);
                return Results.NoContent();
            }
            catch (SqlException ex) when (ex.Number is >= 51800 and <= 51830)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        return app;
    }
}
