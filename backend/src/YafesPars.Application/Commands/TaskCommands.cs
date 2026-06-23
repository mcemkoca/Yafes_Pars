namespace YafesPars.Application.Commands;

public sealed record CreateTaskCommand(
    string Title,
    string? Description,
    string TaskPriorityCode,
    string? RelatedEntityType,
    Guid? RelatedEntityId,
    Guid? AssignedToUserId,
    DateTime? DueAtUtc
);

public sealed record AddTaskCommentCommand(
    Guid TaskId,
    string Body
);
