# PROD Erişim İncelemesi Kanıtı

**Ortam:** PROD  
**Durum:** BEKLENİYOR — PROD ERİŞİMİ ENGELLENMIŞ  
**Sorumlu:** Deuterium12{MCK}  
**Şablon sürümü:** 2026-07-19

> **ÖNEMLİ:** PROD erişim incelemesi yalnızca onaylı değişiklik yönetimi penceresi
> içinde yetkili DBA veya operatör tarafından yapılabilir.
> Kanıt, PROD'dan KKB/PII çekilmeden toplanmalıdır.

---

## Özet

| Alan | Değer |
|---|---|
| Ortam | PROD |
| Veritabanı | |
| İnceleme tarihi/saati (UTC) | |
| İnceleyen (adı) | |
| Onaylayan (adı) | |
| Değişiklik yönetimi bileti | |
| Commit SHA / sürüm | |
| Kullanılan scriptler | `01__list_active_users.sql`, `02__role_permission_matrix.sql`, `03__segregation_of_duties_check.sql` |

---

## Aktif Kullanıcılar (yalnızca sayılar — PII kaydetmeyin)

| Metrik | Değer |
|---|---|
| Toplam aktif kullanıcı | |
| Rolsüz kullanıcı | (beklenen: 0) |
| 90 günden uzun süredir pasif kullanıcı | (kaldırma için işaretle) |
| Aktif kullanıcılı tenant sayısı | |

---

## Rol-İzin Matrisi

| Rol | İzin sayısı | Admin izinleri | Notlar |
|---|---|---|---|
| SYSTEM_ADMIN | | | |
| BROKER_ADMIN | | | |
| BROKER_USER | | | |
| CLAIM_HANDLER | | | |

---

## Görevler Ayrılığı

| Kontrol | Sonuç | Onaylı istisna? |
|---|---|---|
| CLAIM_APPROVE + CLAIM_CLOSE aynı kullanıcı | | |
| PAYMENT_CREATE + PAYMENT_APPROVE aynı kullanıcı | | |

---

## Rol İncelemesi

| Rol | Beklenen sahip | Onaylı kullanım | İstisna |
|---|---|---|---|
| `SYSTEM_ADMIN` | Platform sahibi | Yalnızca acil/platform | |
| `BROKER_ADMIN` | Tenant yöneticisi | Broker yönetimi | |
| `BROKER_USER` | Günlük operatör | Günlük broker işlemleri | |
| `CLAIM_HANDLER` | Hasar ekibi | Hasar işleme | |

---

## PROD'a Özgü Kontroller

| Kontrol | Durum | Notlar |
|---|---|---|
| Hiçbir geliştiricinin PROD'da SYSTEM_ADMIN rolü yok | | |
| Servis hesapları en az ayrıcalıklı rolleri kullanıyor | | |
| Paylaşılan şifre veya kimlik bilgisi yok | | |
| SQL girişleri Windows Kimlik Doğrulama veya yönetilen kimlik kullanıyor | | |
| Tüm DML için denetim izi etkin | | |

---

## İmza (PROD İÇİN İKİ İMZACI GEREKLİDİR)

| Alan | Değer |
|---|---|
| Erişim kabul edildi | |
| İstisnalar kabul edildi | |
| Takip görevleri | |
| Birinci imzacı imzası | Deuterium12 <mcemkoca0@gmail.com> |
| İkinci imzacı imzası | |
| Tarih | |
