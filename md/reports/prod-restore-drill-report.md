# PROD Yedek Geri Yükleme Tatbikatı Kanıt Raporu

**Ortam:** PROD  
**Durum:** BEKLENİYOR — PROD ERİŞİMİ ENGELLENMİŞ  
**Sorumlu:** Deuterium12{MCK}  
**Plan:** `md/restore/prod-restore-drill-plan.md`  
**Şablon sürümü:** 2026-07-19

> **KISITLAMALAR:**
> - PROD yedeğini PROD örneğinin kendisine GERİ YÜKLEME.
> - Tatbikat sonrasında geri yükleme hedefinin ağa erişilebilir olmasına İZİN VERME.
> - Tatbikat penceresi ötesinde PROD verisinin canlı kopyasını SAKLAMA.
> - İKİ ADLI İMZACI GEREKLİDİR.

---

## Tatbikat Özeti

| Alan | Değer |
|---|---|
| Ortam | PROD |
| Kaynak yedek örneği | |
| Geri yükleme hedef örneği (yalıtılmış) | |
| Seçilen yedek dosyası | |
| Yedek zaman damgası | |
| Yedek dosya boyutu | |
| Tatbikat başlangıcı (UTC) | |
| Tatbikat bitişi (UTC) | |
| Geçen süre (dakika) | |
| Hedef RTO | 120 dakika |
| RTO karşılandı mı? | |
| Birinci yürüten | |
| İkinci yürüten | |
| Değişiklik yönetimi bileti | |

---

## Adım 1 — Yedek Seçimi

| Alan | Değer |
|---|---|
| En güncel PROD tam yedeği | |
| Yedek dosya yolu (salt okunur erişim) | |
| Yedekleme tarihi (UTC) | |
| RESTORE VERIFYONLY sonucu | |
| Veri yaşı (yedekten bu yana saat) | |

---

## Adım 2 — Yalıtılmış Örneğe Geri Yükleme

```sql
RESTORE DATABASE [YafesPars_ProdRestoreDrill]
FROM DISK = N'<yedek_yolu>'
WITH MOVE 'YafesPars' TO N'<yalitilmis_veri_yolu>',
     MOVE 'YafesPars_log' TO N'<yalitilmis_log_yolu>',
     REPLACE, STATS = 10;
```

| Alan | Değer |
|---|---|
| Hedef örneğin ağdan yalıtıldığı onaylandı | |
| RESTORE sonucu | |
| Karşılaşılan hatalar | |
| Süre (saniye) | |

---

## Adım 3 — Doğrulama (`database/tools/restore-drill-validation.sql`)

Yalıtılmış örnekteki `YafesPars_ProdRestoreDrill` veritabanına karşı çalıştırın:

| Kontrol | Beklenen | Gerçekleşen | Durum |
|---|---|---|---|
| Migrasyon sayısı | ≥ 48 | | |
| Tüm migrasyonlar SUCCESS | Evet | | |
| Tablo sayısı | ≥ 140 | | |
| Yetim FK ihlali | 0 | | |

---

## Adım 4 — Temizlik

| İşlem | Tamamlandı |
|---|---|
| `YafesPars_ProdRestoreDrill` veritabanı silindi | |
| Anlık görüntü atıldı / yalıtılmış örnek devre dışı bırakıldı | |
| Yedek dosyası erişimi iptal edildi | |
| PROD verisinin canlı kopyası kalmadı | |
| Tatbikat değişiklik yönetimi sistemine kaydedildi | |

---

## Geçme Kriterleri

- [ ] Geri yükleme 120 dakika (RTO) içinde hatasız tamamlandı
- [ ] Migrasyon sayısı ≥ 48, tamamı SUCCESS
- [ ] Tablo sayısı ≥ 140
- [ ] Yetim FK ihlali yok
- [ ] İki imzacı aşağıda kayıtlı
- [ ] Kanıt kaydedildikten sonra geri yükleme hedefi silindi veya anlık görüntü atıldı

---

## İmza (İKİ İMZACI GEREKLİDİR)

| Alan | Değer |
|---|---|
| Tatbikat sonucu | GEÇTİ / KALDI |
| Bulunan sorunlar | |
| Düzeltici eylemler | |
| Birinci imzacı adı | |
| Birinci imzacı imzası | |
| İkinci imzacı adı | |
| İkinci imzacı imzası | |
| Tarih | |
