# Yafes Pars Backend

Doğrulanmış Yafes Pars SQL Server veri tabanı için .NET 8 Web API temeli.

## Yapı

- `src/YafesPars.Api`: HTTP API, Swagger, kimlik doğrulama/yetkilendirme bağlantısı, endpoint'ler.
- `src/YafesPars.Application`: DTO'lar ve uygulama sözleşmeleri.
- `src/YafesPars.Domain`: domain sabitleri ve paylaşılan domain türleri.
- `src/YafesPars.Infrastructure`: SQL Server bağlantısı ve Dapper repository'leri.
- `tests/YafesPars.Tests`: API temel testleri.

## Yapılandırma

Aşağıdaki yapılandırma anahtarlarından birini kullanın:

- `ConnectionStrings__YafesPars`
- `YAFES_SQL_CONNECTION_STRING`

JWT'ye hazır ayarlar:

- `Authentication__Authority`
- `Authentication__Audience`

Bu projede hard-coded secret bulunmamaktadır.

## Yerel komutlar

```powershell
dotnet restore backend/src/YafesPars.Api/YafesPars.Api.csproj
dotnet build backend/src/YafesPars.Api/YafesPars.Api.csproj
dotnet test backend/tests/YafesPars.Tests/YafesPars.Tests.csproj
```

Bu komutlar çalıştırılmadan önce mevcut iş istasyonunda .NET 8 SDK kurulu olmalıdır.
