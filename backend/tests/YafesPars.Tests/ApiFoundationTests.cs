using Xunit;

namespace YafesPars.Tests;

public sealed class ApiFoundationTests
{
    [Fact]
    public void ApiAssemblyIsDiscoverable()
    {
        Assert.Equal("YafesPars.Api", typeof(Program).Assembly.GetName().Name);
    }
}
