using Microsoft.Data.SqlClient;

namespace YafesPars.Infrastructure.Sql;

public sealed class SqlConnectionFactory(IConnectionStringProvider connectionStringProvider) : ISqlConnectionFactory
{
    public SqlConnection Create()
    {
        return new SqlConnection(connectionStringProvider.GetConnectionString());
    }
}
