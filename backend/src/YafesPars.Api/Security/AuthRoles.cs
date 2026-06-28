namespace YafesPars.Api.Security;

/// <summary>
/// RBAC-rollen + autorisatiebeleid-namen. De role-claim heet "role"
/// (TokenValidationParameters.RoleClaimType in Program.cs).
/// </summary>
public static class AuthRoles
{
    public const string Operator = "operator";   // dagelijkse operator
    public const string Admin    = "admin";       // tenant-beheerder
    public const string Auditor  = "auditor";     // alleen-lezen / compliance

    public const string RoleClaimType = "role";

    // Policy-namen
    public const string TenantUserPolicy = "TenantUser";
    public const string AdminPolicy      = "Admin";
    public const string AuditorPolicy    = "Auditor";
}
