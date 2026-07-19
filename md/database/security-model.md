# Güvenlik Modeli

Veri tabanı çekirdeği, tenant farkında altyapı ve RBAC dostu tablolar içerecektir:

- `core.Tenant`
- `core.AppUser`
- `core.Role`
- `core.Permission`
- `core.RolePermission`
- `core.UserRole`

İş kök tabloları `tenant_id` içermelidir. Denetim tabloları, uygulama secret'larını
saklamaksızın mümkün olduğunda kimin neyi ne zaman değiştirdiğini korumalıdır.

## Temel RBAC Tabloları

- `core.Tenant`, tenant kimliğini, hukuki adı, görüntü adını, KDV numarasını, ülkeyi,
  varsayılan dili ve aktif durumu saklar.
- `core.AppUser`, tenant kapsamlı uygulama kullanıcılarını ve kimlik doğrulama
  konu meta verisini saklar.
- `core.Role`, tenant'a özgü rolleri ve sistem düzeyindeki rolleri destekler.
- `core.Permission`, modüle göre izin kodlarını saklar.
- `core.RolePermission`, izinleri rollerle eşler.
- `core.UserRole`, kullanıcıları rollerle eşler.

`core.AppUser.person_id`, `person.Person` migration dizisinin ilerleyen bölümlerinde
oluşturulduğu için temel migration sırasında kasıtlı olarak Null olabilir ve kısıtlı
değildir.

## Tenant İzolasyonu

Kök iş tabloları `tenant_id` içerir; bunlara kişi, kuruluş, risk nesnesi, sözleşme,
hasar, belge ve görev kayıtları dahildir. Tenant tutarlılığını uygulayabilen domain'ler
arası referanslar, hasar-sözleşme gibi bileşik kısıtlamalar aracılığıyla bunu yapar.

## Denetim

`audit.AuditLog`, SQL trigger'larından temel tablolar için kök varlık değişikliklerini
kaydeder. Uygulama katmanı denetimi daha sonra bu satırları kullanıcı id ve korelasyon
id bağlamıyla zenginleştirebilir.
