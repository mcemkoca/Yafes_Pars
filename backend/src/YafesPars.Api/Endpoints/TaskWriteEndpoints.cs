using System.Security.Claims;
using Microsoft.Data.SqlClient;
using YafesPars.Api.Security;
using YafesPars.Application.Abstractions;
using YafesPars.Application.Commands;
using YafesPars.Domain;

namespace YafesPars.Api.Endpoints;

public static class TaskWriteEndpoints
{
    public static IEndpointRouteBuilder MapTaskWriteEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/tasks")
            .WithTags("Tasks")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("write");

        api.MapPost("/", CreateTaskAsync)
            .WithSummary("Yeni görev oluştur");

        api.MapPost("/{taskId:guid}/comments", AddCommentAsync)
            .WithSummary("Göreve yorum ekle");

        return app;
    }

    private static async Task<IResult> CreateTaskAsync(
        CreateTaskCommand cmd,
        ClaimsPrincipal user,
        IWriteRepository repository,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(cmd.Title))
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["title"] = ["Title zorunludur."]
            });

        if (cmd.RelatedEntityType is not null
            && !DomainConstants.PolicyRelatedEntityTypes.Contains(cmd.RelatedEntityType))
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["relatedEntityType"] = [$"Geçerli değerler: {string.Join(", ", DomainConstants.PolicyRelatedEntityTypes)}"]
            });

        var tenantId = TenantClaims.GetRequiredTenantId(user);

        try
        {
            var taskId = await repository.ExecuteScalarAsync<Guid>(
                "DECLARE @id UNIQUEIDENTIFIER; " +
                "EXEC tasking.SP_CreateTask " +
                "@tenant_id, @title, @description, @task_priority_code, @related_entity_type, @related_entity_id, @assigned_to_user_id, @due_at_utc, NULL, @id OUTPUT; " +
                "SELECT @id;",
                new
                {
                    tenant_id = tenantId,
                    title = cmd.Title,
                    description = cmd.Description,
                    task_priority_code = cmd.TaskPriorityCode,
                    related_entity_type = cmd.RelatedEntityType,
                    related_entity_id = cmd.RelatedEntityId,
                    assigned_to_user_id = cmd.AssignedToUserId,
                    due_at_utc = cmd.DueAtUtc
                },
                cancellationToken);

            return Results.Created($"/api/tasks/{taskId}", new { taskId });
        }
        catch (SqlException ex) when (ex.Number >= 51600 && ex.Number < 51700)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
    }

    private static async Task<IResult> AddCommentAsync(
        Guid taskId,
        AddTaskCommentCommand cmd,
        ClaimsPrincipal user,
        IWriteRepository repository,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(cmd.Body))
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["body"] = ["Yorum metni zorunludur."]
            });

        var tenantId = TenantClaims.GetRequiredTenantId(user);

        try
        {
            await repository.ExecuteAsync(
                "EXEC tasking.SP_AddTaskComment @tenant_id, @task_id, @body, NULL;",
                new { tenant_id = tenantId, task_id = taskId, body = cmd.Body },
                cancellationToken);

            return Results.NoContent();
        }
        catch (SqlException ex) when (ex.Number >= 51600 && ex.Number < 51700)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
    }
}
