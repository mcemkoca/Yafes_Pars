using Microsoft.Extensions.Configuration;

namespace YafesPars.McpServer;

/// <summary>
/// Operator'ün tenant kimliğini config'den sağlar.
/// appsettings.json → McpServer:TenantId
/// </summary>
public sealed class OperatorContext
{
    public Guid TenantId { get; }

    public OperatorContext(IConfiguration config)
    {
        var raw = config["McpServer:TenantId"];
        if (!Guid.TryParse(raw, out var id))
            throw new InvalidOperationException(
                "McpServer:TenantId appsettings.json'da geçerli bir GUID olarak tanımlanmalıdır.");
        TenantId = id;
    }
}
