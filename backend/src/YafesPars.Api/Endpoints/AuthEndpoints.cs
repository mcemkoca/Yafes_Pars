namespace YafesPars.Api.Endpoints;

public static class AuthEndpoints
{
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/auth").WithTags("Auth");

        group.MapGet("/config", (IConfiguration configuration) =>
        {
            var authorityConfigured = !string.IsNullOrWhiteSpace(configuration["Authentication:Authority"]);
            var audienceConfigured = !string.IsNullOrWhiteSpace(configuration["Authentication:Audience"]);

            return Results.Ok(new
            {
                jwtReady = authorityConfigured && audienceConfigured,
                authorityConfigured,
                audienceConfigured
            });
        });

        return app;
    }
}
