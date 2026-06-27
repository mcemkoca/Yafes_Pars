using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Microsoft.Extensions.Configuration;

namespace YafesPars.McpServer;

public sealed class BlobStorageService
{
    private readonly BlobServiceClient? _client;
    private readonly string _containerName;
    public bool IsConfigured => _client != null;

    public BlobStorageService(IConfiguration config)
    {
        var connStr = config["AzureStorage:ConnectionString"];
        _containerName = config["AzureStorage:ContainerName"] ?? "documents";

        if (!string.IsNullOrWhiteSpace(connStr))
            _client = new BlobServiceClient(connStr);
    }

    public async Task<(string uri, long sizeBytes)> UploadAsync(
        string fileName, byte[] content, string? mimeType, Guid tenantId, CancellationToken ct)
    {
        if (_client == null)
            throw new InvalidOperationException(
                "Azure Storage niet geconfigureerd. Stel AzureStorage:ConnectionString in appsettings.json in.");

        var container = _client.GetBlobContainerClient(_containerName);
        await container.CreateIfNotExistsAsync(PublicAccessType.None, cancellationToken: ct);

        var blobName = $"{tenantId}/{DateTime.UtcNow:yyyy/MM/dd}/{Guid.NewGuid()}/{fileName}";
        var blob = container.GetBlobClient(blobName);

        using var stream = new MemoryStream(content);
        await blob.UploadAsync(stream,
            new BlobHttpHeaders { ContentType = mimeType ?? "application/octet-stream" },
            cancellationToken: ct);

        return (blob.Uri.ToString(), content.Length);
    }
}
