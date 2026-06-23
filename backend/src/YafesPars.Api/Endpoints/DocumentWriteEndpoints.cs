using Microsoft.Data.SqlClient;
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

        api.MapPost("/", async (CreateDocumentCommand cmd, IWriteRepository repo) =>
        {
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "EXEC document.sp_CreateDocument @DocumentTypeCode, @FileName, @MimeType, @FileSizeBytes, @StorageUri, @Description",
                    new { cmd.DocumentTypeCode, cmd.FileName, cmd.MimeType, cmd.FileSizeBytes, cmd.StorageUri, cmd.Description });
                return Results.Created($"/api/documents/{id}", new { documentId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51800 and <= 51830)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/links", async (LinkDocumentCommand cmd, IWriteRepository repo) =>
        {
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC document.sp_LinkDocument @DocumentId, @EntityType, @EntityId",
                    new { cmd.DocumentId, cmd.EntityType, cmd.EntityId });
                return Results.NoContent();
            }
            catch (SqlException ex) when (ex.Number is >= 51800 and <= 51830)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/{documentId:guid}/archive", async (Guid documentId, ArchiveDocumentCommand cmd, IWriteRepository repo) =>
        {
            if (cmd.DocumentId != documentId)
                return Results.BadRequest(new { error = "Route documentId must match body DocumentId." });
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC document.sp_ArchiveDocument @DocumentId, @Reason",
                    new { cmd.DocumentId, cmd.Reason });
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
