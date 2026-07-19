# Raporlar ve Grafikler

## Amaç

SSMS dostu rapor ve grafik veri kümeleri sağlayın.

## Ana Script

Kullanın:

```text
database/ssms/09__graph_report_pack.sql
```

## Sonuç Kümeleri

- Domain'e göre poliçe portföyü
- Duruma göre hasarlar
- Görev vade yaşlanması
- Sonraki 90 günlük yenileme takvimi
- Teminat paketi matrisi
- Dışa aktarma kataloğu

## Grafik Verisini Kullanma

SSMS Query Editor, modern dashboard grafikleri değil ızgaralar döndürür. Bu
nedenle rapor paketi şunları içerir:

- `chart_axis`
- `chart_value`
- `text_bar`
- dışa aktarmaya hazır etiketler

Görsel grafikler gerektiğinde ızgarayı Excel veya Power BI'a kopyalayın.

## Bilgi İpuçları

- Yalnızca SSMS'de hızlı okuma için metin çubuklarını kullanın.
- Doğru sonuç kümesini seçmek için dışa aktarma kataloğunu kullanın.
- Raporları salt okunur tutun; raporlama ve düzenlemeyi aynı sekmede karıştırmayın.
