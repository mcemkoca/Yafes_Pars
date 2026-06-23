# Yafes Pars Backend

.NET 8 Web API foundation for the validated Yafes Pars SQL Server database.

## Structure

- `src/YafesPars.Api`: HTTP API, Swagger, auth/authorization wiring, endpoints.
- `src/YafesPars.Application`: DTOs and application contracts.
- `src/YafesPars.Domain`: domain constants and shared domain types.
- `src/YafesPars.Infrastructure`: SQL Server connection and Dapper repositories.
- `tests/YafesPars.Tests`: API foundation tests.

## Configuration

Use either configuration key:

- `ConnectionStrings__YafesPars`
- `YAFES_SQL_CONNECTION_STRING`

JWT-ready settings:

- `Authentication__Authority`
- `Authentication__Audience`

No secrets are hardcoded in this project.

## Local commands

```powershell
dotnet restore backend/src/YafesPars.Api/YafesPars.Api.csproj
dotnet build backend/src/YafesPars.Api/YafesPars.Api.csproj
dotnet test backend/tests/YafesPars.Tests/YafesPars.Tests.csproj
```

The current workstation must have the .NET 8 SDK installed before these commands
can run.
