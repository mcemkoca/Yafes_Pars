# Depo Geliştirme Planı

Bu plan, SSMS öncelikli, veri tabanı öncelikli Yafes Pars deposu için sonraki
profesyonelleştirme adımlarını kapsar.

## A. Kritik Bulgular

- Ürün yönü SQL Server ve SSMS öncelikli, web öncelikli değil.
- Migration sırası `000`'dan `018`'e kararlı kalmalıdır.
- Üretim dağıtımı Azure Windows Server, SQL Server, yedek, geri yükleme,
  güvenlik ve yürütme runbook'larına ihtiyaç duyar.
- Statik kalite kontrolleri daha ağır SQL Server doğrulamasından önce çalışmalıdır.

## B. Bozulmaması Gereken Mevcut Yapı

- `database/legacy/`
- `database/migrations/`
- `database/rollback/`
- `database/validation/`
- `md/database/`
- `database/templates/`
- `database/ssms/`
- `UML/`
- `ERD/`
- `md/trust-plan/` yalnızca temizlenmiş karşılaştırma notları olarak

## C. Azure Windows Server Hedef Mimarisi

SQL Server'ı özel ağ erişimiyle bir Azure Windows Server VM'inde çalıştırın, mümkün
olduğunda veri/günlük/tempdb/yedek depolamayı ayırın ve operatör yüzeyi olarak SSMS
kullanın. Azure izleme ve VM dışı yedek depolama kullanın.

## D. SQL Server ve SSMS Dağıtım Planı

Dağıtımı script tabanlı tutun. Operatörler SSMS Query Editor, Results Grid, Messages
ve SQLCMD Mode kullanır. DEV korumalı PowerShell çalıştırıcısını kullanabilir. TEST
ve PROD, SSMS dağıtım runbook'unu ve yürütme günlüğünü izler.

## E. Migration ve Doğrulama Planı

Migration'ları `000`'dan `018`'e koruyun. Yeni ileri migration'lar `019`'dan başlar.
Doğrulama script'leri sıralı kalır ve migration'lardan sonra çalıştırılmalıdır.
Rollback script'leri ayrı kalır ve manuel olarak onaylanır.

## F. Güvenlik Güçlendirme Planı

Üretim öncesinde en az ayrıcalık, özel SQL erişimi, kısıtlı RDP, kimlik bilgisi
rotasyonu, Git dışı secret saklama, RBAC incelemesi, tenant izolasyon incelemesi
ve denetim günlüğü incelemesi kullanın.

## G. Yedek, Geri Yükleme ve DR Planı

RPO/RTO'yu iş sahibiyle tanımlayın. Tam yedekler, isteğe bağlı fark yedekler, tam
kurtarma için günlük yedekler, zorunlu dağıtım öncesi yedekler ve düzenli geri
yükleme tatbikatları kullanın.

## H. İzleme ve Bakım Planı

SQL Server kullanılabilirliğini, yedek yaşını, SQL Agent işlerini, disk alanını,
hata günlüklerini, başarısız girişleri ve doğrulama sonuçlarını izleyin. Gerçek
veri hacmi bilindiğinde indeks/istatistik çalışması için bakım pencerelerini gözden
geçirin. Onaylı SQL Agent işleri oluşturulmadan önce SSMS salt okunur deviri olarak
`database/ssms/15__monitoring_and_job_readiness.sql` kullanın.

## I. Depo Dosyası ve Belgeleme Güncelleme Listesi

- Azure Windows Server dağıtım kılavuzu ekleyin.
- SSMS dağıtım runbook'u ekleyin.
- SQL Server kurulum kontrol listesi ekleyin.
- Yedek ve geri yükleme stratejisi ekleyin.
- Güvenlik güçlendirme kılavuzu ekleyin.
- Migration yürütme günlüğü şablonu ekleyin.
- Erişim inceleme kanıt şablonu ekleyin.
- Geri yükleme tatbikatı kanıt şablonu ekleyin.
- Tablo mutabakat kaydı ekleyin.
- Ortam matrisi ekleyin.
- Üretim hazırlık kontrol listesi ekleyin.
- Statik SQL kalite kapısı script'i ve CI iş akışı ekleyin.
- SSMS izleme ve SQL Agent hazırlık sonuç kümeleri ekleyin.

## J. Yeni SQL Script Önerileri

- Yalnızca yeni veri tabanı değişiklikleri için `019+` migration ekleyin.
- Her yeni domain veya paylaşılan davranış için eşleşen doğrulama script'leri ekleyin.
- Yeni kılavuzlu operatör aksiyonları için SSMS bridge script'leri ekleyin.
- Yeni yönetici veya operasyonel dashboard'lar için rapor paketi script'leri ekleyin.
- DEV/TEST sahipleri, zamanlamalar ve uyarı yolları onaylandıktan sonra izleme
  sonuç kümelerini onaylı SQL Agent işlerine dönüştürün.

## K. Üretim Hazırlık Kontrol Listesi

`md/database/production-readiness-checklist.md` dosyasını tek hazırlık kapısı
olarak kullanın. Her istisnada bir sahip, gerekçe ve son kullanma tarihi olmalıdır.

## L. Riskler ve Azaltmalar

| Risk | Azaltma |
| --- | --- |
| Yanlış ortam yürütmesi | SSMS güvenlik script'leri, ortam matrisi ve runbook durdurma koşulları. |
| Eksik yedek | Dağıtım öncesi yedek zorunluluğu ve yürütme günlüğü kanıtı. |
| Güvensiz SQL | Statik kalite kapısı ve uzman incelemesi. |
| Tenant'lar arası veri hataları | Tenant zorunlu şablonlar ve RBAC/denetim incelemesi. |
| Secret ifşası | Secret yasağı politikası ve kimlik bilgisi rotasyonu. |

## M. Somut Yürütme Sırası

1. Mevcut migration sırasını değiştirmeden koruyun.
2. Statik SQL kalite kapısını çalıştırın.
3. DEV/CI'da SQL Server doğrulamasını çalıştırın.
4. TEST'te SSMS dağıtımını prova edin.
5. Yedek/geri yükleme tatbikatını tamamlayın.
6. Üretim hazırlık kontrol listesini tamamlayın.
7. Onaylı PROD sürüm runbook'unu yürütün.
