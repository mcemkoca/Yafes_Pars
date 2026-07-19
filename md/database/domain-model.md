# Domain Modeli

Platform şu sigorta temel domain'leri etrafında organize edilmiştir:

- Kişi ve müşteri yönetimi
- Kuruluş yönetimi
- Sigortalanabilir nesneler
- Poliçeler ve sözleşmeler
- Sözleşme versiyonları
- Teminatlar
- Hasarlar
- Belgeler
- Görevler ve hatırlatıcılar
- Denetim ve uyumluluk

Sözleşme versiyonlama temel bir domain kavramıdır ve açık kalmalıdır.

## Person Domain'i

Person domain'i, tenant farkında kök olarak `person.Person`'ı kullanır. Gerçek ve
tüzel kişiler `person.NaturalPerson` ve `person.LegalPerson`'a bölünmüştür.
İletişim verisi adres, telefon, e-posta, sosyal medya, banka hesabı ve sürücü
belgesi tablolarıyla temsil edilir.

Eski birleştirme tablosu adları PascalCase'e normalleştirildi:

- `Person_PersonType`, `person.PersonPersonType` oldu.
- `PersonRelation_Person`, `person.PersonRelationPerson` oldu.

## Institution Domain'i

Institution domain'i, sigortacılar, bankalar, brokerlar ve ortak şirketler için
tenant farkında kök olarak `institution.Institution`'ı kullanır. Tanımlayıcılar ve
adresler, tür ve rol arama tablolarıyla alt tablolar olarak modellenir.

## Risk Domain'i

Eski nesne domain'i `risk.InsurableObject` ve alt tür tablolarına yeniden
düzenlendi. Hiçbir tablo `Object` olarak adlandırılmaz; alt türler `InsurableVehicle`,
`InsurableRealEstate`, `InsurableLoan`, `InsurablePerson`, `InsurableThing` ve
`InsurableActivity` kullanır.

## Policy Domain'i

Policy domain'i, tenant farkında kök olarak `policy.Contract`'ı ve yaşam döngüsü
geçmişi modeli olarak `policy.ContractVersion`'ı kullanır. Taraflar `person.Person`'a
bağlanır; sigortalı nesneler `risk.InsurableObject`'e bağlanır.

## Coverage Domain'i

Coverage domain'i, eski `lookup_coverage` ve `coverage_domain` tablolarının
yerini schema-nitelikli `coverage.Coverage` ve `coverage.CoverageDomain` ile alır.
Teminat paketleri, poliçe domain'i başına yeniden kullanılabilir paketlere izin verir.

## Claim Domain'i

Claim domain'i, tenant farkında kök olarak `claim.Claim`'i kullanır. Hasarlar
`policy.Contract`, isteğe bağlı `coverage.Coverage`, hasar tarafları, hasar nesneleri
ve koşul türlerine bağlanır.

## Document Domain'i

Belgeler, depolama sağlayıcısı ve depolama anahtarı alanlarına sahip meta veri
kayıtları olarak temsil edilir. İkili dosya içeriği kasıtlı olarak SQL Server dışında
depolanır. Belgeler versiyonlanabilir ve kişilere, kuruluşlara, poliçelere, hasarlara
veya risk nesnelerine bağlanabilir.

## Task Domain'i

Görevler, kişiye, kuruluşa, poliçeye, hasara, risk nesnesine veya belgeye işaret
edebilen tenant farkında operasyonel kayıtlardır. Yorumlar ve hatırlatıcılar alt
tablolar olarak modellenir.

## Audit Domain'i

Denetim günlüğü `audit.AuditLog`'da merkezileştirilir. İlk migration versiyonu,
temel kök tablolar için minimal insert/update/delete trigger'ları ekler: kişi,
kuruluş, sigortalanabilir nesne, sözleşme, sözleşme versiyonu ve hasar.
