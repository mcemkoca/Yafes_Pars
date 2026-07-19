# TEST Yedek Geri Yükleme Tatbikatı Kanıt Raporu

**Ortam:** TEST  
**Durum:** ORTAM YÜRÜTMESI BEKLENİYOR  
**Sorumlu:** Deuterium12{MCK}  
**Plan:** `md/restore/test-restore-drill-plan.md`  
**Şablon sürümü:** 2026-07-19

---

## Tatbikat Özeti

| Alan | Değer |
|---|---|
| Ortam | TEST |
| Kaynak yedek örneği | |
| Geri yükleme hedef örneği | |
| Seçilen yedek dosyası | |
| Yedek zaman damgası | |
| Yedek dosya boyutu | |
| Tatbikat başlangıcı (UTC) | |
| Tatbikat bitişi (UTC) | |
| Geçen süre (dakika) | |
| Hedef RTO | 60 dakika |
| RTO karşılandı mı? | |
| Yürüten | |

---

## Adım 1 — Yedek Seçimi

| Alan | Değer |
|---|---|
| Bulunan en güncel tam yedek | |
| Yedek dosya yolu | |
| Yedekleme tarihi (UTC) | |
| RESTORE VERIFYONLY ile doğrulandı | |

---

## Adım 2 — Geri Yükleme

```sql
-- Kullanılan komut:
RESTORE DATABASE [YafesPars_RestoreDrill]
FROM DISK = N'<yedek_yolu>'
WITH MOVE 'YafesPars' TO N'<veri_dosyası_yolu>',
     MOVE 'YafesPars_log' TO N'<log_dosyası_yolu>',
     REPLACE, STATS = 10;
```

| Alan | Değer |
|---|---|
| RESTORE komutu sonucu | |
| Karşılaşılan hatalar | |
| Süre (saniye) | |

---

## Adım 3 — Doğrulama (`database/tools/restore-drill-validation.sql`)

`YafesPars_RestoreDrill` veritabanına karşı çalıştırın:

| Kontrol | Beklenen | Gerçekleşen | Durum |
|---|---|---|---|
| Migrasyon sayısı | ≥ 48 | | |
| Tüm migrasyonlar SUCCESS | Evet | | |
| Tablo sayısı | ≥ 140 | | |
| Yetim FK ihlali | 0 | | |
| Şema sürümü | 1 | | |

---

## Adım 4 — SSMS Operatör Duman Testi (isteğe bağlı)

| Script | Durum |
|---|---|
| `05__operator_dashboard_home.sql` | |
| `14__admin_role_permission_matrix.sql` | |

---

## Adım 5 — Temizlik

| İşlem | Tamamlandı |
|---|---|
| `YafesPars_RestoreDrill` veritabanı silindi | |
| Yedek dosyası erişimi iptal edildi | |
| TEST verisinin canlı kopyası kalmadı | |

---

## Geçme Kriterleri

- [ ] Geri yükleme 60 dakika içinde hatasız tamamlandı
- [ ] Migrasyon sayısı ≥ 48, tamamı SUCCESS
- [ ] Tablo sayısı ≥ 140
- [ ] Yetim FK ihlali yok
- [ ] Kanıt kaydedildikten sonra geri yükleme hedefi silindi

---

## İmza

| Alan | Değer |
|---|---|
| Tatbikat sonucu | GEÇTİ / KALDI |
| Bulunan sorunlar | |
| Düzeltici eylemler | |
| Yürüten imzası | Deuterium12 <mcemkoca0@gmail.com> |
| Onaylayan imzası | |
| Tarih | |
