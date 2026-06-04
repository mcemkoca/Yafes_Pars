using Xunit;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Endpoints;

namespace YafesPars.Tests;

public sealed class ApiFoundationTests
{
    [Fact]
    public void ApiAssemblyIsDiscoverable()
    {
        Assert.Equal("YafesPars.Api", typeof(Program).Assembly.GetName().Name);
    }

    [Fact]
    public void DomainReadEndpointsRequireAuthorization()
    {
        var builder = WebApplication.CreateBuilder();
        builder.Services.AddSingleton<IReadRepository, StubReadRepository>();
        var app = builder.Build();

        app.MapDomainReadEndpoints();

        var endpoints = ((IEndpointRouteBuilder)app).DataSources
            .SelectMany(source => source.Endpoints)
            .OfType<RouteEndpoint>()
            .Where(endpoint => endpoint.RoutePattern.RawText?.StartsWith("/api/", StringComparison.Ordinal) == true)
            .ToList();

        Assert.NotEmpty(endpoints);
        Assert.All(
            endpoints,
            endpoint => Assert.Contains(endpoint.Metadata, metadata => metadata is IAuthorizeData));
    }

    private sealed class StubReadRepository : IReadRepository
    {
        public Task<IReadOnlyList<T>> QueryAsync<T>(
            string sql,
            object? parameters = null,
            CancellationToken cancellationToken = default)
        {
            return Task.FromResult<IReadOnlyList<T>>(Array.Empty<T>());
        }

        public Task<bool> CanConnectAsync(CancellationToken cancellationToken = default)
        {
            return Task.FromResult(true);
        }
    }
}
