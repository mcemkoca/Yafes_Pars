# SSMS Kurumsal Dashboard Planı

## Hedef

Ürünü bir web uygulamasına dönüştürmeksizin SQL Server Management Studio içinde
tam kurumsal operatör deneyimi oluşturun. Dashboard, SSMS Query Editor, Results Grid,
Messages, SQLCMD Mode ve script tabanlı operasyonları korumalıdır.

## Dashboard İlkeleri

- SSMS birincil arayüz olmaya devam eder.
- Her iş akışı DEV bağlamı doğrulamasıyla başlar.
- Salt okunur dashboard'lar, mutasyon script'lerinden ayrıdır.
- Veri girişi stored procedure bridge'lerinden geçer.
- Veri düzenleme önce rollback bariyer kalıpları kullanır.
- Her sonuç kümesi, faydalı olduğunda net etiketler ve `info_tip` rehberliği içerir.
- Operatörler, GUID yazmaları yerine Results Grid'den ID kopyalar.
- Raporlar Excel/Power BI dışa aktarımı için grafiğe hazır ızgaralar döndürür.

## Dashboard Alanları

| Alan | Script | Amaç |
| --- | --- | --- |
| Ana Sayfa | `05__operator_dashboard_home.sql` | Kısayollar, bağlam, sağlık, sonraki aksiyonlar. |
| Mimari | `11__schema_working_logic_map.sql` | Domain grupları, alt başlıklar, kontrol akışı ve board kartları. |
| Katalog | `12__table_catalog_and_relationships.sql` | Tam tablo kataloğu, kök tablolar ve yabancı anahtar ilişki haritası. |
| Görsel Board | `13__visual_workflow_board.sql` | SSMS güvenli düğüm, kenar, alt başlık ve şablon rota ızgaraları. |
| Günlük | `10__daily_operator_checklist.sql` | BAŞARILI/GÖZDEN GEÇİR/AKSIYON kontrol listesi. |
| Operasyonlar | `02__operations_dashboard.sql` | Müşteri, poliçe, hasar, belge, görev, teminat genel bakışı. |
| Arama | `06__query_library_shortcuts.sql` | Kayıt bulma ve ID kopyalama. |
| Giriş | `07__data_entry_bridge_templates.sql` | Önizleme öncelikli oluşturma aksiyonları. |
| Düzenleme | `08__data_editing_guardrails.sql` | Önce rollback güncellemeleri. |
| Raporlar | `09__graph_report_pack.sql` | Grafik/dışa aktarıma hazır sonuç kümeleri. |
| Denetim | `04__admin_security_audit_queries.sql` | RBAC, denetim, trigger ve bütünlük kontrolleri. |
| Admin | `14__admin_role_permission_matrix.sql` | Rol kapsamı, izin matrisi, kullanıcı atamaları, en az ayrıcalık kontrolleri ve devir satırları. |
| İzleme | `15__monitoring_and_job_readiness.sql` | DEV sağlığı, biriktirme, yedek görünürlüğü, SQL Agent gözlemlenen işleri ve DBA devir satırları. |
| Teslimat | `16__delivery_gap_register.sql` | Commit inceleme kapanması, bitmemiş teslimat boşlukları, sahip engelleyicileri ve sonraki SSMS aksiyonları. |
| Kapanış | `17__remaining_work_cockpit.sql` | Sahip kanıtı, 019+ karar alımı, bridge sıralaması, SQL Agent terfisi ve sürüm kapanış kapıları. |

## Kısayol Modeli

SSMS, Results Grid içinde yerel tıklanabilir uygulama stili düğmeler sağlayamaz.
Dashboard bu nedenle şunları içeren bir kısayol kataloğu döndürür:

- kısayol sırası
- grup
- aksiyon adı
- script yolu
- güvenlik modu
- bilgi ipucu

Operatörler listelenen script'i yeni bir SSMS sekmesinde açar.

## Kullanıcı Dostu Akış

1. Dashboard ana sayfasını açın.
2. Öğrenirken veya değişiklikler planlarken çalışma mantık haritasını inceleyin.
3. Düğüm/kenar ve şablon rota ızgaralarını incelemek için görsel iş akışı board'unu açın.
4. Yeni tablo veya bridge akışları oluşturmadan önce tablo kataloğunu açın.
5. Günlük kontrol listesini çalıştırın.
6. Kaydı arayın ve ID kopyalayın.
7. Oluşturmalar için bridge şablonu kullanın.
8. Güncellemeler için bariyer şablonu kullanın.
9. Erişim değişikliklerinden önce rol/izin matrisini inceleyin.
10. Denetim kontrollerini çalıştırın.
11. DBA deviri öncesinde izleme ve SQL Agent hazırlığını inceleyin.
12. PR/commit veya müşteri incelemesinden sonra teslimat boşluk kaydını inceleyin.
13. Sahip kanıtını, 019+ kararlarını, kenar bridge sıralamasını ve DBA devirini
    atamak için kalan iş kokpitini açın.
14. Gerektiğinde rapor paketi ızgaralarını dışa aktarın.

## Gelecekteki Geliştirmeler

- Daha fazla kılavuzlu oluşturma/düzenleme aksiyonu için stored procedure'ler ekleyin.
- Gerçek operatör kullanımı gözlemlendikten sonra sahip onaylı departman rotalarıyla
  `13__visual_workflow_board.sql`'i genişletin.
- Departman başına özel rapor paketleri ekleyin.
- `14__admin_role_permission_matrix.sql`'den TEST/PROD erişim inceleme kanıtı ekleyin.
- Açık P0-P3 teslimat öğeleri için görünür SSMS kontrol noktası olarak
  `16__delivery_gap_register.sql` kullanın.
- Açık P0-P3 öğelerini kanıt, sahip kararı, bridge sıralaması ve DBA devir
  iş akışlarına dönüştürmek için `17__remaining_work_cockpit.sql` kullanın.
- DEV/TEST sahipleri ve zamanlamaları onaylandıktan sonra izleme sonuç kümelerini
  onaylı SQL Agent işlerine dönüştürün.
- Standart SSMS kayıtlı sunucu talimatları ekleyin.
- Rapor paketi dışa aktarımlarını tüketen Power BI şablonu ekleyin.
- DEV/TEST yürütmesi doğrulandıktan sonra üretim hazırlık kontrol listesini gerçek
  geri yükleme tatbikatı kanıtı, izleme sahipleri ve SQL Agent bakım işleriyle genişletin.

## Kurumsal Hazırlık Bağlantıları

- `../database/ssms-deployment-runbook.md`
- `../database/environment-matrix.md`
- `../database/production-readiness-checklist.md`
- `../database/migration-execution-log-template.md`
