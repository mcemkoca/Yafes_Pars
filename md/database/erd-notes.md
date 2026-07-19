# ERD Notları

Mevcut eski ERD görüntüleri `ERD/` altında kalmaya devam eder. SQL Server migration
seti artık schema-nitelikli domain tabloları kullandığından, yeni ERD belgeleri
şurada tutulmaktadır:

- `md/database/erd-mermaid.md`

## Domain Bölünmesi

- `core`: tenant'lar, kullanıcılar, roller, izinler.
- `person`: gerçek/tüzel kişiler, kişiler, ilişkiler, banka ve ehliyet verisi.
- `institution`: sigortacılar, brokerlar, bankalar, tanımlayıcılar, adresler.
- `risk`: sigortalanabilir nesne kökü artı araç, gayrimenkul, kredi, kişi, nesne
  ve faaliyet alt türleri.
- `policy`: sözleşmeler, versiyonlar, taraflar, nesneler, versiyon nesneleri, devirler.
- `coverage`: teminatlar, domain eşlemeleri, paketler, paket kalemleri.
- `claim`: hasarlar, hasar tarafları, hasar nesneleri, hasar koşulları.
- `document`: yalnızca meta veri belgeleri, bağlantılar, versiyonlar.
- `tasking`: görevler, yorumlar, hatırlatıcılar.
- `audit`: denetim günlüğü ve sütun başına değişim kümeleri.

## Eski Eşleme Notları

- Eski `Object`, `risk.InsurableObject`'e eşlendi.
- Eski `ObjectVehicle`, `risk.InsurableVehicle`'a eşlendi.
- Eski `ObjectRealEstate`, `risk.InsurableRealEstate`'e eşlendi.
- Eski `Contract_Object`, `policy.ContractObject`'e eşlendi.
- Eski `ContractVersion_Object`, `policy.ContractVersionObject`'e eşlendi.
- Eski `Claim_Object`, `claim.ClaimObject`'e eşlendi.
- Eski `lookup_coverage`, `coverage.Coverage`'a eşlendi.
- Eski `coverage_domain`, `coverage.CoverageDomain`'e eşlendi.

## Diyagram Stratejisi

Tam model, tek pratik bir diyagram için çok büyük. Navigasyon için bir üst düzey
domain'ler arası ERD, ardından uygulama ayrıntısı için `erd-mermaid.md`'deki
domain düzeyi diyagramlar kullanın.
