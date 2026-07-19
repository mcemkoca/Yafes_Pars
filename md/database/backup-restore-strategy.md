# Yedek ve Geri Yükleme Stratejisi

Yafes Pars, SQL Server'ın yerel yedek ve geri yükleme uygulamalarına dayanır. Yedekler
herhangi bir üretim dağıtımından önce planlanmalıdır.

## Hedefler

| Ortam | RPO hedefi | RTO hedefi | Notlar |
| --- | --- | --- | --- |
| DEV | Mümkün olan en iyi | Aynı gün | Migration'lardan yeniden oluşturma kabul edilebilir. |
| TEST | 24 saat | Aynı gün | Geri yükleme tatbikatları PROD'u yansıtmalıdır. |
| PROD | İş tanımlı | İş tanımlı | Başlatmadan önce paydaşlarla onaylayın. |

Yukarıdaki RPO ve RTO değerleri, iş sahibi üretim hedeflerini onaylayana kadar yer tutucudur.

## Yedek Türleri

- Tam yedek: temel kurtarma noktası.
- Fark yedeği: isteğe bağlı döngü ortası kurtarma noktası.
- İşlem günlüğü yedeği: PROD tam kurtarma modelini kullandığında zorunlu.
- Dağıtım öncesi yedek: üretim schema değişikliklerinden önce zorunlu.

## Önerilen PROD Zamanlaması

| Yedek | Sıklık | Saklama |
| --- | --- | --- |
| Tam | Günlük | 14 ila 35 gün |
| Fark | 4 ila 6 saatte bir | 7 ila 14 gün |
| İşlem günlüğü | 15 ila 30 dakikada bir | 7 ila 14 gün |
| Dağıtım öncesi | Her sürümden önce | Garanti süresi boyunca sakla |

Sıklığı onaylanan RPO/RTO ve veri tabanı boyutuna göre ayarlayın.

## Yedek Depolama

- Yedek dosyalarını depo klasörlerinin dışında tutun.
- Yedek dosyalarını SQL Server VM'inden dışarı kopyalayın.
- Depolamayı özel erişim ve rol tabanlı izinlerle koruyun.
- Sürüm ve politika desteklediğinde yedekleri şifreleyin.
- Yedek işi başarısızlığını ve yedek yaşını izleyin.

## Geri Yükleme Tatbikatı

Üretim başlatmadan ve büyük sürüm değişikliklerinden sonra geri yükleme tatbikatı çalıştırın:

1. En son tam yedeği TEST'e veya izole bir geri yükleme ortamına geri yükleyin.
2. Kullanılıyorsa fark ve günlük yedeklerini uygulayın.
3. Doğrulama script'lerini çalıştırın.
4. SSMS operatör dashboard'unu açın.
5. Geri yükleme başlangıç saatini, bitiş saatini ve doğrulama durumunu kaydedin.

Sonucu `md/database/restore-drill-evidence-template.md` ile kaydedin.

## Dağıtım Öncesi Yedek

Üretim migration'ından önce:

1. Uzun süreli kritik iş sürecinin etkin olmadığını doğrulayın.
2. Tam yedek oluşturun.
3. Yedek dosyasının var olduğunu ve yakın zaman damgasına sahip olduğunu doğrulayın.
4. VM'den dışarı kopyalanabildiğini doğrulayın.
5. Yedek adını yürütme günlüğüne kaydedin.

## Geri Yükleme Karar Yolu

Geri yüklemeyle rollback, otomatik bir script aksiyonu değil operasyonel bir karardır.
PROD'u geri yüklemeden önce sürüm sahibi, veri tabanı sahibi ve iş sahibi anlaşmalıdır.
