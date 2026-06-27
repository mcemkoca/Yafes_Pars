using System.Text.Json;
using System.Text.Json.Serialization;

namespace YafesPars.McpServer;

internal static class JsonOpts
{
    public static readonly JsonSerializerOptions Default = new()
    {
        WriteIndented = false,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        Converters = { new JsonStringEnumConverter() }
    };
}
