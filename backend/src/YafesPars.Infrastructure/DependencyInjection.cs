using Dapper;
using Microsoft.Extensions.DependencyInjection;
using YafesPars.Application.Abstractions;
using YafesPars.Infrastructure.Mollie;
using YafesPars.Infrastructure.Sql;

namespace YafesPars.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services)
    {
        // DateOnly/TimeOnly handlers — anders falen alle datum-schrijfpaden via Dapper.
        SqlMapper.AddTypeHandler(new DateOnlyTypeHandler());
        SqlMapper.AddTypeHandler(new TimeOnlyTypeHandler());

        services.AddSingleton<IConnectionStringProvider, ConnectionStringProvider>();
        services.AddScoped<ISqlConnectionFactory, SqlConnectionFactory>();
        services.AddScoped<IReadRepository, DapperReadRepository>();
        services.AddScoped<IWriteRepository, DapperWriteRepository>();

        // Mollie-betalingsservice: HttpClient met base address voor testbaarheid.
        services.AddHttpClient("Mollie", c => c.BaseAddress = new Uri("https://api.mollie.com/v2/"));
        services.AddScoped<IMolliePaymentService, MolliePaymentService>();

        return services;
    }
}
