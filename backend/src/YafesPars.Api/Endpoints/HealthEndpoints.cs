using YafesPars.Application.Abstractions;

namespace YafesPars.Api.Endpoints;

public static class HealthEndpoints
{
    public static IEndpointRouteBuilder MapHealthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/health").WithTags("Health");

        group.MapGet("", () => Results.Ok(new
        {
            status = "ok",
            service = "YafesPars.Api",
            utc = DateTimeOffset.UtcNow
        }));

        group.MapGet("/db", async (IReadRepository repository, CancellationToken cancellationToken) =>
        {
            var canConnect = await repository.CanConnectAsync(cancellationToken);
            return canConnect
                ? Results.Ok(new { status = "ok", database = "reachable" })
                : Results.Problem("Database connectivity check failed.");
        });

        return app;
    }
}
