using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
using YafesPars.Api.Endpoints;
using YafesPars.Application.Abstractions;

namespace YafesPars.Tests;

public sealed class HealthEndpointTests
{
    private static IReadOnlyList<string?> MapAndCollectRoutes()
    {
        var builder = WebApplication.CreateBuilder();
        builder.Services.AddSingleton<IReadRepository, StubReadRepository>();
        var app = builder.Build();

        app.MapHealthEndpoints();

        return ((IEndpointRouteBuilder)app).DataSources
            .SelectMany(s => s.Endpoints)
            .OfType<RouteEndpoint>()
            .Select(e => "/" + (e.RoutePattern.RawText ?? string.Empty).TrimStart('/'))
            .ToList();
    }

    [Theory]
    [InlineData("/health/live")]
    [InlineData("/health/ready")]
    [InlineData("/health/db")]
    public void HealthRoutesAreMapped(string expected)
    {
        var routes = MapAndCollectRoutes();
        Assert.Contains(expected, routes);
    }

    [Fact]
    public void RootHealthRouteExists()
    {
        // De root-route (lege pattern op de /health-groep) bestaat ook.
        var routes = MapAndCollectRoutes();
        Assert.Contains(routes, r => (r ?? "").TrimEnd('/').EndsWith("health", StringComparison.Ordinal));
    }

    private sealed class StubReadRepository : IReadRepository
    {
        public Task<IReadOnlyList<T>> QueryAsync<T>(string sql, object? parameters = null,
            CancellationToken cancellationToken = default)
            => Task.FromResult<IReadOnlyList<T>>(Array.Empty<T>());

        public Task<bool> CanConnectAsync(CancellationToken cancellationToken = default)
            => Task.FromResult(true);
    }
}
