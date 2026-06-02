namespace YafesPars.Api.Endpoints;

public static class AuthEndpoints
{
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/auth").WithTags("Auth");

        group.MapGet("/config", (IConfiguration configuration) => Results.Ok(new
        {
            jwtReady = true,
            authorityConfigured = !string.IsNullOrWhiteSpace(configuration["Authentication:Authority"]),
            audienceConfigured = !string.IsNullOrWhiteSpace(configuration["Authentication:Audience"])
        }));

        return app;
    }
}
