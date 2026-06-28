using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Xunit;
using YafesPars.Api.Security;

namespace YafesPars.Tests;

public sealed class AuthTests
{
    private const string DevKey = "dev-only-signing-key-change-me-32+bytes-yafespars-2026";

    private static IConfiguration Config() => new ConfigurationBuilder()
        .AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Authentication:DevSigningKey"] = DevKey,
            ["Authentication:Audience"] = "yafes-pars-api"
        })
        .Build();

    [Fact]
    public void DevTokenIssuer_EmitsTenantAndRoleClaims()
    {
        var issuer = new DevTokenIssuer(Config());
        var tenantId = Guid.NewGuid();

        var (token, expiresIn) = issuer.Issue(tenantId, AuthRoles.Operator, "Demo Operator", "user-1");

        Assert.True(expiresIn > 0);
        var jwt = new JwtSecurityTokenHandler().ReadJwtToken(token);
        Assert.Equal(DevTokenIssuer.Issuer, jwt.Issuer);
        Assert.Equal(tenantId.ToString(), jwt.Claims.First(c => c.Type == TenantClaims.TenantIdClaimType).Value);
        Assert.Equal(AuthRoles.Operator, jwt.Claims.First(c => c.Type == AuthRoles.RoleClaimType).Value);
    }

    [Fact]
    public void IssuedToken_ValidatesAgainstSameKey()
    {
        var issuer = new DevTokenIssuer(Config());
        var (token, _) = issuer.Issue(Guid.NewGuid(), AuthRoles.Admin, "Beheerder", "user-2");

        var parameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = DevTokenIssuer.Issuer,
            ValidateAudience = true,
            ValidAudience = "yafes-pars-api",
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(DevKey)),
            ValidateLifetime = true,
            RoleClaimType = AuthRoles.RoleClaimType
        };

        var handler = new JwtSecurityTokenHandler { MapInboundClaims = false };
        var principal = handler.ValidateToken(token, parameters, out _);

        Assert.True(principal.Identity?.IsAuthenticated);
        Assert.True(TenantClaims.TryGetTenantId(principal, out var tenantId));
        Assert.NotEqual(Guid.Empty, tenantId);
        Assert.True(principal.IsInRole(AuthRoles.Admin));
    }

    [Fact]
    public void TamperedToken_FailsValidation()
    {
        var issuer = new DevTokenIssuer(Config());
        var (token, _) = issuer.Issue(Guid.NewGuid(), AuthRoles.Operator, "Demo", "user-3");

        var tampered = token[..^4] + "AAAA";
        var parameters = new TokenValidationParameters
        {
            ValidIssuer = DevTokenIssuer.Issuer,
            ValidAudience = "yafes-pars-api",
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(DevKey)),
            RoleClaimType = AuthRoles.RoleClaimType
        };

        Assert.ThrowsAny<Exception>(() =>
            new JwtSecurityTokenHandler().ValidateToken(tampered, parameters, out _));
    }

    [Fact]
    public void DevTokenIssuer_RequiresSigningKey()
    {
        var empty = new ConfigurationBuilder().Build();
        Assert.Throws<InvalidOperationException>(() => new DevTokenIssuer(empty));
    }
}
