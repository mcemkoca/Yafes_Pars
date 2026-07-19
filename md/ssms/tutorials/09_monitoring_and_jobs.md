# İzleme ve İşler

Bir operatör, admin veya DBA'nın veri tabanı hazırlığı, biriktirme baskısı,
yedek görünürlüğü ve SQL Agent devir öğelerinin hızlı bir SSMS görünümünü
istediğinde bu iş akışını kullanın.

## Script'i Açma

1. SSMS'de `database/ssms/15__monitoring_and_job_readiness.sql` dosyasını açın.
2. `Query > SQLCMD Mode` etkinleştirin.
3. `YAFES_SQL_DATABASE`'in `DEV` içerdiğini doğrulayın.
4. `TENANT_CODE`'un beklenen tenant olduğunu doğrulayın.
5. Script'i çalıştırın.

## Sonuç Kümelerini Okuma

1. `01 - İzleme bağlamı` ile başlayın.
2. Migration sayısı, kurtarma modeli, güncellenebilirlik ve Query Store durumu
   için `02 - Veri tabanı hazırlık sinyalleri`'ni kontrol edin.
3. Açık görevler, gecikmiş görevler, açık hasarlar, yenileme adayları ve son
   denetim hacmi için `03 - Tenant operasyon izlemesi`'ni inceleyin.
4. DBA devir listesi olarak `04 - SQL Agent iş şeması`'nı kullanın.
5. Onaylanmış işlerin zaten mevcut olup olmadığını görmek için
   `05 - SQL Agent gözlemlenen Yafes işleri`'ni kontrol edin.
6. Sürüm veya geri yükleme planlamasından önce `07 - Yedek güncellik sinyali`'ni inceleyin.

## Operatör Kuralı

Bu script salt okunurdur. SQL Agent işleri oluşturmaz ve veri değiştirmez.
Bir sinyal `AKSIYON` veya `GÖZDEN GEÇİR` gösteriyorsa bağlantılı SSMS script'ini
açın veya sonuç kümesini adı geçen sahibine gönderin.
