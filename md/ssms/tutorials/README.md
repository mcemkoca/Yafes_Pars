# Yafes Pars SSMS Öğreticileri

Bu klasör, SQL Server Management Studio içinde güvenli çalışmak için operatör
kılavuzudur.

## Öğretici Haritası

1. `01_quick_start.md` - ilk çalıştırma kurulumu ve günlük başlangıç.
2. `02_dashboard_workflow.md` - SSMS dashboard ve kısayolların kullanımı.
3. `03_query_and_search.md` - müşteri, poliçe, hasar, görev ve arama sorgulama.
4. `04_data_entry_bridge.md` - stored procedure'ler aracılığıyla kılavuzlu oluşturma aksiyonları.
5. `05_data_editing_guardrails.md` - varsayılan rollback ile güvenli güncelleme kalıpları.
6. `06_reports_and_graphs.md` - rapor ızgaraları, metin çubukları ve dışa aktarma kılavuzu.
7. `07_security_audit.md` - RBAC, denetim ve veri kalitesi kontrolleri.
8. `08_troubleshooting.md` - yaygın SSMS hataları ve çözümleri.
9. `09_monitoring_and_jobs.md` - izleme ızgaraları ve SQL Agent deviri.
10. `10_delivery_gap_register.md` - commit inceleme kapanması ve bitmemiş teslimat öğeleri.
11. `11_remaining_work_cockpit.md` - sahip kanıtı, 019+ kararları, bridge sıralaması ve DBA deviri.

## Operatör Kuralı

Şüphe duyduğunuzda önce salt okunur script'leri çalıştırın:

1. `00__open_first_safety_check.sql`
2. `05__operator_dashboard_home.sql`
3. `11__schema_working_logic_map.sql`
4. `13__visual_workflow_board.sql`
5. `12__table_catalog_and_relationships.sql`
6. `10__daily_operator_checklist.sql`
7. `14__admin_role_permission_matrix.sql`
8. `15__monitoring_and_job_readiness.sql`
9. `16__delivery_gap_register.sql`
10. `17__remaining_work_cockpit.sql`

Yalnızca bunların ardından veri girişi veya düzenleme script'lerini kullanın.
