# Ortam Matrisi

Bu matris, DEV, TEST ve PROD davranışını operatörler için açık tutar.

| Alan | DEV | TEST | PROD |
| --- | --- | --- | --- |
| Veri tabanı adı | `YafesPars_DEV` | `YafesPars_TEST` | `YafesPars` |
| SQL Server sürümü | Developer | Standard/Enterprise veya onaylı test sürümü | Standard/Enterprise |
| Veri | Demo veya sentetik | Temizlenmiş veya onaylı test verisi | Canlı iş verisi |
| Demo seed `018` | İzinli | İsteğe bağlı | İzin verilmez |
| Rollback script'leri | İncelemeden sonra izinli | Kısıtlı | Yalnızca ayrı onay |
| Migration'lardan yeniden oluşturma | İzinli | Onay ile izinli | Normal rollback olarak izin verilmez |
| Migration öncesi yedek | Zorunlu | Zorunlu | Zorunlu |
| Statik kalite kapısı | Zorunlu | Zorunlu | Zorunlu |
| SQL doğrulama | Zorunlu | Zorunlu | Zorunlu |
| SSMS dashboard | Zorunlu | Zorunlu | Zorunlu |
| Depoda secret | Asla | Asla | Asla |
| Genel SQL erişimi | Hayır | Hayır | Hayır |
| RDP | Kısıtlı | Kısıtlı | Kısıtlı/JIT |
| Değişiklik onayı | Basit | Sürüm onayı | Resmi onay |

## Adlandırma Kuralları

- DEV veri tabanı adları `DEV` içermelidir.
- TEST veri tabanı adları `TEST` içermeli veya üretim dışı olarak açıkça etiketlenmelidir.
- PROD veri tabanı adları `DEV`, `TEST`, `LOCAL` veya `SANDBOX` içermemelidir.
- Araçlar, PROD runbook yürütmesi için açıkça tasarlanmadıkça üretime benzer adları
  reddetmelidir.

## Operatör Kuralı

Ortam belirsizse durun. Veri değiştiren veya schema değiştiren herhangi bir script
çalıştırmadan önce SQL Server adını, veri tabanı adını, yedek hedefini ve onay
kaydını doğrulayın.
