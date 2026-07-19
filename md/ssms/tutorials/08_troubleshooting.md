# Sorun Giderme

## SQLCMD Değişkenleri Çalışmıyor

SSMS'de `Query > SQLCMD Mode` etkinleştirin. `:setvar` veya `:r` içeren script'ler
bunu gerektirir.

## Hedef Veri Tabanı Hatası

Çalışma tezgahı, `DEV` içermeyen veri tabanı adlarını reddeder. Bağlantıyı ve
`YAFES_SQL_DATABASE`'i doğrulayın.

## Tenant Bulunamadı

Script'in üstündeki `TENANT_CODE`'u kontrol edin. Mevcut tenant'ları listelemek
için operasyonlar dashboard'unu çalıştırın.

## Arama Eksik

`06__query_library_shortcuts.sql` çalıştırın ve arama yardımcısı sonuç kümesini
inceleyin. Yalnızca aktif arama değerlerini kullanın.

## Düzenleme Commit Edilmedi

Çoğu düzenleme şablonu varsayılan olarak geri alınır. Önizlemeyi inceledikten
sonra yalnızca `COMMIT_CHANGES = 1` ayarlayın.

## Migration Yedek Hatası

SQL Server hizmet hesabı, yedek yoluna yazabilmelidir. Gerçek bir zaman damgalı
`.bak` yolu kullanın ve yeniden çalıştırın.

## Bilgi İpuçları

- Results Grid'in yanı sıra Messages panelini de okuyun.
- ID'leri elle yazmak yerine ızgaralardan kopyalayın.
- Görev başına bir sekme açık tutun: dashboard, arama, düzenleme, denetim.
