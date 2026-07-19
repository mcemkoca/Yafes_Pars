# TEST Erişim İncelemesi Kanıtı

**Ortam:** TEST  
**Durum:** ORTAM YÜRÜTMESI BEKLENİYOR  
**Sorumlu:** Deuterium12{MCK}  
**Şablon sürümü:** 2026-07-19

TEST örneğine karşı `database/tools/access-review/` scriptleri çalıştırılarak doldurulacaktır.

---

## Özet

| Alan | Değer |
|---|---|
| Ortam | TEST |
| Veritabanı | |
| İnceleme tarihi/saati (UTC) | |
| İnceleyen | |
| Onaylayan | |
| Commit SHA / sürüm | |
| Kullanılan scriptler | `01__list_active_users.sql`, `02__role_permission_matrix.sql`, `03__segregation_of_duties_check.sql` |

---

## Aktif Kullanıcılar (`01__list_active_users.sql`)

| user_id | e-posta | rol_sayısı | son_giriş_utc | tenant | Durum |
|---|---|---|---|---|---|
| | | | | | |

Toplam aktif kullanıcı: ______  
Rolsüz kullanıcı: ______ (beklenen: 0)  
90 günden uzun süredir pasif kullanıcı: ______ (kaldırma için işaretle)

---

## Rol-İzin Matrisi (`02__role_permission_matrix.sql`)

| Rol | İzin sayısı | Admin izinleri | Durum |
|---|---|---|---|
| SYSTEM_ADMIN | | | |
| BROKER_ADMIN | | | |
| BROKER_USER | | | |
| CLAIM_HANDLER | | | |

---

## Görevler Ayrılığı (`03__segregation_of_duties_check.sql`)

| Kontrol | Sonuç | Notlar |
|---|---|---|
| CLAIM_APPROVE + CLAIM_CLOSE aynı kullanıcı | | (beklenen: 0 veya onaylı istisna) |
| PAYMENT_CREATE + PAYMENT_APPROVE aynı kullanıcı | | (beklenen: 0 veya onaylı istisna) |
| ADMIN + CLAIM_HANDLE birlikte | | |

---

## Rol İncelemesi

| Rol | Beklenen sahip | Onaylı kullanım | İstisna |
|---|---|---|---|
| `SYSTEM_ADMIN` | Platform sahibi | Yalnızca acil/platform yönetimi | |
| `BROKER_ADMIN` | Tenant yöneticisi | Broker ofisi yönetimi | |
| `BROKER_USER` | Günlük operatör | Günlük broker işlemleri | |
| `CLAIM_HANDLER` | Hasar ekibi | Hasar işleme ve belge çalışması | |

---

## Kullanıcı Atama İncelemesi

| Kullanıcı | Rol(ler) | Durum | Karar | Notlar |
|---|---|---|---|---|
| | | | Tut / Kaldır / Değiştir | |

---

## İmza

| Alan | Değer |
|---|---|
| Erişim kabul edildi | |
| İstisnalar kabul edildi | |
| Takip görevleri | |
| İnceleyen imzası | Deuterium12 <mcemkoca0@gmail.com> |
| Onaylayan imzası | |
| Tarih | |
