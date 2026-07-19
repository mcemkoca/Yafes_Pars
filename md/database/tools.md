# Veri Tabanı Araçları

Bu klasör, Yafes Pars SQL Server DEV veri tabanı iş akışını çalıştırmak için
korumalı yardımcılar içerir.

## Statik kalite kapısı

Daha ağır SQL Server yürütmesinden önce statik kalite kapısını çalıştırın:

```powershell
.\database\tools\test-sql-quality-gate.ps1
```

CI'da yerel yürütme eserlerini yazmaktan kaçınmak için `-NoReportFile` kullanın:

```powershell
.\database\tools\test-sql-quality-gate.ps1 -NoReportFile
```

`SET XACT_ABORT ON` gibi stil önerilerinin engelleyici hatalara dönüşmesini
istediğinizde `-StrictStyle` kullanın.

Kapı şunları kontrol eder:

- `000`'dan `018`'e korumalı migration sırası
- `001`'den `017`'ye korumalı doğrulama sırası
- Desteklenmeyen SQL Server dışı sözdizimi
- Rollback script'leri dışında yıkıcı SQL kalıpları
- Yasaklı `Object` tablo adlandırması
- Bilgi ipuçları, SQLCMD koruyucuları ve tenant bağlamı için SSMS operatör kuralları
- Gerekli üretim hazırlık belgeleri

## Gerekli değişkenler

Migration çalıştırıcısını çalıştırmadan önce şu ortam değişkenlerini ayarlayın:

```powershell
$env:YAFES_SQL_SERVER="YOUR_DEV_SQL_SERVER"
$env:YAFES_SQL_DATABASE="YafesPars_Dev"
$env:YAFES_SQL_USER="YOUR_SQL_USER"
$env:YAFES_SQL_PASSWORD="YOUR_SQL_PASSWORD"

.\database\tools\run-dev-migrations.ps1
```

İsteğe bağlı:

- `YAFES_SQL_BACKUP_DIR`: SQL Server tarafından görülebilen yedek dizini. Varsayılan olarak
  çalıştırma günlüğü klasörüdür.
- `YAFES_SQL_SECRET_FILE`: gerekli değişkenleri içeren, commit edilmemiş yerel bir
  `KEY=VALUE` dosyasının yolu.

Gerçek secret'ları, parolaları, token'ları veya bağlantı dizelerini asla commit etmeyin.

## Güvenlik kontrolleri

`run-dev-migrations.ps1`, şu durumlarda DB değişikliklerinden önce durur:

- `YAFES_SQL_DATABASE` `DEV` içermiyor.
- `YAFES_SQL_SERVER`, doğrulanmış sunucu adı veya makine adı üretimi akla getiriyor.
- Gerekli bağlantı değişkenlerinden herhangi biri eksik.
- Beklenen dizideki herhangi bir migration veya doğrulama dosyası eksik.
- Güvensiz migration işlemleri tespit edildi.
- Hedef veri tabanı doğrulanamıyor.
- Migration öncesi yedek oluşturulamıyor.
- Herhangi bir migration veya doğrulama script'i başarısız oluyor.

Çalıştırıcı, migration'ları `000`'dan `018`'e kesin sayısal sırayla, ardından
doğrulamaları `001`'den `017`'ye çalıştırır.

## Yedek davranışı

Migration'lar çalışmadan önce, çalıştırıcının migration öncesi yedek oluşturabilmesi
için hedef DEV veri tabanı zaten mevcut olmalıdır.

Yedek dosyası adı biçimi:

```text
YafesPars_Dev_PreMigration_YYYYMMDD_HHMMSS.bak
```

SQL Server yedek yolunu yazamıyorsa veya SQL hesabında yedek izni yoksa, çalıştırıcı
durur ve migration'ları yürütmez.

## Günlükler

Her çalıştırma şunu oluşturur:

```text
database/execution-logs/YYYYMMDD_HHMMSS/
```

Klasör hazırlanmış script'leri, migration başına bir günlük, doğrulama başına bir
günlük, yedek günlükleri ve `final-report.md` içerir.

Çalıştırıcı, SQL dosyalarının yapılandırılmış DEV veri tabanı adıyla geçici kopyalarını
hazırlar. Özgün migration ve doğrulama dosyaları değiştirilmez.

## CI doğrulaması

GitHub Actions, bir SQL Server Developer container'ı başlatmak, `YafesPars_DEV`
oluşturmak, `000`'dan `018`'e migration'ları çalıştırmak, `001`'den `017`'ye
doğrulamaları çalıştırmak ve yürütme günlüklerini yüklemek için
`.github/workflows/sql-server-validation.yml` ve `run-ci-sql-validation.ps1` kullanır.

İş akışı, her çalıştırma için maskelenmiş, kısa ömürlü bir SQL Server container
parolası oluşturur. Depoda statik SQL Server parolası saklanmaz.

`.github/workflows/database-quality-gate.yml`, belgeleme, SSMS, şablon ve migration
yapı sorunlarının hızla yakalanması için SQL Server container'ı olmadan statik kapıyı
çalıştırır.

## SSMS geri dönüşü

`sqlcmd` kurulu değilse çalıştırıcı şunu oluşturur:

```text
database/execution-logs/YYYYMMDD_HHMMSS/ssms-dev-migrations.sql
```

Bu dosyayı SSMS'de açın, `Query > SQLCMD Mode` etkinleştirin, üstteki SQLCMD
değişkenlerini ayarlayın ve yalnızca doğrulanmış bir DEV hedefine karşı çalıştırın.

Yalnızca manuel SSMS script'ini şununla oluşturabilirsiniz:

```powershell
.\database\tools\run-dev-migrations.ps1 -GenerateSsmsScriptOnly
```

## Rollback notları

Rollback otomatik değildir. `database/rollback/` altındaki script'leri yalnızca
koruyucu değişkenleri inceledikten ve hedefin DEV olduğunu doğruladıktan sonra
kullanın.
