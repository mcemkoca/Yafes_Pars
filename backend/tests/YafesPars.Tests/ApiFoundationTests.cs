using Xunit;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Endpoints;
using YafesPars.Api.Security;

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
            endpoint => Assert.Contains(
                endpoint.Metadata.OfType<IAuthorizeData>(),
                authorization => authorization.Policy == "TenantUser"));
    }

    [Fact]
    public void TenantClaimResolverAcceptsValidGuid()
    {
        var expectedTenantId = Guid.NewGuid();
        var user = CreateUser(new Claim(TenantClaims.TenantIdClaimType, expectedTenantId.ToString()));

        Assert.True(TenantClaims.TryGetTenantId(user, out var actualTenantId));
        Assert.Equal(expectedTenantId, actualTenantId);
        Assert.Equal(expectedTenantId, TenantClaims.GetRequiredTenantId(user));
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("not-a-guid")]
    public void TenantClaimResolverRejectsMissingOrInvalidGuid(string? claimValue)
    {
        var claims = claimValue is null
            ? Array.Empty<Claim>()
            : new[] { new Claim(TenantClaims.TenantIdClaimType, claimValue) };
        var user = CreateUser(claims);

        Assert.False(TenantClaims.TryGetTenantId(user, out _));
        Assert.Throws<InvalidOperationException>(() => TenantClaims.GetRequiredTenantId(user));
    }

    [Fact]
    public void DatabaseHealthEndpointRequiresAuthorization()
    {
        var builder = WebApplication.CreateBuilder();
        builder.Services.AddSingleton<IReadRepository, StubReadRepository>();
        var app = builder.Build();

        app.MapHealthEndpoints();

        var endpoint = ((IEndpointRouteBuilder)app).DataSources
            .SelectMany(source => source.Endpoints)
            .OfType<RouteEndpoint>()
            .Single(candidate => candidate.RoutePattern.RawText == "/health/db");

        Assert.Contains(endpoint.Metadata, metadata => metadata is IAuthorizeData);
    }

    private static ClaimsPrincipal CreateUser(params Claim[] claims)
    {
        return new ClaimsPrincipal(new ClaimsIdentity(claims, "Test"));
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
