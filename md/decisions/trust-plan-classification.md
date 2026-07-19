# Karar: Trust-Plan Klasörü Sınıflandırması

**Tarih:** 2026-07-19
**Sahip:** Deuterium12{MCK}
**Durum:** KARARA BAĞLANDI

## Bağlam

`md/trust-plan/` klasörü, ekip eski web öncelikli bir mimariden mevcut SSMS öncelikli
yaklaşıma geçişi değerlendirirken ilk teknik keşif aşamasında oluşturuldu. Eski
içe aktarılan paketten temizlenmiş karşılaştırma notlarını, tablo sayısı geçmişini
ve UX derslerini içermektedir.

## Karar

`md/trust-plan/` dizinini **salt okunur eski referans klasörü** olarak tutun.

- SİLMEYİN: tablo sayısı evrimine ve SSMS öncelikli pivotun gerekçesine ilişkin
  telafi edilemez bağlamı içermektedir.
- KOPYALAMAYIN: eski kimlik bilgileri, docker varsayılanları, CORS örnekleri veya
  web öncelikli mimari bu klasörden aktif ürüne aktarılmamalıdır.
- GÜNCELLEMEYİN: klasör, eski planın yerini alındığı andaki durumda dondurulmuştur.

## Aktif Gerçek Kaynakları (trust-plan'ın yerini alır)

| Endişe | Aktif konum |
|---------|----------------|
| Veri tabanı schema'sı | `database/migrations/` |
| SSMS çalışma tezgahı | `database/ssms/` |
| Proje planı | `md/mustafaplan.md` |
| Tablo mutabakatı | `md/database/table-reconciliation-89-vs-108.md` |
| Müşteri genel bakışı | `README.md` |

## İçerik Sınıflandırması

| Dosya/Klasör | Sınıflandırma |
|------------|----------------|
| `trust-plan/README.md` | ESKİ — karşılaştırma bağlamı |
| `trust-plan/legacy-reference-summary.md` | ESKİ — tablo sayısı geçmişi |
| `trust-plan/research/` | ESKİ — erken tasarım araştırması anlık görüntüleri |

## Gerekçe

Eski notların silinmesi, mimari kararlar için denetim izini ortadan kaldırır. Birinin
eski talimatlara göre hareket etme riski, `trust-plan/README.md`'de zaten mevcut
olan sınıflandırma başlığıyla azaltılmıştır.
