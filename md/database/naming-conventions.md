# Adlandırma Kuralları

## Schema'lar

`person`, `policy` ve `claim` gibi küçük harfli domain schema adları kullanın.

## Tablolar

PascalCase tekil tablo adları kullanın:

- `person.Person`
- `risk.InsurableObject`
- `policy.Contract`
- `policy.ContractVersion`

## Sütunlar

snake_case sütun adları kullanın:

- `tenant_id`
- `created_at_utc`
- `contract_number`

## Veri Tabanı Nesneleri

- Birincil anahtarlar: `PK_<Tablo>`
- Yabancı anahtarlar: `FK_<KaynakTablo>_<HedefTablo>_<Amaç>`
- Benzersiz kısıtlamalar: `UQ_<Tablo>_<SütunVeyaİşAnahtarı>`
- Kontrol kısıtlamaları: `CK_<Tablo>_<Kural>`
- İndeksler: `IX_<Tablo>_<SütunListesi>`
- Varsayılanlar: `DF_<Tablo>_<Sütun>`
- Trigger'lar: `TR_<Tablo>_<Aksiyon>`
- View'lar: `VW_<Domain>_<Ad>`
- Stored procedure'ler: `SP_<Domain>_<Aksiyon>`
