# Erişim İnceleme Kanıtı — DEV — 2026-06-04

## Özet

| Alan | Değer |
| --- | --- |
| Ortam | DEV yerel geçici SQL Server container'ı |
| İncelenen veri tabanı | `YafesPars_RESTORE_DEV` |
| Kanıt tarihi | 2026-06-04 |
| Kaynak script | `database/ssms/14__admin_role_permission_matrix.sql` |
| Tenant kodu | `DEV-BE-BROKER` |
| Tenant görünen adı | Yafes Broker Operations |
| Sonuç | BAŞARILI |

## RBAC Sinyalleri

| Sinyal | Değer |
| --- | --- |
| Beklenen sistem rolleri mevcut | 4 |
| Aktif izinler mevcut | 18 |
| Aktif DEV örnek kullanıcıları mevcut | 3 |
| Admin matrisi yürütmesi | BAŞARILI |
| En az ayrıcalık kontrol listesi yürütmesi | BAŞARILI |

## Rol İncelemesi

| Rol | Beklenen kullanım | DEV kanıtı |
| --- | --- | --- |
| `SYSTEM_ADMIN` | Yalnızca platform/veri tabanı yönetimi | Mevcut; tüm aktif izinler kapsanıyor. |
| `BROKER_ADMIN` | Tenant yönetimi | Mevcut; operasyon admin kullanıcısı atandı. |
| `BROKER_USER` | Günlük broker operasyonu | Mevcut; broker operatör kullanıcısı atandı. |
| `CLAIM_HANDLER` | Hasar işleme | Mevcut; hasar uzmanı kullanıcısı atandı. |

## Karar

DEV erişim inceleme kanıtı, mevcut SSMS öncelikli ürün temeli için kabul edilebilir.
TEST/PROD erişim incelemesi, adlandırılmış operatörler, onaylı SQL girişleri veya
Windows grupları ve resmi imzayla ortama özgü kanıt gerektirmeye devam etmektedir.
