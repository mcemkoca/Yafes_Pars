using Dapper;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.OpenApi.Models;
using YafesPars.Api.Endpoints;
using YafesPars.Api.Security;
using YafesPars.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

DefaultTypeMap.MatchNamesWithUnderscores = true;

builder.Configuration.AddEnvironmentVariables();

var authority = builder.Configuration["Authentication:Authority"];
var audience = builder.Configuration["Authentication:Audience"];
if (!builder.Environment.IsDevelopment()
    && (string.IsNullOrWhiteSpace(authority) || string.IsNullOrWhiteSpace(audience)))
{
    throw new InvalidOperationException(
        "Authentication:Authority and Authentication:Audience are required outside Development.");
}

builder.Services.AddInfrastructure();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Yafes Pars API",
        Version = "v1"
    });
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header
    });
});

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = authority;
        options.Audience = audience;
        options.RequireHttpsMetadata = true;
    });
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("TenantUser", policy =>
    {
        policy.RequireAuthenticatedUser();
        policy.RequireAssertion(context => TenantClaims.TryGetTenantId(context.User, out _));
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseAuthentication();
app.UseAuthorization();

app.MapHealthEndpoints();
app.MapAuthEndpoints();
app.MapDomainReadEndpoints();

app.Run();

public partial class Program;
