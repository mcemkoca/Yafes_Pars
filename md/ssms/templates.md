# SSMS Şablonlar

Bu şablonlar, operatörler ve bakımcılar için kopyalamaya hazır başlangıç
noktalarıdır. Migration değildir. Dashboard ve güvenlik kontrollerini çalıştırdıktan
sonra SSMS sekmelerinde kullanın.

## Dosyalar

- `operator-query-header.sql`: yeni operatör sorguları için standart başlık.
- `guided-search-template.sql`: güvenli salt okunur arama kalıbı.
- `guarded-update-template.sql`: varsayılan rollback güncelleme kalıbı.
- `report-grid-template.sql`: grafik/dışa aktarmaya hazır rapor kalıbı.

## Kural

Her operatör sorgusu şunları içermelidir:

- SQLCMD değişken bloğu
- DEV veri tabanı hedefi
- `DB_NAME() LIKE '%DEV%'` çalışma zamanı koruması
- tenant çözümlemesi
- `INFO TIP` yorumları veya sonuç sütunları
- mutasyondan önce önizleme
- güncellemeler için varsayılan rollback

Şablonlar gerçek SSMS başlangıç noktalarıdır; yalnızca demo amaçlı parçacıklar
değildir. Şablonları yeni operatör script'lerine kopyalamadan veya çalıştırmadan
önce SQLCMD Mode etkin tutun.
