using Dapper;
using YafesPars.Application.Abstractions;

namespace YafesPars.Infrastructure.Sql;

public sealed class DapperWriteRepository(ISqlConnectionFactory connectionFactory) : IWriteRepository
{
    public async Task<T?> ExecuteScalarAsync<T>(
        string sql,
        object? parameters = null,
        CancellationToken cancellationToken = default)
    {
        await using var connection = connectionFactory.Create();
        var command = new CommandDefinition(sql, parameters, cancellationToken: cancellationToken);
        return await connection.ExecuteScalarAsync<T>(command);
    }

    public async Task<int> ExecuteAsync(
        string sql,
        object? parameters = null,
        CancellationToken cancellationToken = default)
    {
        await using var connection = connectionFactory.Create();
        var command = new CommandDefinition(sql, parameters, cancellationToken: cancellationToken);
        return await connection.ExecuteAsync(command);
    }
}
