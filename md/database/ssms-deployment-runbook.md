# SSMS Dağıtım Runbook'u

Bu runbook, Yafes Pars için kontrollü bir SSMS öncelikli dağıtımı tanımlar.

## Gerekli Erişim

- Hedef ortam için onaylı Windows girişi veya SQL girişi.
- Dağıtım için veri tabanı nesneleri oluşturma veya değiştirme izni.
- Değişikliklerden önce yedek oluşturma izni.
- Sürüm dalına veya onaylı sürüm eserine erişim.
- Yürütme günlüğü şablonuna erişim.

Parola, token veya bağlantı dizelerini depo dosyalarına veya paylaşılan biletlere
yapıştırmayın.

## Dağıtım Öncesi Kontroller

1. Ortam adını ve veri tabanı adını doğrulayın.
2. En son onaylı commit'i veya sürüm etiketini doğrulayın.
3. Yedek hedefinin SQL Server tarafından yazılabilir olduğunu doğrulayın.
4. Statik kalite kapısını çalıştırın:

```powershell
.\database\tools\test-sql-quality-gate.ps1
```

5. SSMS'de hedef SQL Server örneğine bağlanın.
6. `database/ssms/00__open_first_safety_check.sql` açın.
7. Script SQLCMD değişkenleri gerektiriyorsa `Query > SQLCMD Mode` etkinleştirin.
8. Güvenlik kontrolünü çalıştırın ve Results Grid/Messages çıktısını kaydedin.

## DEV Dağıtımı

`sqlcmd` kuruluyken DEV korumalı çalıştırıcıyı kullanabilir:

```powershell
$env:YAFES_SQL_SERVER = "localhost,1433"
$env:YAFES_SQL_DATABASE = "YafesPars_DEV"
$env:YAFES_SQL_USER = "sa"
$env:YAFES_SQL_PASSWORD = "<dev-password>"
$env:YAFES_SQL_BACKUP_DIR = "C:\SqlBackups"

.\database\tools\run-dev-migrations.ps1
```

`sqlcmd` mevcut değilse SSMS script'ini oluşturun:

```powershell
.\database\tools\run-dev-migrations.ps1 -GenerateSsmsScriptOnly
```

Oluşturulan script'i SSMS'de açın, SQLCMD Mode'u etkinleştirin, değişkenleri
doğrulayın ve yalnızca bir DEV veri tabanına karşı çalıştırın.

## TEST Dağıtımı

1. TEST veri tabanını geri yükleyin veya oluşturun.
2. Dağıtım öncesi yedek alın.
3. Migration'ları kesin sırayla yürütün.
4. Doğrulamaları kesin sırayla yürütün.
5. SSMS dashboard'unu ve günlük kontrol listesini çalıştırın.
6. Test imzasını yürütme günlüğüne kaydedin.

TEST, üretim verisini kullanmadıkça veya veri temizlenip onaylanmadıkça tam PROD
prosedürünü prova etmelidir.

## PROD Dağıtımı

1. Değişiklik onayını ve bakım penceresini doğrulayın.
2. Rollback karar yolunu ve geri yükleme sahibini doğrulayın.
3. Tam dağıtım öncesi yedek alın.
4. Yedeğin listelenebileceğini ve VM'den kopyalanabildiğini doğrulayın.
5. Yalnızca onaylı migration script'lerini yürütün.
6. Demo veri script'lerini yürütmeyin.
7. Doğrulama script'lerini yürütün.
8. SSMS çalışma tezgahından üretim sağlık kontrollerini çalıştırın.
9. Bitiş zamanını, doğrulama durumunu ve sonraki izleme penceresini kaydedin.

## Dağıtım Sonrası Kontroller

- `core.SchemaMigration`, beklenen uygulanan script'leri içeriyor.
- Gerekli schema'lar mevcut.
- Doğrulama script'leri geçiyor.
- Operatör dashboard'u engelleyici hata olmadan açılıyor.
- RBAC ve denetim kontrolleri beklenen kayıtları döndürüyor.
- Yedek işi durumu sağlıklı.
- SQL Server Hata Günlüğünde dağıtıma ilişkin kritik hata yok.

## Durdurma Koşulları

Şu durumlarda dağıtımı durdurun ve üst kademelere bildirin:

- Hedef veri tabanı veya sunucu adı onaylı ortam değil.
- Dağıtım öncesi yedek başarısız oluyor.
- Bir migration başarısız oluyor.
- Bir doğrulama script'i başarısız oluyor.
- Beklenmedik yıkıcı SQL bulundu.
- Üretim verisi DEV veya TEST'e açık kalacak.
