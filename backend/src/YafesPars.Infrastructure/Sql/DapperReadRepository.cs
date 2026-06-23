using Dapper;
using YafesPars.Application.Abstractions;

namespace YafesPars.Infrastructure.Sql;

public sealed class DapperReadRepository(ISqlConnectionFactory connectionFactory) : IReadRepository
{
    public async Task<IReadOnlyList<T>> QueryAsync<T>(
        string sql,
        object? parameters = null,
        CancellationToken cancellationToken = default)
    {
        await using var connection = connectionFactory.Create();
        var command = new CommandDefinition(sql, parameters, cancellationToken: cancellationToken);
        var rows = await connection.QueryAsync<T>(command);
        return rows.AsList();
    }

    public async Task<bool> CanConnectAsync(CancellationToken cancellationToken = default)
    {
        await using var connection = connectionFactory.Create();
        var command = new CommandDefinition("SELECT 1", cancellationToken: cancellationToken);
        var value = await connection.ExecuteScalarAsync<int>(command);
        return value == 1;
    }
}
