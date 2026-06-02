using Microsoft.Data.SqlClient;

namespace YafesPars.Infrastructure.Sql;

public interface ISqlConnectionFactory
{
    SqlConnection Create();
}
