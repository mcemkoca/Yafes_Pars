using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class AuthEndpoints
{
    // Demo-tenant uit migration 018__seed_demo_data.sql
    private static readonly Guid DemoTenantId = Guid.Parse("10000000-0000-0000-0000-000000000001");

    public sealed record DevTokenRequest(Guid? TenantId, string? Role, string? UserName, string? UserId);

    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/auth").WithTags("Auth");

        group.MapGet("/config", (IConfiguration configuration) =>
        {
            var authorityConfigured = !string.IsNullOrWhiteSpace(configuration["Authentication:Authority"]);
            var audienceConfigured = !string.IsNullOrWhiteSpace(configuration["Authentication:Audience"]);
            var devTokenEnabled = !string.IsNullOrWhiteSpace(configuration["Authentication:DevSigningKey"]);

            return Results.Ok(new
            {
                jwtReady = (authorityConfigured && audienceConfigured) || devTokenEnabled,
                authorityConfigured,
                audienceConfigured,
                devTokenEnabled,
                mode = devTokenEnabled ? "development" : "external-idp"
            });
        });

        // Development/demo: lokaal ondertekende token uitgeven. Alleen beschikbaar
        // als Authentication:DevSigningKey is gezet (nooit in PROD-config).
        group.MapPost("/dev-token", (
            DevTokenRequest? request,
            IConfiguration configuration,
            IServiceProvider services) =>
        {
            if (string.IsNullOrWhiteSpace(configuration["Authentication:DevSigningKey"]))
                return Results.NotFound(new { error = "Dev-token uitgifte is uitgeschakeld." });

            var issuer = new DevTokenIssuer(configuration);
            var tenantId = request?.TenantId ?? DemoTenantId;
            var role = string.IsNullOrWhiteSpace(request?.Role) ? AuthRoles.Operator : request!.Role!;
            var userName = string.IsNullOrWhiteSpace(request?.UserName) ? "Demo Operator" : request!.UserName!;
            var userId = string.IsNullOrWhiteSpace(request?.UserId) ? Guid.NewGuid().ToString() : request!.UserId!;

            var (token, expiresIn) = issuer.Issue(tenantId, role, userName, userId);

            return Results.Ok(new
            {
                accessToken = token,
                tokenType = "Bearer",
                expiresIn,
                tenantId,
                role,
                userName
            });
        })
        .WithSummary("Ontwikkel-token uitgeven (alleen met DevSigningKey)")
        .AllowAnonymous();

        return app;
    }
}
