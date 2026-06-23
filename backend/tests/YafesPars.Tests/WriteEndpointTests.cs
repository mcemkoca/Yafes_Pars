using Xunit;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using YafesPars.Api.Endpoints;
using YafesPars.Application.Abstractions;

namespace YafesPars.Tests;

public sealed class WriteEndpointTests
{
    private static WebApplication BuildApp()
    {
        var builder = WebApplication.CreateBuilder();
        builder.Services.AddSingleton<IWriteRepository, StubWriteRepository>();
        builder.Services.AddAuthorization();
        builder.Services.AddRateLimiter(_ => { });
        return builder.Build();
    }

    private static IReadOnlyList<RouteEndpoint> MapAndCollect(WebApplication app, Action<IEndpointRouteBuilder> map)
    {
        map(app);
        return ((IEndpointRouteBuilder)app).DataSources
            .SelectMany(s => s.Endpoints)
            .OfType<RouteEndpoint>()
            .Where(e => e.RoutePattern.RawText?.StartsWith("/api/", StringComparison.Ordinal) == true)
            .ToList();
    }

    [Fact]
    public void FinanceEndpointsRequireAuthorization()
    {
        var app = BuildApp();
        var endpoints = MapAndCollect(app, e => e.MapFinanceWriteEndpoints());

        Assert.NotEmpty(endpoints);
        Assert.All(endpoints, e => Assert.Contains(
            e.Metadata.OfType<IAuthorizeData>(),
            a => a.Policy == "TenantUser"));
    }

    [Fact]
    public void DocumentEndpointsRequireAuthorization()
    {
        var app = BuildApp();
        var endpoints = MapAndCollect(app, e => e.MapDocumentWriteEndpoints());

        Assert.NotEmpty(endpoints);
        Assert.All(endpoints, e => Assert.Contains(
            e.Metadata.OfType<IAuthorizeData>(),
            a => a.Policy == "TenantUser"));
    }

    [Fact]
    public void CoverageEndpointsRequireAuthorization()
    {
        var app = BuildApp();
        var endpoints = MapAndCollect(app, e => e.MapCoverageWriteEndpoints());

        Assert.NotEmpty(endpoints);
        Assert.All(endpoints, e => Assert.Contains(
            e.Metadata.OfType<IAuthorizeData>(),
            a => a.Policy == "TenantUser"));
    }

    [Fact]
    public void RiskEndpointsRequireAuthorization()
    {
        var app = BuildApp();
        var endpoints = MapAndCollect(app, e => e.MapRiskWriteEndpoints());

        Assert.NotEmpty(endpoints);
        Assert.All(endpoints, e => Assert.Contains(
            e.Metadata.OfType<IAuthorizeData>(),
            a => a.Policy == "TenantUser"));
    }

    [Theory]
    [InlineData("/api/finance/invoices")]
    [InlineData("/api/finance/payment-plans")]
    [InlineData("/api/documents")]
    [InlineData("/api/documents/links")]
    [InlineData("/api/coverage/items")]
    [InlineData("/api/risk/objects")]
    [InlineData("/api/risk/vehicles")]
    [InlineData("/api/risk/properties")]
    [InlineData("/api/risk/links")]
    public void ExpectedPostRoutesExist(string expectedPath)
    {
        var app = BuildApp();
        app.MapFinanceWriteEndpoints();
        app.MapDocumentWriteEndpoints();
        app.MapCoverageWriteEndpoints();
        app.MapRiskWriteEndpoints();

        var routes = ((IEndpointRouteBuilder)app).DataSources
            .SelectMany(s => s.Endpoints)
            .OfType<RouteEndpoint>()
            .Select(e => e.RoutePattern.RawText)
            .ToHashSet();

        Assert.Contains(expectedPath.TrimStart('/'), routes.Select(r => r?.TrimStart('/')));
    }

    // ── Stub ──────────────────────────────────────────────────────────────────
    private sealed class StubWriteRepository : IWriteRepository
    {
        public Task<T?> ExecuteScalarAsync<T>(string sql, object? parameters = null,
            CancellationToken cancellationToken = default)
            => Task.FromResult(default(T));

        public Task<int> ExecuteAsync(string sql, object? parameters = null,
            CancellationToken cancellationToken = default)
            => Task.FromResult(0);
    }
}
