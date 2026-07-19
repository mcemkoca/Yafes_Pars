# Azure Windows Server Dağıtımı

Bu kılavuz, SSMS öncelikli SQL Server işletim modelini korurken Yafes Pars için
hedef Azure Windows Server dağıtım modelini tanımlar.

## Hedef Model

Yafes Pars, Azure'daki bir Windows Server sanal makinesinde SQL Server veri tabanı
çekirdeği olarak dağıtılır. SQL Server Management Studio, dağıtım, doğrulama, destek
ve kontrollü veri işlemleri için birincil operatör yüzeyi olarak kalmaya devam eder.

Önerilen üretim temeli şöyledir:

- Kuruluş ağ sınırına bağlı Azure Windows Server VM'i.
- DEV için SQL Server Developer, lisans ihtiyaçlarına göre TEST ve PROD için SQL Server
  Standard veya Enterprise.
- SQL Server Management Studio, admin iş istasyonlarına veya sertleştirilmiş bir
  yönetim VM'ine kurulur.
- SQL Server için yalnızca özel ağ erişimi.
- VM diskinin dışında depolanan Azure Backup veya SQL Server yerel yedekleri.
- Windows Olay Günlüğü, SQL Server Hata Günlüğü, SQL Agent geçmişi ve yedek günlükleri
  merkezi olarak toplanır.

## Ortam Düzeni

| Ortam | Amaç | Veri tabanı adı | Demo veri | Erişim |
| --- | --- | --- | --- | --- |
| DEV | Geliştirici doğrulama ve SSMS prova çalışmaları | `YafesPars_DEV` | İzinli | Yalnızca mühendislik |
| TEST | Sürüm provası ve UAT | `YafesPars_TEST` | İsteğe bağlı temizlenmiş veri | Mühendislik ve test kullanıcıları |
| PROD | Canlı iş verisi | `YafesPars` | İzin verilmez | Kısıtlı operasyon grubu |

DEV ve TEST, migration'lardan yeniden oluşturulabilir. PROD yalnızca
onaylı sürüm yürütmesiyle değiştirilebilir.

## Azure Kaynak Temeli

| Kaynak | Temel |
| --- | --- |
| Kaynak grubu | Ortam başına bir grup veya açık ortam etiketleri. |
| Sanal ağ | Veri tabanı VM'i için özel alt ağ. |
| Ağ güvenlik grubu | SQL'e yalnızca onaylı admin/uygulama alt ağlarından izin ver. |
| VM diski | Mümkün olduğunda veri, günlük ve tempdb için Premium SSD. |
| Yedek depolama | Ayrı depolama hesabı veya Kurtarma Hizmetleri kasası. |
| İzleme | Azure Monitor artı SQL Server günlükleri. |
| Secret'lar | Onaylı secret yöneticisinde saklanır, asla depo dosyalarında değil. |

## SQL Server VM Düzeni

Mümkün olduğunda ayrı birimler kullanın:

- `C:` işletim sistemi ve araçlar.
- `D:` SQL Server veri dosyaları.
- `L:` SQL Server günlük dosyaları.
- `T:` tempdb dosyaları.
- `B:` yedekler için VM dışına kopyalamadan önce yerel hazırlık alanı.

Daha küçük bir DEV VM daha az disk kullanıyorsa, aynı runbook'ların
hâlâ geçerli olması için mantıksal klasör ayrımını koruyun.

## Ağ Kuralları

- SQL Server'a genel erişimi devre dışı bırakın.
- VPN, Bastion, özel endpoint kalıpları veya bir atlama sunucusu tercih edin.
- TCP 1433'ü onaylı kaynak aralıklarıyla kısıtlayın.
- RDP'yi admin kaynaklarıyla ve mevcut olduğunda tam zamanında erişimle kısıtlı tutun.
- Her geçici istisnayı yürütme günlüğüne kaydedin.

## Dağıtım Akışı

1. Windows Server VM'ini sağlayın.
2. SQL Server'ı kurun ve yamalayın.
3. SQL Server hizmet hesaplarını ve depolama klasörlerini yapılandırın.
4. Ortam için hedef veri tabanını oluşturun.
5. Yedek konumunu yapılandırın ve SQL Server'ın yazabildiğini doğrulayın.
6. SSMS'de `database/ssms/00__open_first_safety_check.sql` çalıştırın.
7. Depodan statik kalite kapısını çalıştırın.
8. Migration'ları `000`'dan `018`'e sırasıyla çalıştırın.
9. Doğrulamaları `001`'den `017`'ye sırasıyla çalıştırın.
10. Üretim hazırlık kontrol listesini tamamlayın.

## Üretim Koruyucuları

- PROD'da demo seed `018__seed_demo_data.sql` çalıştırmayın.
- Ayrı bir onay kaydı olmadan rollback script'lerini çalıştırmayın.
- Git'te parola, token, bağlantı dizesi veya yedek dosyaları saklamayın.
- `000`'dan `018`'e migration numaralarını değiştirmeyin.
- Yeni ileri migration'lar `019`'dan başlamalıdır.
