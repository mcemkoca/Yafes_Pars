FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY backend/src/YafesPars.Api/YafesPars.Api.csproj                       backend/src/YafesPars.Api/
COPY backend/src/YafesPars.Application/YafesPars.Application.csproj       backend/src/YafesPars.Application/
COPY backend/src/YafesPars.Infrastructure/YafesPars.Infrastructure.csproj backend/src/YafesPars.Infrastructure/
COPY backend/src/YafesPars.Domain/YafesPars.Domain.csproj                 backend/src/YafesPars.Domain/

RUN dotnet restore backend/src/YafesPars.Api/YafesPars.Api.csproj

COPY backend/src/ backend/src/

RUN dotnet publish backend/src/YafesPars.Api/YafesPars.Api.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
EXPOSE 8080

ENTRYPOINT ["dotnet", "YafesPars.Api.dll"]
