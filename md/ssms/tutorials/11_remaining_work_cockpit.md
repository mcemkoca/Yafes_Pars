# Kalan İş Kokpiti

Teslimat boşluk kaydından sonra bu ekranı kullanın. Açık engelleyicileri
uygulanabilir sahip kanıtı, 019+ kararı, bridge sıralaması ve DBA devir satırlarına
dönüştürür.

## Açma

1. `database/ssms/17__remaining_work_cockpit.sql` dosyasını açın.
2. `Query > SQLCMD Mode` etkinleştirin.
3. `YAFES_SQL_DATABASE`'in `DEV` içerdiğini doğrulayın.
4. `TENANT_CODE`'un incelediğiniz tenant olduğunu doğrulayın.
5. Script'i çalıştırın.

## Izgaraları Okuma

1. `02 - İş akışı kapanış board'u`, kalan her iş akışını, sahibini, gereken
   kanıtı ve durdurma koşulunu gösterir.
2. `03 - Ortam kanıtı deviri`, TEST/PROD migration, erişim ve geri yükleme kanıt
   artifakt'larını listeler.
3. `04 - 019+ adayları için sahip karar girişi`, tablo oluşturmadan finans,
   içe aktarma, ürün ve not kararlarını hazırlar.
4. `05 - Sonraki bridge iş akışı sıralama kuyruğu`, bir sonraki prosedür destekli
   aksiyonu sıralamaya yardımcı olur.
5. `06 - SQL Agent terfi board'u`, SQL Agent işleri oluşturmadan DBA iş onayını
   hazırlar.
6. `07 - Sürüm öncesi kapanış kapıları`, sürüm kapılarını özetler.

## Operatör Kuralı

Yalnızca bu ekrandan migration `019+`, SQL Agent işleri veya yeni bridge
prosedürleri uygulamayın. Önce sahip kararlarını toplamak için kokpiti kullanın,
ardından ayrı bir incelenmiş değişiklikte ileri yönlü bir migration veya stored
procedure ekleyin.
