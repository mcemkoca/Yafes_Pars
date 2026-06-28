using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace YafesPars.Api.Security;

/// <summary>
/// Geeft lokaal ondertekende JWT's uit (HS256) voor ontwikkeling/demo, zodat de
/// volledige API getest kan worden zonder externe IdP. In PRODUCTIE wordt een
/// echte OIDC-provider gebruikt (Authentication:Authority/Audience) en is deze
/// uitgever niet geregistreerd. Wissel = config-only.
/// </summary>
public sealed class DevTokenIssuer
{
    public const string Issuer = "yafes-pars-dev";

    private readonly string _signingKey;
    private readonly string _audience;

    public DevTokenIssuer(IConfiguration config)
    {
        _signingKey = config["Authentication:DevSigningKey"]
            ?? throw new InvalidOperationException("Authentication:DevSigningKey is vereist voor de dev-token uitgever.");
        _audience = config["Authentication:Audience"] ?? "yafes-pars-api";
    }

    public (string token, int expiresInSeconds) Issue(Guid tenantId, string role, string userName, string userId)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_signingKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, userId),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new(JwtRegisteredClaimNames.Name, userName),
            new(TenantClaims.TenantIdClaimType, tenantId.ToString()),
            new(AuthRoles.RoleClaimType, role)
        };

        const int lifetimeSeconds = 8 * 3600;
        var token = new JwtSecurityToken(
            issuer: Issuer,
            audience: _audience,
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: DateTime.UtcNow.AddSeconds(lifetimeSeconds),
            signingCredentials: creds);

        return (new JwtSecurityTokenHandler().WriteToken(token), lifetimeSeconds);
    }
}
