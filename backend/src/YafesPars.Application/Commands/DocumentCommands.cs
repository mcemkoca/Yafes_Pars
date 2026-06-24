namespace YafesPars.Application.Commands;

public sealed record CreateDocumentCommand(
    string DocumentTypeCode,
    string FileName,
    string? MimeType,
    long? FileSizeBytes,
    string? StorageUri,
    string? Description
);

public sealed record LinkDocumentCommand(
    Guid DocumentId,
    string EntityType,
    Guid EntityId
);

public sealed record ArchiveDocumentCommand(
    Guid DocumentId,
    string? Reason
);
