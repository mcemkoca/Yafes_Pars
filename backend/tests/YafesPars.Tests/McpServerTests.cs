using System.Reflection;
using Xunit;
using ModelContextProtocol.Server;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;
using YafesPars.McpServer.Tools;

namespace YafesPars.Tests;

file sealed class McpStubReadRepository : IReadRepository
{
    public Task<IReadOnlyList<T>> QueryAsync<T>(string sql, object? parameters = null, CancellationToken cancellationToken = default)
        => Task.FromResult<IReadOnlyList<T>>(Array.Empty<T>());
    public Task<bool> CanConnectAsync(CancellationToken cancellationToken = default) => Task.FromResult(true);
}

file sealed class McpStubWriteRepository : IWriteRepository
{
    public Task<int> ExecuteAsync(string sql, object? parameters = null, CancellationToken cancellationToken = default) => Task.FromResult(0);
    public Task<T?> ExecuteScalarAsync<T>(string sql, object? parameters = null, CancellationToken cancellationToken = default) => Task.FromResult(default(T?));
}

public sealed class McpServerTests
{
    private static IServiceProvider BuildServices()
    {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["McpServer:TenantId"]             = "00000000-0000-0000-0000-000000000001",
                ["AzureStorage:ConnectionString"]  = "",
                ["AzureStorage:ContainerName"]     = "documents",
                ["ConnectionStrings:YafesPars"]    = "Server=.;Database=YafesPars;Integrated Security=True;"
            })
            .Build();

        var services = new ServiceCollection();
        services.AddSingleton<IConfiguration>(config);
        services.AddSingleton<IReadRepository, McpStubReadRepository>();
        services.AddSingleton<IWriteRepository, McpStubWriteRepository>();
        services.AddSingleton<OperatorContext>();
        services.AddSingleton<BlobStorageService>();
        return services.BuildServiceProvider();
    }

    [Fact]
    public void OperatorContext_ParsesTenantId()
    {
        var sp = BuildServices();
        var ctx = sp.GetRequiredService<OperatorContext>();
        Assert.Equal(Guid.Parse("00000000-0000-0000-0000-000000000001"), ctx.TenantId);
    }

    [Fact]
    public void BlobStorageService_NotConfigured_WhenConnectionStringEmpty()
    {
        var sp = BuildServices();
        var blob = sp.GetRequiredService<BlobStorageService>();
        Assert.False(blob.IsConfigured);
    }

    [Fact]
    public void McpServerAssembly_HasExpectedToolTypes()
    {
        var assembly = typeof(DashboardTools).Assembly;
        var toolTypes = assembly.GetTypes()
            .Where(t => t.GetCustomAttribute<McpServerToolTypeAttribute>() != null)
            .Select(t => t.Name)
            .OrderBy(n => n)
            .ToList();

        Assert.Contains("DashboardTools",    toolTypes);
        Assert.Contains("PersonTools",       toolTypes);
        Assert.Contains("PersonWriteTools",  toolTypes);
        Assert.Contains("PolicyTools",       toolTypes);
        Assert.Contains("PolicyWriteTools",  toolTypes);
        Assert.Contains("ClaimTools",        toolTypes);
        Assert.Contains("FinanceTools",      toolTypes);
        Assert.Contains("RiskTools",         toolTypes);
        Assert.Contains("DocumentTools",     toolTypes);
        Assert.Contains("TaskTools",         toolTypes);
        Assert.Contains("AzureTools",        toolTypes);
    }

    [Fact]
    public void McpServerAssembly_AllToolMethods_HaveDescriptions()
    {
        var assembly = typeof(DashboardTools).Assembly;
        var toolTypes = assembly.GetTypes()
            .Where(t => t.GetCustomAttribute<McpServerToolTypeAttribute>() != null);

        var missing = new List<string>();
        foreach (var type in toolTypes)
        {
            foreach (var method in type.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly))
            {
                if (method.GetCustomAttribute<McpServerToolAttribute>() == null) continue;
                var desc = method.GetCustomAttribute<System.ComponentModel.DescriptionAttribute>();
                if (desc == null || string.IsNullOrWhiteSpace(desc.Description))
                    missing.Add($"{type.Name}.{method.Name}");
            }
        }

        Assert.Empty(missing);
    }

    [Fact]
    public void McpServerAssembly_ToolCount_AtLeast20()
    {
        var assembly = typeof(DashboardTools).Assembly;
        var count = assembly.GetTypes()
            .Where(t => t.GetCustomAttribute<McpServerToolTypeAttribute>() != null)
            .SelectMany(t => t.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly))
            .Count(m => m.GetCustomAttribute<McpServerToolAttribute>() != null);

        Assert.True(count >= 20, $"Verwacht minstens 20 tools, gevonden: {count}");
    }

    [Fact]
    public void DashboardTools_CanBeConstructed()
    {
        var sp = BuildServices();
        var tool = ActivatorUtilities.CreateInstance<DashboardTools>(sp);
        Assert.NotNull(tool);
    }

    [Fact]
    public void PersonWriteTools_CanBeConstructed()
    {
        var sp = BuildServices();
        var tool = ActivatorUtilities.CreateInstance<PersonWriteTools>(sp);
        Assert.NotNull(tool);
    }

    [Fact]
    public void AzureTools_CanBeConstructed()
    {
        var sp = BuildServices();
        var tool = ActivatorUtilities.CreateInstance<AzureTools>(sp);
        Assert.NotNull(tool);
    }

    [Fact]
    public void DocumentTools_CanBeConstructed()
    {
        var sp = BuildServices();
        var tool = ActivatorUtilities.CreateInstance<DocumentTools>(sp);
        Assert.NotNull(tool);
    }
}
