using Dapper;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using YafesPars.Infrastructure;
using YafesPars.McpServer;

DefaultTypeMap.MatchNamesWithUnderscores = true;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddInfrastructure();
builder.Services.AddSingleton<OperatorContext>();
builder.Services.AddSingleton<BlobStorageService>();

builder.Services
    .AddMcpServer()
    .WithStdioServerTransport()
    .WithToolsFromAssembly(typeof(Program).Assembly);

await builder.Build().RunAsync();
