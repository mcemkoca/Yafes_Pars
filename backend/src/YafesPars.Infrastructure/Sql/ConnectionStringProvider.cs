using Microsoft.Extensions.Configuration;

namespace YafesPars.Infrastructure.Sql;

public sealed class ConnectionStringProvider(IConfiguration configuration) : IConnectionStringProvider
{
    public string GetConnectionString()
    {
        var value =
            configuration.GetConnectionString("YafesPars")
            ?? configuration["YAFES_SQL_CONNECTION_STRING"];

        if (string.IsNullOrWhiteSpace(value))
        {
            throw new InvalidOperationException(
                "Configure ConnectionStrings:YafesPars or YAFES_SQL_CONNECTION_STRING.");
        }

        return value;
    }
}
