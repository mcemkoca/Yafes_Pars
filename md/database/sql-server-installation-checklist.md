# SQL Server Kurulum Kontrol Listesi

Yeni bir SQL Server örneğinde Yafes Pars migration'larını çalıştırmadan önce bu
kontrol listesini kullanın.

## Windows Server

- [ ] Windows Server yamalandı.
- [ ] Saat dilimi ve NTP senkronizasyonu yapılandırıldı.
- [ ] Yerel yönetici erişimi kısıtlandı.
- [ ] RDP erişimi onaylı kaynaklarla kısıtlandı.
- [ ] Windows Defender veya onaylı uç nokta koruması etkinleştirildi.
- [ ] Veri, günlük, tempdb ve yedek klasörleri oluşturuldu.
- [ ] Disk boş alan uyarıları yapılandırıldı.

## SQL Server Kurulumu

- [ ] SQL Server sürümü ortamla eşleşiyor.
- [ ] En son onaylı SQL Server kümülatif güncellemesi yüklendi.
- [ ] SQL Server hizmet hesabı adanmış ve etkileşimli olmayan.
- [ ] Agent kullanıldığında SQL Server Agent hizmet hesabı adanmış.
- [ ] Karma mod yalnızca SQL girişleri gerektiğinde etkin.
- [ ] `sa` mümkün olduğunda politika gereği devre dışı veya korumalı.
- [ ] TCP/IP yalnızca gerekli arayüzler için etkin.
- [ ] SQL Browser açıkça gerekmedikçe devre dışı.
- [ ] Maksimum sunucu belleği yapılandırıldı.
- [ ] tempdb uygun dosya sayısı, boyutu ve büyüme ayarlarına sahip.
- [ ] Veri tabanı varsayılan harmanlama belgelendi.

## Gerekli Araçlar

- [ ] SQL Server Management Studio operatörler için yüklendi.
- [ ] `sqlcmd` gerektiğinde otomatik DEV/CI doğrulaması için yüklendi.
- [ ] PowerShell, depo araçlarını çalıştırabilir.
- [ ] Git istemcisi mühendislik iş istasyonlarında mevcut.

## Veri Tabanı Hazırlığı

- [ ] Hedef veri tabanı adı ortam matrisiyle eşleşiyor.
- [ ] Veri tabanı sahibi onaylandı.
- [ ] Veri ve günlük dosyası konumları doğru.
- [ ] Kurtarma modeli yedek stratejisiyle eşleşiyor.
- [ ] Yedek konumu SQL Server tarafından yazılabilir.
- [ ] Migration öncesi yedek test edildi.

## Depo Hazırlığı

- [ ] Sürüm dalı veya etiketi onaylandı.
- [ ] Statik kalite kapısı geçiyor.
- [ ] `000`'dan `018`'e migration sırası değişmedi.
- [ ] Varsa yeni migration'lar `019`'dan başlıyor.
- [ ] Depo dosyalarında secret yok.
