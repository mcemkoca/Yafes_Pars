using System.Text;
using System.Text.RegularExpressions;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Xunit;
using YafesPars.Application.Abstractions;
using YafesPars.Infrastructure.Sql;
using YafesPars.McpServer;

namespace YafesPars.IntegrationTests;

/// <summary>
/// Past alle migraties toe op een echte SQL Server en stelt repositories + tools
/// beschikbaar. Activeert alleen als YAFES_SQL_INTEGRATION is gezet, anders worden
/// alle tests overgeslagen (Skippable). Zo blijft lokaal `dotnet test` groen
/// zonder database, terwijl CI ze tegen een echte SQL Server draait.
/// </summary>
public sealed class SqlServerFixture : IAsyncLifetime
{
    // Demo-tenant uit migration 018__seed_demo_data.sql
    public static readonly Guid TenantId = Guid.Parse("10000000-0000-0000-0000-000000000001");

    private const string DatabaseName = "YafesPars";

    public bool Available { get; private set; }
    public string? SkipReason { get; private set; }

    private string _masterConnString = "";
    private string _dbConnString = "";

    public IWriteRepository Write { get; private set; } = null!;
    public IReadRepository Read { get; private set; } = null!;
    public OperatorContext Operator { get; private set; } = null!;

    public async Task InitializeAsync()
    {
        Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true;

        var baseConn = Environment.GetEnvironmentVariable("YAFES_SQL_INTEGRATION");
        if (string.IsNullOrWhiteSpace(baseConn))
        {
            Available = false;
            SkipReason = "YAFES_SQL_INTEGRATION niet gezet — integratietests overgeslagen.";
            return;
        }

        var masterBuilder = new SqlConnectionStringBuilder(baseConn) { InitialCatalog = "master" };
        _masterConnString = masterBuilder.ConnectionString;
        var dbBuilder = new SqlConnectionStringBuilder(baseConn) { InitialCatalog = DatabaseName };
        _dbConnString = dbBuilder.ConnectionString;

        await WaitForServerAsync();
        await ApplyMigrationsAsync();

        var factory = new FixedConnectionFactory(_dbConnString);
        Write = new DapperWriteRepository(factory);
        Read = new DapperReadRepository(factory);

        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["McpServer:TenantId"] = TenantId.ToString()
            })
            .Build();
        Operator = new OperatorContext(config);

        Available = true;
    }

    public Task DisposeAsync() => Task.CompletedTask;

    private async Task WaitForServerAsync()
    {
        var deadline = DateTime.UtcNow.AddSeconds(90);
        Exception? last = null;
        while (DateTime.UtcNow < deadline)
        {
            try
            {
                await using var conn = new SqlConnection(_masterConnString);
                await conn.OpenAsync();
                await using var cmd = new SqlCommand("SELECT 1", conn);
                await cmd.ExecuteScalarAsync();
                return;
            }
            catch (Exception ex)
            {
                last = ex;
                await Task.Delay(2000);
            }
        }
        throw new InvalidOperationException("SQL Server niet bereikbaar binnen 90s.", last);
    }

    private static string MigrationsDir()
    {
        var dir = AppContext.BaseDirectory;
        for (var i = 0; i < 12 && dir is not null; i++)
        {
            var candidate = Path.Combine(dir, "database", "migrations");
            if (Directory.Exists(candidate)) return candidate;
            dir = Path.GetDirectoryName(dir);
        }
        throw new DirectoryNotFoundException("database/migrations niet gevonden vanaf " + AppContext.BaseDirectory);
    }

    private async Task ApplyMigrationsAsync()
    {
        var files = Directory.GetFiles(MigrationsDir(), "*.sql").OrderBy(f => f, StringComparer.Ordinal).ToArray();

        // Migration 000 maakt de database aan via [master]; rest gebruikt USE [YafesPars].
        await using var conn = new SqlConnection(_masterConnString);
        await conn.OpenAsync();

        foreach (var file in files)
        {
            var sql = await File.ReadAllTextAsync(file, Encoding.UTF8);
            foreach (var batch in SplitOnGo(sql))
            {
                if (string.IsNullOrWhiteSpace(batch)) continue;
                await using var cmd = new SqlCommand(batch, conn) { CommandTimeout = 120 };
                await cmd.ExecuteNonQueryAsync();
            }
        }
    }

    private static IEnumerable<string> SplitOnGo(string sql)
    {
        // Split op een regel die alleen GO bevat (case-insensitief), zoals sqlcmd.
        return Regex.Split(sql, @"^\s*GO\s*$", RegexOptions.Multiline | RegexOptions.IgnoreCase);
    }

    private sealed class FixedConnectionFactory(string connectionString) : ISqlConnectionFactory
    {
        public SqlConnection Create() => new(connectionString);
    }
}

[CollectionDefinition("sqlserver")]
public sealed class SqlServerCollection : ICollectionFixture<SqlServerFixture>;
