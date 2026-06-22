using System.Security.Claims;

namespace YafesPars.Api.Security;

public static class TenantClaims
{
    public const string TenantIdClaimType = "tenant_id";

    public static bool TryGetTenantId(ClaimsPrincipal user, out Guid tenantId)
    {
        return Guid.TryParse(user.FindFirstValue(TenantIdClaimType), out tenantId);
    }

    public static Guid GetRequiredTenantId(ClaimsPrincipal user)
    {
        if (TryGetTenantId(user, out var tenantId))
        {
            return tenantId;
        }

        throw new InvalidOperationException(
            $"Authenticated user is missing a valid {TenantIdClaimType} claim.");
    }
}
