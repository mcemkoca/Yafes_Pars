using YafesPars.Application.Abstractions;

namespace YafesPars.Api.Endpoints;

public static class HealthEndpoints
{
    public static IEndpointRouteBuilder MapHealthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/health").WithTags("Health");

        // Basis-status (compat).
        group.MapGet("", () => Results.Ok(new
        {
            status = "ok",
            service = "YafesPars.Api",
            utc = DateTimeOffset.UtcNow
        })).AllowAnonymous();

        // Liveness — proces draait. Geen afhankelijkheden. Voor App Service /
        // k8s livenessProbe: 200 zolang het proces gezond is.
        group.MapGet("/live", () => Results.Ok(new
        {
            status = "alive",
            service = "YafesPars.Api",
            utc = DateTimeOffset.UtcNow
        })).AllowAnonymous();

        // Readiness — afhankelijkheden (database) bereikbaar. 503 wanneer niet,
        // zodat de load balancer / k8s readinessProbe geen verkeer stuurt.
        group.MapGet("/ready", async (IReadRepository repository, CancellationToken cancellationToken) =>
        {
            bool dbReachable;
            try
            {
                dbReachable = await repository.CanConnectAsync(cancellationToken);
            }
            catch
            {
                dbReachable = false;
            }

            var payload = new { status = dbReachable ? "ready" : "not-ready", database = dbReachable ? "reachable" : "unreachable" };

            return dbReachable
                ? Results.Ok(payload)
                : Results.Json(payload, statusCode: StatusCodes.Status503ServiceUnavailable);
        }).AllowAnonymous();

        // Backwards-compatibele DB-check.
        group.MapGet("/db", async (IReadRepository repository, CancellationToken cancellationToken) =>
        {
            var canConnect = await repository.CanConnectAsync(cancellationToken);
            return canConnect
                ? Results.Ok(new { status = "ok", database = "reachable" })
                : Results.Problem("Database connectivity check failed.");
        }).AllowAnonymous();

        return app;
    }
}
