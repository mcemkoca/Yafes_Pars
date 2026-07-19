# Belgeleme Temizlik Raporu — 2026-07-19

## Kapsam

Eski, yanıltıcı veya arşiv bağlamı eklenmesi gereken Markdown dosyalarının periyodik
sınıflandırması.

## İncelenen Dosyalar

### `md/reports/final-progress-report.md`

| Alan | Değer |
|-------------|-------|
| Durum | ARŞİVLENDİ |
| Dal referansı | `feature/complete-db-validation-backend-frontend-foundation` (silindi) |
| Alınan aksiyon | Tarih ve bağlam notu ile ARŞİV başlığı eklendi |
| Korundu mu? | Evet — geçmiş kayıt bozulmadan korundu |
| Gerekçe | Silinmiş bir dala referans veriyor; derleme sonuçları mevcut koddan yeniden üretilemiyor |

### `md/trust-plan/README.md`

| Alan | Değer |
|-------------|-------|
| Durum | ESKİ / YALNIZCA REFERANS |
| Alınan aksiyon | `md/decisions/trust-plan-classification.md`'de sınıflandırıldı |
| Korundu mu? | Evet |
| Gerekçe | Kullanışlı karşılaştırma notları ve tablo sayısı geçmişi içeriyor; yanıltıcı değil |

### `md/trust-plan/legacy-reference-summary.md`

| Alan | Değer |
|-------------|-------|
| Durum | ESKİ / YALNIZCA REFERANS |
| Alınan aksiyon | `md/decisions/trust-plan-classification.md`'de sınıflandırıldı |
| Korundu mu? | Evet |
| Gerekçe | Eski karşılaştırma materyali; etkinleştirilebilir talimat yok |

### `md/trust-plan/research/`

| Alan | Değer |
|-------------|-------|
| Durum | ESKİ / SALT OKUNUR |
| Alınan aksiyon | Arşiv alt klasörü olarak sınıflandırıldı |
| Korundu mu? | Evet |
| Gerekçe | Erken tasarım aşamasından araştırma anlık görüntüleri; uygulanabilir değil |

## İncelenmeyen Dosyalar (kapsam dışı)

- `md/reports/dev-validation-evidence-*.md` — DEV ortamı için hâlâ geçerli
- `md/reports/productization-report-2026-06-22.md` — güncel
- `md/database/` dosyaları — aktif olarak bakımda
- `md/mustafaplan.md` — güncel proje planı

## Uygulanan Temizlik Kuralları

1. **Eski dal referansları** → tarih ve silme notu ile ARŞİV başlığı ekle
2. **Eski karşılaştırma klasörleri** → sınıflandırma karar belgesi ekle; silme
3. **Mevcut derleme kanıtı** → aksiyon yok; eski olarak işaretlemeden önce git geçmişine karşı doğrulandı

## Sonraki Planlanmış İnceleme

`main` dalına her büyük kilometre taşı birleştirmesinden önce. Sahip: Deuterium12{MCK}.
