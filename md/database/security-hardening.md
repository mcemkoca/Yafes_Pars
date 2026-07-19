# Güvenlik Güçlendirme

Bu kılavuz, profesyonel bir SQL Server ve SSMS öncelikli Yafes Pars dağıtımı için
minimum güçlendirme kontrollerini listeler.

## Secret'lar

- Parola, token, bağlantı dizesi, sertifika veya yedek dosyalarını commit etmeyin.
- Secret'lar için ortam değişkenleri, secret depolar veya dağıtım araçları kullanın.
- Sohbete, biletlere, günlüklere veya kaynağa yapıştırılan kimlik bilgilerini döndürün.
- CI günlüklerinde secret'ları maskeleyin.

## Windows Server

- Windows Server'ı yamalı tutun.
- Yerel yöneticileri kısıtlayın.
- SQL Server servisleri için adlandırılmış hizmet hesapları kullanın.
- Kullanılmayan servisleri devre dışı bırakın.
- RDP'yi ağ kurallarıyla ve mevcut olduğunda tam zamanında erişimle kısıtlayın.
- Uç nokta korumasını ve olay iletmeyi etkinleştirin.

## SQL Server Örneği

- Onaylı SQL Server kümülatif güncellemelerini uygulayın.
- `sa`'yı devre dışı bırakın veya kısıtlayın.
- En az ayrıcalıklı girişler kullanın.
- Kullanılmayan örnek veri tabanlarını kaldırın.
- Onaylanmadıkça bağlı sunucuları ve harici erişim özelliklerini kısıtlayın.
- Maksimum sunucu belleğini yapılandırın.
- Her dağıtımdan sonra SQL Server Hata Günlüğünü inceleyin.

## Veri Tabanı Erişimi

- Dağıtım, uygulama, destek ve salt okunur erişimi ayırın.
- Yalnızca gerekli izinleri verin.
- Tenant farkında tabloları geniş çaplı geçici güncellemelerden koruyun.
- Kılavuzlu oluşturma işlemleri için stored procedure bridge'leri kullanın.
- Manuel veri düzeltmesi için önce rollback script'leri kullanın.
- Stored procedure bridge'ler, sağlanan her kişi, kuruluş, poliçe, hasar, nesne ve
  operatör kullanıcı ID'si için tenant sahipliğini doğrulamalıdır.

## API Yüzeyi

- Sağlık ve kimlik doğrulama keşif uç noktalarını domain verilerinden ayrı tutun.
- Tenant, kişi, poliçe, hasar, belge, görev, teminat veya arama verisi açığa
  çıkarmadan önce domain okuma uç noktalarında JWT/Bearer yetkilendirmesi gerektirin.
- Yerel DEV dışında eksik otorite veya kitle yapılandırmasını dağıtım engelleyici
  olarak değerlendirin.

## Tenant İzolasyonu

İş kök tabloları `tenant_id` içermelidir. Sorgu şablonları ve dashboard script'leri
operatör iş akışları için tenant bağlamı gerektirmelidir. Tenant'lar arası birleşimler
açık ve incelenmiş olmalıdır.

## RBAC

Platform şunları kullanır:

- `core.Role`
- `core.Permission`
- `core.RolePermission`
- `core.UserRole`

Üretim rolleri, canlıya geçişten önce ve izinleri değiştiren her sürümden sonra
incelenmelidir.

İnceleme kanıtını `md/database/access-review-evidence-template.md` ile kaydedin.
DEV'de, resmi TEST/PROD kanıtını onaylı ortam prosedürü aracılığıyla toplamadan önce
operatör dostu matris olarak `database/ssms/14__admin_role_permission_matrix.sql`
kullanın.

## İzleme

SSMS salt okunur izleme deviri olarak `database/ssms/15__monitoring_and_job_readiness.sql`
kullanın. DEV sağlığını, biriktirme baskısını, yedek görünürlüğünü ve gözlemlenen
Yafes SQL Agent işlerini inceler. TEST/PROD işleri yine de yalnızca adlandırılmış
sahipler, zamanlamalar ve uyarı yollarına sahip onaylı bir DBA tarafından oluşturulmalıdır.

## Denetim

Denetim trigger'ları temel kök tablo değişikliklerini `audit.AuditLog`'a yazar.
Üretim operasyonları ayrıca şunları kaydetmelidir:

- sürüm sahibi
- yürütme zaman damgası
- hedef ortam
- değiştirilen script'ler
- doğrulama durumu
- olay veya rollback kararı

## CI ve Depo Kontrolleri

- Üretim sürüm dalları için dal koruması kullanın.
- Veri tabanı değişiklikleri için pull request incelemesi gerektirin.
- SQL kalite kapısı ve SQL Server doğrulama iş akışlarını zorunlu kılın.
- GitHub Actions ve NuGet için Dependabot'u etkin tutun.
- `SECURITY.md` dosyasını güncel tutun.
