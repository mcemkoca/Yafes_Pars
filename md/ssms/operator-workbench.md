# SSMS Operatör Çalışma Tezgahı

Bu klasör, Yafes Pars için SSMS öncelikli operasyonel arayüzdür. SQL Server
Management Studio içinde çalışan ve net kısayollara, güvenli veri girişine,
kılavuzlu güncellemelere, rapor ızgaralarına, öğreticilere ve bilgi ipuçlarına
ihtiyaç duyan kullanıcılar için oluşturulmuştur.

Bu dosyaları SQL Server Management Studio'da açın ve `:setvar` veya `:r` içeren
script'ler için `Query > SQLCMD Mode` etkinleştirin.

## Operatör Başlangıç Noktası

1. `00__open_first_safety_check.sql`
2. `05__operator_dashboard_home.sql`
3. `11__schema_working_logic_map.sql`
4. `13__visual_workflow_board.sql`
5. `12__table_catalog_and_relationships.sql`
6. `10__daily_operator_checklist.sql`
7. `02__operations_dashboard.sql`
8. `14__admin_role_permission_matrix.sql`
9. `15__monitoring_and_job_readiness.sql`
10. `16__delivery_gap_register.sql`
11. `17__remaining_work_cockpit.sql`

`05__operator_dashboard_home.sql` dosyasını SSMS ana sekmesi olarak açık tutun.
Kısayol ızgaraları, sağlık sinyalleri ve önerilen sonraki aksiyonlar döndürür.

## Script Kataloğu

| Dosya | Mod | Amaç |
| --- | --- | --- |
| `00__open_first_safety_check.sql` | Salt okunur | DEV veri tabanını ve üretim benzeri olmayan sunucu adlarını doğrular. |
| `01__run_all_dev_migrations_sqlcmd.sql` | Salt okunur devir | DEV bağlamını doğrular ve gerçek tümünde bir SSMS migration script'inin nasıl oluşturulacağını/açılacağını açıklar. |
| `02__operations_dashboard.sql` | Salt okunur | Tenant farkında müşteri, kuruluş, risk, poliçe, hasar, belge, görev, teminat ve arama dashboard'u. |
| `03__create_renewal_tasks.sql` | Önce kuru çalıştırma | `tasking.SP_CreateRenewalTasks` çalıştırır; onaylanana kadar kuru çalıştırma olarak kalmalıdır. |
| `04__admin_security_audit_queries.sql` | Salt okunur | RBAC, denetim, trigger ve bütünlük kontrolleri. |
| `05__operator_dashboard_home.sql` | Salt okunur | Kısayollar, sağlık, bağlam ve sonraki aksiyonlarla SSMS ana dashboard. |
| `06__query_library_shortcuts.sql` | Salt okunur | Operatörler için arama ve inceleme kütüphanesi. |
| `07__data_entry_bridge_templates.sql` | Önce önizleme | Kişi, araç risk nesnesi, poliçe, bağlantılar, hasarlar, görevler, görev yorumları ve görev hatırlatıcıları için önizleme ve çıktı ID'leriyle prosedür tabanlı oluşturma aksiyonları. |
| `08__data_editing_guardrails.sql` | Varsayılan rollback | Öncesi/sonrası ızgaralar ve açık commit anahtarıyla kılavuzlu güncellemeler. |
| `09__graph_report_pack.sql` | Salt okunur | Grafik hazır ızgaralar, metin çubukları ve dışa aktarma kataloğu. |
| `10__daily_operator_checklist.sql` | Salt okunur | BAŞARILI/GÖZDEN GEÇİR/AKSIYON sinyalleriyle sabah/gün sonu kontrol listesi. |
| `11__schema_working_logic_map.sql` | Salt okunur | Domain grupları, alt başlıklar, kontrol noktaları ve planlama board kartları. |
| `12__table_catalog_and_relationships.sql` | Salt okunur | Tam SQL Server tablo kataloğu, sütun profili, kök tablolar ve FK haritası. |
| `13__visual_workflow_board.sql` | Salt okunur | Görsel board fikri için SSMS güvenli düğüm, kenar, alt başlık, şablon rota ve hazırlık ızgaraları. |
| `14__admin_role_permission_matrix.sql` | Salt okunur | Kullanıcı dostu rol, izin, tenant kullanıcı ataması, en az ayrıcalık ve admin devir ızgaraları. |
| `15__monitoring_and_job_readiness.sql` | Salt okunur | DEV veri tabanı sağlığı, biriktirme sinyalleri, yedek görünürlüğü, SQL Agent gözlemlenen işleri ve DBA devir ızgaraları. |
| `16__delivery_gap_register.sql` | Salt okunur | Commit inceleme kapanması, açık teslimat boşlukları, sahip engelleyicileri ve sonraki SSMS aksiyonları. |
| `17__remaining_work_cockpit.sql` | Salt okunur | Sahip kanıtı deviri, 019+ karar alımı, kenar bridge sıralaması, SQL Agent terfisi ve sürüm kapanış kapıları. |

## Destekleyici Varlıklar

