using System.ComponentModel;
using System.Diagnostics;
using System.Text;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class AzureTools
{
    private readonly OperatorContext _ctx;

    public AzureTools(OperatorContext ctx)
    {
        _ctx = ctx;
    }

    [McpServerTool, Description(
        "Controleer of Azure CLI en aanmeldstatus beschikbaar zijn. / Azure CLI ve giriş durumunu kontrol et.\n" +
        "Voer dit altijd eerst uit voordat je gaat deployen.")]
    public async Task<string> CheckAzureStatus(CancellationToken ct = default)
    {
        var results = new Dictionary<string, object>();

        var (azVer, azErr) = await RunAsync("az", "--version", ct);
        results["az_cli"] = azErr == null ? "beschikbaar" : $"niet gevonden: {azErr}";

        var (account, accountErr) = await RunAsync("az", "account show --output json", ct);
        if (accountErr == null && !string.IsNullOrWhiteSpace(account))
        {
            try
            {
                var doc = JsonDocument.Parse(account);
                results["aangemeld_als"] = doc.RootElement.TryGetProperty("user", out var u)
                    ? u.GetProperty("name").GetString() ?? "onbekend"
                    : "onbekend";
                results["abonnement"] = doc.RootElement.TryGetProperty("name", out var n)
                    ? n.GetString() ?? ""
                    : "";
            }
            catch { results["aangemeld_als"] = "parse fout"; }
        }
        else
        {
            results["aangemeld_als"] = "niet aangemeld — voer 'az login' uit";
        }

        var (dotnet, _) = await RunAsync("dotnet", "--version", ct);
        results["dotnet_versie"] = dotnet?.Trim() ?? "niet gevonden";

        return JsonSerializer.Serialize(results, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Meld aan bij Azure via apparaatcode (device code flow). / Azure'a cihaz kodu ile giriş yap.\n" +
        "De gebruiker krijgt een URL en code te zien om in te loggen in de browser.\n" +
        "Gebruik dit als eerste stap bij een nieuwe Azure-deployment.")]
    public async Task<string> AzureLogin(CancellationToken ct = default)
    {
        var (output, err) = await RunAsync("az", "login --use-device-code --output json", ct, timeoutSeconds: 120);

        if (err != null)
            return $"Aanmeldingsfout: {err}";

        return string.IsNullOrWhiteSpace(output)
            ? "Aanmelding gestart. Volg de instructies in de terminal. / Giriş başlatıldı."
            : $"Aangemeld. / Giriş yapıldı:\n{output}";
    }

    [McpServerTool, Description(
        "Maak een Azure Resource Group aan. / Azure kaynak grubu oluştur.\n" +
        "Naamconventie: rg-yafespars-{omgeving}. Regio: westeurope (standaard).")]
    public async Task<string> CreateResourceGroup(
        [Description("Naam van de resourcegroep bijv. rg-yafespars-prod")] string resourceGroupName = "",
        [Description("Azure-regio: westeurope (standaard), northeurope, eastus")] string location = "westeurope",
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(resourceGroupName))
            return "Fout: naam van de resourcegroep is verplicht.";

        var (output, err) = await RunAsync("az",
            $"group create --name {resourceGroupName} --location {location} --output json", ct);

        return err != null
            ? $"Fout bij aanmaken resourcegroep: {err}"
            : $"Resourcegroep aangemaakt: {resourceGroupName} in {location}.\n{output}";
    }

    [McpServerTool, Description(
        "Implementeer de Yafes Pars infrastructuur via Bicep. / Yafes Pars altyapısını Bicep ile dağıt.\n" +
        "Vereist: resourcegroep bestaat al (gebruik create_resource_group).\n" +
        "Omgevingen: dev, staging, prod.\n" +
        "Voer dit uit vanuit de projectroot (waar infra/main.bicep staat).")]
    public async Task<string> DeployInfrastructure(
        [Description("Naam van de resourcegroep")] string resourceGroupName = "",
        [Description("Omgeving: dev, staging, prod")] string environment = "dev",
        [Description("JWT Authority URL bijv. https://login.microsoftonline.com/{tenant}/v2.0")] string jwtAuthority = "",
        [Description("JWT Audience bijv. api://yafespars")] string jwtAudience = "",
        [Description("CORS-oorsprong bijv. https://app.yafespars.be")] string corsAllowedOrigins = "*",
        [Description("Pad naar infra/main.bicep (standaard: ./infra/main.bicep)")] string bicepPath = "./infra/main.bicep",
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(resourceGroupName) || string.IsNullOrWhiteSpace(environment))
            return "Fout: resourcegroepnaam en omgeving zijn verplicht.";

        var args = $"deployment group create" +
                   $" --resource-group {resourceGroupName}" +
                   $" --template-file {bicepPath}" +
                   $" --parameters environment={environment}" +
                   $" jwtAuthority=\"{jwtAuthority}\"" +
                   $" jwtAudience=\"{jwtAudience}\"" +
                   $" corsAllowedOrigins=\"{corsAllowedOrigins}\"" +
                   $" --output json";

        var (output, err) = await RunAsync("az", args, ct, timeoutSeconds: 300);

        return err != null
            ? $"Implementatiefout: {err}\nControleer of je bent aangemeld (check_azure_status) en de Bicep geldig is."
            : $"Implementatie geslaagd voor omgeving '{environment}'.\n{output}";
    }

    [McpServerTool, Description(
        "Voer SQL-migraties uit op de Azure SQL-database. / Azure SQL veritabanında SQL migration'ları çalıştır.\n" +
        "Voert alle .sql-bestanden in database/migrations/ uit in volgorde.\n" +
        "Vereist: sqlcmd geïnstalleerd, server + gebruikersnaam + wachtwoord opgeven.")]
    public async Task<string> RunDatabaseMigrations(
        [Description("SQL Server hostnaam bijv. sql-yafespars-prod.database.windows.net")] string server = "",
        [Description("Databasenaam (standaard: YafesPars)")] string database = "YafesPars",
        [Description("SQL-gebruikersnaam")] string username = "",
        [Description("SQL-wachtwoord")] string password = "",
        [Description("Map met migratiebestanden (standaard: ./database/migrations)")] string migrationsPath = "./database/migrations",
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(server) || string.IsNullOrWhiteSpace(username))
            return "Fout: server en gebruikersnaam zijn verplicht.";

        var files = Directory.GetFiles(migrationsPath, "*.sql").OrderBy(f => f).ToArray();
        if (files.Length == 0)
            return $"Geen SQL-bestanden gevonden in: {migrationsPath}";

        var results = new List<object>();
        foreach (var file in files)
        {
            var fileName = Path.GetFileName(file);
            var args = $"-S {server} -d {database} -U {username} -P \"{password}\" -i \"{file}\" -b";
            var (output, err) = await RunAsync("sqlcmd", args, ct, timeoutSeconds: 60);

            results.Add(new
            {
                bestand = fileName,
                status = err == null ? "geslaagd" : "mislukt",
                uitvoer = err ?? output?.Trim()
            });

            if (err != null) break;
        }

        return JsonSerializer.Serialize(new { migraties = results }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Stel GitHub Secrets in die nodig zijn voor CI/CD-deployment. / GitHub CI/CD için gerekli secret'ları ayarla.\n" +
        "Vereist: GitHub CLI (gh) aangemeld en repository beschikbaar.\n" +
        "Gebruik dit na een Azure-deployment om de pipeline te configureren.")]
    public async Task<string> SetGitHubSecrets(
        [Description("GitHub-repository bijv. mcemkoca/Yafes_Pars")] string repository = "",
        [Description("Azure Client ID (uit federated credential)")] string azureClientId = "",
        [Description("Azure Tenant ID")] string azureTenantId = "",
        [Description("Azure Subscription ID")] string azureSubscriptionId = "",
        [Description("Azure Resource Group naam")] string resourceGroup = "",
        [Description("SQL Server connectiestring (voor migraties)")] string sqlConnectionString = "",
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(repository))
            return "Fout: repository is verplicht bijv. eigenaar/naam.";

        var secrets = new Dictionary<string, string>
        {
            ["AZURE_CLIENT_ID"]       = azureClientId,
            ["AZURE_TENANT_ID"]       = azureTenantId,
            ["AZURE_SUBSCRIPTION_ID"] = azureSubscriptionId,
            ["AZURE_RESOURCE_GROUP"]  = resourceGroup,
            ["SQL_CONNECTION_STRING"] = sqlConnectionString
        };

        var results = new List<object>();
        foreach (var (name, value) in secrets)
        {
            if (string.IsNullOrWhiteSpace(value)) continue;

            var (_, err) = await RunAsync("gh",
                $"secret set {name} --repo {repository} --body \"{value}\"", ct);

            results.Add(new { secret = name, status = err == null ? "ingesteld" : $"fout: {err}" });
        }

        return JsonSerializer.Serialize(new { repository, secrets = results }, JsonOpts.Default);
    }

    [McpServerTool, Description(
        "Controleer de deploymentstatus van de Azure App Service. / Azure App Service deployment durumunu kontrol et.")]
    public async Task<string> CheckAppStatus(
        [Description("Naam van de App Service bijv. app-yafespars-prod")] string appName = "",
        [Description("Naam van de resourcegroep")] string resourceGroupName = "",
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(appName) || string.IsNullOrWhiteSpace(resourceGroupName))
            return "Fout: appName en resourceGroupName zijn verplicht.";

        var (output, err) = await RunAsync("az",
            $"webapp show --name {appName} --resource-group {resourceGroupName} --output json", ct);

        if (err != null) return $"Fout: {err}";

        try
        {
            var doc = JsonDocument.Parse(output!);
            var root = doc.RootElement;
            return JsonSerializer.Serialize(new
            {
                naam   = root.TryGetProperty("name", out var n) ? n.GetString() : appName,
                status = root.TryGetProperty("state", out var s) ? s.GetString() : "onbekend",
                url    = root.TryGetProperty("defaultHostName", out var h) ? $"https://{h.GetString()}" : "",
                sku    = root.TryGetProperty("sku", out var sk) ? sk.GetString() : ""
            }, JsonOpts.Default);
        }
        catch
        {
            return output ?? "Geen uitvoer.";
        }
    }

    private static async Task<(string? output, string? error)> RunAsync(
        string command, string arguments, CancellationToken ct, int timeoutSeconds = 30)
    {
        try
        {
            using var process = new Process();
            process.StartInfo = new ProcessStartInfo
            {
                FileName               = command,
                Arguments              = arguments,
                RedirectStandardOutput = true,
                RedirectStandardError  = true,
                UseShellExecute        = false,
                CreateNoWindow         = true
            };

            process.Start();

            using var cts = CancellationTokenSource.CreateLinkedTokenSource(ct);
            cts.CancelAfter(TimeSpan.FromSeconds(timeoutSeconds));

            var outputTask = process.StandardOutput.ReadToEndAsync(cts.Token);
            var errorTask  = process.StandardError.ReadToEndAsync(cts.Token);

            await process.WaitForExitAsync(cts.Token);

            var output = await outputTask;
            var error  = await errorTask;

            return process.ExitCode == 0
                ? (output, null)
                : (output, string.IsNullOrWhiteSpace(error) ? $"exitcode {process.ExitCode}" : error);
        }
        catch (OperationCanceledException)
        {
            return (null, $"Time-out na {timeoutSeconds}s voor commando: {command}");
        }
        catch (Exception ex)
        {
            return (null, $"{ex.GetType().Name}: {ex.Message}");
        }
    }
}
