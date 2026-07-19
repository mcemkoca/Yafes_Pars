# Mimari

Yafes Pars, bir sigorta platformu için SQL Server veri tabanı çekirdeği olarak tasarlanmıştır.

Mimari, veri tabanı öncelikli ve domain schema'larıyla organize edilmiştir. Temel SaaS
altyapısı, sigorta iş domain'lerinden ayrıdır; böylece tenant, kullanıcı, rol, izin,
migration ve denetim endişeleri açık kalır.

## Birincil Schema'lar

- `core`
- `ref`
- `person`
- `institution`
- `risk`
- `policy`
- `coverage`
- `claim`
- `document`
- `tasking`
- `audit`

Her migration oluşturuldukça ayrıntılı domain notları genişletilecektir.

## Temel Altyapı

İlk altyapı katmanı migration takibi, tenant kimliği, uygulama kullanıcıları, roller,
izinler ve rol atama tablolarını oluşturur. Bu, daha sonraki SaaS tenant izolasyonu ve
RBAC farkında backend çalışması için temel sağlar.

## Domain Akışı

Derleme sırası bağımlılık yönünü izler:

1. Temel schema'lar ve migration takibi.
2. Tenant, kullanıcı, rol ve izin temeli.
3. Person ve institution domain'leri.
4. `risk.InsurableObject` üzerinden risk nesneleri.
5. Policy sözleşmeleri ve sözleşme versiyonları.
6. Coverage ve claim domain'leri.
7. Belge meta verisi ve görev/hatırlatıcı domain'leri.
8. Denetim günlüğü, kısıtlamalar, indeksler, trigger'lar, view'lar, procedure'lar ve
   seed verisi.

Backend/API çalışması, SSMS doğrulaması geçtikten sonra bu veri tabanı modelini tüketmelidir.

## Dağıtım Mimarisi

Üretim hedefi, birincil operasyonel arayüz olarak SQL Server ve SSMS ile Azure Windows
Server'dır. Dağıtım ve hazırlık ayrıntıları odaklanmış runbook'lara bölünmüştür:

- `azure-windows-server-deployment.md`
- `ssms-deployment-runbook.md`
- `sql-server-installation-checklist.md`
- `backup-restore-strategy.md`
- `security-hardening.md`
- `environment-matrix.md`
- `production-readiness-checklist.md`