| Yol | Amaç |
| --- | --- |
| `md/ssms/tutorials/` | Her ana iş akışı için adım adım SSMS kullanıcı kılavuzları. |
| `md/ssms/templates.md` | Kopyalamaya hazır sorgu, arama, güncelleme ve rapor kalıpları. |
| `database/ssms/demo/` | SSMS stili operatör çalışma tezgahının yerel tarayıcı önizlemesi. |
| `md/ssms/dashboard-plan.md` | Kurumsal dashboard mimarisi ve gelecekteki yol haritası. |
| `database/ssms/11__schema_working_logic_map.sql` | İş domain'lerinin nasıl birlikte çalıştığına ilişkin SSMS sonuç kümesi haritası. |
| `database/ssms/12__table_catalog_and_relationships.sql` | Planlama için meta veri odaklı tablo ve ilişki kataloğu. |
| `database/ssms/13__visual_workflow_board.sql` | Görsel planlama demosunu yansıtan düğüm/kenar ve şablon rota ızgaraları. |
| `database/ssms/14__admin_role_permission_matrix.sql` | SSMS operatörleri için admin RBAC matrisi ve erişim inceleme kontrol listesi. |
| `database/ssms/15__monitoring_and_job_readiness.sql` | DBA/operasyon deviri için izleme ve SQL Agent hazırlık ızgaraları. |
| `database/ssms/16__delivery_gap_register.sql` | Bitmemiş commit/PR teslimat öğeleri ve sonraki SSMS aksiyonları için salt okunur kayıt. |
| `database/ssms/17__remaining_work_cockpit.sql` | Kalan engelleyicileri sahip kanıtına, 019+ kararlarına, bridge sıralamasına ve DBA devir aksiyonlarına dönüştürmek için salt okunur kokpit. |
| `database/ssms/demo/workbench-manifest.json` | Gerçek SSMS/veri tabanı kaynak dosyaları ile yerel çalışma tezgahı önizlemesi arasında oluşturulan köprü. |
| `database/tools/update-ssms-workbench-manifest.ps1` | Migration'lardan, doğrulamalardan, SSMS script'lerinden, kısayol satırlarından, schema/tablo yapısından ve backend API rotalarından önizleme manifestosunu yeniden oluşturur. |

## Üretim Runbook'ları

SSMS çalışma tezgahı, `md/database/` altındaki üretim planlama belgeleriyle
desteklenmektedir:

- `ssms-deployment-runbook.md`
- `azure-windows-server-deployment.md`
- `sql-server-installation-checklist.md`
- `backup-restore-strategy.md`
- `security-hardening.md`
- `environment-matrix.md`
- `production-readiness-checklist.md`

## Güvenlik Modları

- `READ_ONLY`: veri değişikliği yok.
- `BACKUP_REQUIRED`: yalnızca yedek yolu yapılandırıldıktan sonra.
- `DRY_RUN_FIRST`: ekle/güncelle öncesinde sonucu önizle.
- `REVIEW_BEFORE_COMMIT`: aksiyondan önce önizleme ızgaralarını incele.
- `ROLLBACK_DEFAULT`: bir commit değişkeni açıkça etkinleştirilmedikçe geri alınır.

## Gerekli SSMS Davranışı

1. Yalnızca DEV SQL Server örneğine bağlanın.
2. Üretim veya canlı sunucular kullanmayın.
3. Her script'in üstünde `YAFES_SQL_DATABASE` ayarlayın.
4. Veri tabanı değerinin `DEV` içerdiğinden emin olun.
5. `:setvar` veya `:r` içeren herhangi bir script çalıştırmadan önce
   `Query > SQLCMD Mode` etkinleştirin.
6. Açılış güvenlik kontrolünü çalıştırın.
7. ID'leri bridge şablonlarına kopyalamak için sorgu kütüphanesi sonuçlarını kullanın.
8. Veri düzenleme script'lerini incelenene kadar rollback/varsayılan önizleme
   modunda tutun.

## Önizleme Sınırı

Yerel çalışma tezgahı önizlemesi kalıcı değildir. Gerçek çalışma, DEV veri tabanına
karşı SQLCMD Mode etkinleştirilmiş SSMS'de yapılmalıdır. Migration yürütmesi,
`database/tools/run-dev-migrations.ps1 -GenerateSsmsScriptOnly` tarafından
oluşturulan `database/execution-logs/<run-id>/ssms-dev-migrations.sql` dosyasını
kullanır; oluşturulan yürütme günlüğü dosyaları commit edilmez.

Önizleme başlangıçta `database/ssms/demo/workbench-manifest.json` dosyasını okur.
Migration'ları, doğrulama script'lerini, SSMS script'lerini, kısayol satırlarını,
schema/tablo yapısını veya backend okuma uç noktalarını değiştirdikten sonra görünür
çalışma tezgahının SSMS altyapısıyla uyumlu kalması için
`database/tools/update-ssms-workbench-manifest.ps1` çalıştırın.

## Bilgi İpucu Standardı

Her operatör script'i şunları içermelidir:

- bir `INFO TIP` başlığı
- üstte SQLCMD değişkenleri
- tenant kapsamlı script'ler için tenant bağlam kontrolleri
- net sonuç kümesi adları
- faydalı olduğunda `info_tip` sütunları
- herhangi bir mutasyon için rollback/kuru çalıştırma varsayılanları

Çalışma arayüzü, bir web uygulaması değil, SSMS Query Editor, Results Grid ve
Messages'dır.
