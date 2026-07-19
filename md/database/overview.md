# Veri Tabanı

Bu klasör, Yafes Pars için SQL Server ve SSMS öncelikli veri tabanı projesini içerir.

## Klasörler

- `legacy/`: karşılaştırma ve izlenebilirlik için saklanan özgün SQL dosyaları.
- `migrations/`: sıralı ileri migration'lar.
- `rollback/`: ileri yolun dışında tutulan rollback script'leri.
- `validation/`: beklenen veri tabanı nesnelerini ve kuralları doğrulayan SSMS script'leri.
- `md/database/`: insan tarafından okunabilir veri tabanı mimarisi ve operasyon belgeleri.
- `templates/`: yeniden kullanılabilir T-SQL şablonları.

## Çalışma Kuralı

Her büyük veri tabanı değişikliği şunları içermelidir:

1. Bir migration script'i.
2. Bir doğrulama script'i.
3. Belgeleme güncellemeleri.
4. Odaklı bir commit.

Üretim arama seed verisi ve isteğe bağlı demo verisi ayrı kalmalıdır.

## Derleme Durumu

Veri tabanı klasörü artık `000`'dan `018`'e sıralı migration'lar, her büyük aşama
için doğrulama script'leri, korumalı rollback script'leri ve yeniden kullanılabilir
SQL şablonlarını içermektedir. İnsan tarafından okunabilir veri tabanı belgeleri
`md/database/` altındadır.

## Kanıt Belgeleri

- `table-reconciliation-89-vs-108.md`: mevcut modelin neden 89 eski referansa
  karşı 108 tablo içerdiğini açıklar.
- `access-review-evidence-template.md`: rol, izin, kullanıcı ve en az ayrıcalık
  inceleme kanıtını kaydeder.
- `restore-drill-evidence-template.md`: yedek geri yükleme kanıtını, zamanlamayı
  ve doğrulama sonuçlarını kaydeder.
