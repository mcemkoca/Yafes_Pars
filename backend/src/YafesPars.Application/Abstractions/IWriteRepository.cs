namespace YafesPars.Application.Abstractions;

public interface IWriteRepository
{
    Task<T?> ExecuteScalarAsync<T>(string sql, object? parameters = null, CancellationToken cancellationToken = default);
    Task<int> ExecuteAsync(string sql, object? parameters = null, CancellationToken cancellationToken = default);
}
