# Geri Yükleme Tatbikatı Kanıtı — DEV — 2026-06-04

## Özet

| Alan | Değer |
| --- | --- |
| Geri yükleme yapılan ortam | Yerel geçici SQL Server DEV container'ı |
| Çalıştırma ID'si | `20260604093451` |
| Geri yükleme hedefi | `YafesPars_RESTORE_DEV` |
| Kaynak veri tabanı | `YafesPars_DEV` |
| SQL Server versiyonu | 16.0.4260.1 RTM, Developer Edition |
| Yedek dosya boyutu | 20.013.056 byte |
| Kanıt oluşturma UTC | 2026-06-04T07:35:22Z |
| Tenant kodu | `DEV-BE-BROKER` |
| Tenant görünen adı | Yafes Broker Operations |
| Sonuç | BAŞARILI |

## Geri Yükleme Adımları

| Adım | Sonuç |
| --- | --- |
| Kaynak DEV veri tabanına migration `000..018` uygula | BAŞARILI |
| Kaynak DEV veri tabanında doğrulama `001..017` çalıştır | BAŞARILI |
| Yalnızca kopya yedeği oluştur | BAŞARILI |
| `RESTORE VERIFYONLY` çalıştır | BAŞARILI |
| Yedeği `YafesPars_RESTORE_DEV`'e geri yükle | BAŞARILI |
| Geri yüklenen veri tabanında doğrulama `001..017` çalıştır | BAŞARILI |
| Geri yüklenen veri tabanına karşı SSMS dashboard script'ini aç | BAŞARILI |
| Geri yüklenen veri tabanına karşı admin rol matrisini çalıştır | BAŞARILI |

## Geri Yüklenen Veri Tabanı Sinyalleri

| Sinyal | Değer |
| --- | --- |
| Domain tablo sayısı | 108 |
| Aktif rol sayısı | 4 |
| Aktif izin sayısı | 18 |
| Aktif DEV örnek kullanıcı sayısı | 3 |
| Schema migration başarı satırları | 17 |

## Karar

DEV geri yükleme tatbikatı, depo hazırlığı için kabul edilebilir. TEST/PROD geri
yükleme tatbikatı kanıtı, `md/database/restore-drill-evidence-template.md` kullanılarak
onaylı altyapıda toplanmaya devam etmelidir.
