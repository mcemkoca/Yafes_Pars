# Eski Referans Özeti

Bu klasör artık arındırılmış bir referans alanıdır. Eski web-öncelikli uygulama
planları, VM dağıtım notları, paket readme'leri ve kopyalanan görev planları
aktif dokümantasyon ağacından kaldırıldı.

## Saklanan Faydalı Dersler

| Ders | Mevcut ürün kararı |
| --- | --- |
| Sigorta modelinin net kişi, kuruluş, risk/nesne, poliçe ve hasar domain'lerine ihtiyacı var. | Mevcut migration'lar bu domain'leri korur ve SQL Server schema'larına yerleştirir. |
| Operatörler ham tablo düzenlemesi değil kılavuzlu akışlara ihtiyaç duyar. | SSMS çalışma tezgahı script'leri dashboard'lar, bridge şablonları, güvenceler, öğreticiler ve bilgi ipuçları sağlar. |
| Eski paket 89 tabloya referans veriyordu. | `md/database/table-reconciliation-89-vs-108.md`, mevcut kaynakta neden 108 tablo bulunduğunu kaydeder. |
| Görsel planlama, modeli açıklamaya yardımcı olur. | `13__visual_workflow_board.sql`, görsel fikri SSMS güvenli düğüm, kenar ve rota ızgaralarına dönüştürür. |

## Burada Hâlâ Faydalı Dosyalar

- `research/insurance_schema_comparison.md`
- `research/below_70_comparison.md`

Bunlar yalnızca karşılaştırma notlarıdır. Uygulama kaynağı değildir.

## Aktif Belgelerden Kaldırılan Dosyalar

- eski React/web dashboard planları
- eski VM/VHDX dağıtım notları
- kopyalanmış sıfır hata/araştırma/GitHub görev planları
- eski sunucu/paket readme'leri

Gerçeğin üretim kaynağı, kök depo ve `md/` klasörlerindeki SQL, SSMS ve
dokümantasyon yapısıdır.
