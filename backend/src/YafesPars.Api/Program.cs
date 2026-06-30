using System.Security.Claims;
using System.Threading.RateLimiting;
using Dapper;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.OpenApi.Models;
using Azure.Monitor.OpenTelemetry.AspNetCore;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using Serilog;
using Serilog.Events;
using YafesPars.Api.Endpoints;
using YafesPars.Api.Security;
using YafesPars.Infrastructure;

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.Hosting.Lifetime", LogEventLevel.Information)
    .Enrich.FromLogContext()
    .WriteTo.Console(outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}")
    .CreateBootstrapLogger();

try
{
    Log.Information("Starting Yafes Pars API");

    var builder = WebApplication.CreateBuilder(args);

    DefaultTypeMap.MatchNamesWithUnderscores = true;

    builder.Configuration.AddEnvironmentVariables();

    builder.Host.UseSerilog((ctx, services, cfg) =>
    {
        cfg
            .ReadFrom.Configuration(ctx.Configuration)
            .ReadFrom.Services(services)
            .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
            .MinimumLevel.Override("Microsoft.Hosting.Lifetime", LogEventLevel.Information)
            .Enrich.FromLogContext()
            .Enrich.WithProperty("Application", "YafesPars")
            .Enrich.WithProperty("Environment", ctx.HostingEnvironment.EnvironmentName)
            .WriteTo.Console(outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}");

        var aiCs = ctx.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"];
        if (!string.IsNullOrWhiteSpace(aiCs))
            cfg.WriteTo.ApplicationInsights(aiCs, TelemetryConverter.Traces);
    });

    var authority = builder.Configuration["Authentication:Authority"];
    var audience = builder.Configuration["Authentication:Audience"];
    if (!builder.Environment.IsDevelopment()
        && (string.IsNullOrWhiteSpace(authority) || string.IsNullOrWhiteSpace(audience)))
    {
        throw new InvalidOperationException(
            "Authentication:Authority and Authentication:Audience are required outside Development.");
    }

    var allowedOrigins = builder.Configuration
        .GetSection("Cors:AllowedOrigins")
        .Get<string[]>() ?? [];

    builder.Services.AddCors(options =>
    {
        options.AddPolicy("YafesPolicy", policy =>
        {
            if (builder.Environment.IsDevelopment())
                policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();
            else
                policy.WithOrigins(allowedOrigins).AllowAnyHeader().AllowAnyMethod();
        });
    });

    // Rate limiting: per-tenant sliding window
    builder.Services.AddRateLimiter(options =>
    {
        options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

        options.AddPolicy("tenant", httpContext =>
        {
            var tenantId = httpContext.User.FindFirstValue("tenant_id") ?? "anonymous";
            return RateLimitPartition.GetSlidingWindowLimiter(tenantId, _ => new SlidingWindowRateLimiterOptions
            {
                Window = TimeSpan.FromMinutes(1),
                SegmentsPerWindow = 6,
                PermitLimit = 300,
                QueueLimit = 0
            });
        });

        options.AddPolicy("write", httpContext =>
        {
            var tenantId = httpContext.User.FindFirstValue("tenant_id") ?? "anonymous";
            return RateLimitPartition.GetSlidingWindowLimiter($"write:{tenantId}", _ => new SlidingWindowRateLimiterOptions
            {
                Window = TimeSpan.FromMinutes(1),
                SegmentsPerWindow = 6,
                PermitLimit = 60,
                QueueLimit = 0
            });
        });
    });

    var aiConnectionStr = builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"];
    if (!string.IsNullOrWhiteSpace(aiConnectionStr))
        builder.Services.AddApplicationInsightsTelemetry(o => o.ConnectionString = aiConnectionStr);

    builder.Services.AddInfrastructure();

    // OpenTelemetry distributed tracing
    // Azure Monitor exporteert naar Application Insights wanneer connection string aanwezig is.
    // Zonder connection string: tracing actief maar geen export (development mode).
    var otelBuilder = builder.Services.AddOpenTelemetry()
        .ConfigureResource(res => res
            .AddService("YafesPars.Api")
            .AddAttributes(new Dictionary<string, object>
            {
                ["deployment.environment"] = builder.Environment.EnvironmentName
            }))
        .WithTracing(tracing => tracing
            .AddAspNetCoreInstrumentation(opts => opts.RecordException = true)
            .AddSqlClientInstrumentation(opts =>
            {
                opts.SetDbStatementForText = false; // geen SQL-tekst in traces (privacy)
                opts.RecordException = true;
            }));

    if (!string.IsNullOrWhiteSpace(aiConnectionStr))
        otelBuilder.UseAzureMonitor(opts => opts.ConnectionString = aiConnectionStr);
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(options =>
    {
        options.SwaggerDoc("v1", new OpenApiInfo { Title = "Yafes Pars API", Version = "v1" });
        options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
        {
            Name = "Authorization",
            Type = SecuritySchemeType.Http,
            Scheme = "bearer",
            BearerFormat = "JWT",
            In = ParameterLocation.Header
        });
        options.AddSecurityRequirement(new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } },
                []
            }
        });
    });

    var devSigningKey = builder.Configuration["Authentication:DevSigningKey"];

    builder.Services
        .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            // Claimtypes (tenant_id, role, sub) ongewijzigd laten — geen URI-mapping.
            options.MapInboundClaims = false;

            if (!string.IsNullOrWhiteSpace(devSigningKey))
            {
                // Development/demo: lokaal ondertekende HS256 tokens (DevTokenIssuer).
                options.RequireHttpsMetadata = false;
                options.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = DevTokenIssuer.Issuer,
                    ValidateAudience = !string.IsNullOrWhiteSpace(audience),
                    ValidAudience = audience,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(
                        System.Text.Encoding.UTF8.GetBytes(devSigningKey)),
                    ValidateLifetime = true,
                    RoleClaimType = AuthRoles.RoleClaimType
                };
            }
            else
            {
                // Productie: externe OIDC IdP (Azure AD B2C / Auth0 / Keycloak).
                options.Authority = authority;
                options.Audience = audience;
                options.RequireHttpsMetadata = !builder.Environment.IsDevelopment();
                options.TokenValidationParameters.ValidateIssuer = !string.IsNullOrWhiteSpace(authority);
                options.TokenValidationParameters.ValidateAudience = !string.IsNullOrWhiteSpace(audience);
                options.TokenValidationParameters.RoleClaimType = AuthRoles.RoleClaimType;
            }
        });

    builder.Services.AddAuthorization(options =>
    {
        options.AddPolicy(AuthRoles.TenantUserPolicy, policy =>
        {
            policy.RequireAuthenticatedUser();
            policy.RequireAssertion(context => TenantClaims.TryGetTenantId(context.User, out _));
        });

        options.AddPolicy(AuthRoles.AdminPolicy, policy =>
        {
            policy.RequireAuthenticatedUser();
            policy.RequireAssertion(context => TenantClaims.TryGetTenantId(context.User, out _));
            policy.RequireRole(AuthRoles.Admin);
        });

        options.AddPolicy(AuthRoles.AuditorPolicy, policy =>
        {
            policy.RequireAuthenticatedUser();
            policy.RequireAssertion(context => TenantClaims.TryGetTenantId(context.User, out _));
            policy.RequireRole(AuthRoles.Auditor, AuthRoles.Admin);
        });
    });

    var app = builder.Build();

    app.UseExceptionHandler(errorApp =>
    {
        errorApp.Run(async context =>
        {
            context.Response.StatusCode = 500;
            context.Response.ContentType = "application/json";
            var feature = context.Features.Get<IExceptionHandlerFeature>();
            if (feature?.Error is not null)
                Log.Error(feature.Error, "Unhandled exception");
            var detail = app.Environment.IsDevelopment() ? feature?.Error.Message : "An unexpected error occurred.";
            await context.Response.WriteAsJsonAsync(new { error = detail });
        });
    });

    if (!app.Environment.IsDevelopment())
        app.UseHttpsRedirection();

    app.UseCors("YafesPolicy");
    app.UseRateLimiter();
    app.UseSerilogRequestLogging(options =>
    {
        options.MessageTemplate = "HTTP {RequestMethod} {RequestPath} responded {StatusCode} in {Elapsed:0.0000}ms";
    });

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
    app.MapPersonWriteEndpoints();
    app.MapPolicyWriteEndpoints();
    app.MapClaimWriteEndpoints();
    app.MapTaskWriteEndpoints();
    app.MapFinanceWriteEndpoints();
    app.MapDocumentWriteEndpoints();
    app.MapCoverageWriteEndpoints();
    app.MapRiskWriteEndpoints();
    app.MapCommissionEndpoints();
    app.MapPortfolioEndpoints();
    app.MapImportEndpoints();
    app.MapPaymentEndpoints();
    app.MapEmailEndpoints();
    app.MapReportingEndpoints();
    app.MapAuditEndpoints();
    app.MapMonitoringEndpoints();

    app.Run();
}
catch (Exception ex) when (ex is not HostAbortedException)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}

public partial class Program;
