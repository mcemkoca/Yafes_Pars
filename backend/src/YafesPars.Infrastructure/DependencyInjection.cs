using Microsoft.Extensions.DependencyInjection;
using YafesPars.Application.Abstractions;
using YafesPars.Infrastructure.Sql;

namespace YafesPars.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services)
    {
        services.AddSingleton<IConnectionStringProvider, ConnectionStringProvider>();
        services.AddScoped<ISqlConnectionFactory, SqlConnectionFactory>();
        services.AddScoped<IReadRepository, DapperReadRepository>();
        return services;
    }
}
