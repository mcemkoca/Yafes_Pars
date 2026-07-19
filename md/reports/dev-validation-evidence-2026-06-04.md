# DEV Doğrulama Kanıtı — 2026-06-04

## Özet

| Alan | Değer |
| --- | --- |
| Ortam | Yerel geçici SQL Server DEV container'ı |
| Kaynak veri tabanı | `YafesPars_DEV` |
| Kanıt tarihi | 2026-06-04 |
| Commit hattı | PR #1 feature dalı |
| Tenant kodu | `DEV-BE-BROKER` |
| Tenant görünen adı | Yafes Broker Operations |
| Sonuç | BAŞARILI |

## Kanıt

| Kontrol | Sonuç |
| --- | --- |
| Statik kalite kapısı | BAŞARILI |
| Migration script'leri `000..018` | BAŞARILI, 19 script |
| Kaynak DEV veri tabanında doğrulama script'leri `001..017` | BAŞARILI, 17 script |
| SSMS dashboard sözleşmesi | BAŞARILI |
| Admin rol matrisi sözleşmesi | BAŞARILI |
| SQL Server doğrulama iş akışı | GitHub Actions'ta BAŞARILI |
| SSMS çalışma tezgahı doğrulama iş akışı | GitHub Actions'ta BAŞARILI |

## Geri Yüklenen Veri Tabanı Sinyalleri

| Sinyal | Değer |
| --- | --- |
| Domain tablo sayısı | 108 |
| Aktif rol sayısı | 4 |
| Aktif izin sayısı | 18 |
| Aktif DEV örnek kullanıcı sayısı | 3 |

## Notlar

- Secret, parola, yedek dosyası veya yürütme günlüğü eseri commit edilmedi.
- Veri tabanı kaynağı migration `000..018` olmaya devam ediyor; gelecekteki schema
  çalışmaları `019+` ile başlıyor.
- Yerel tarayıcı önizlemesi kalıcı değil. Gerçek veri çalışması, DEV/TEST/PROD
  değişiklik kontrollü ortamlarına karşı SQLCMD Mode etkinleştirilmiş SSMS'de
  kalmaktadır.
