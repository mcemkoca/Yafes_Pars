# Hızlı Başlangıç

## Hedef

SSMS çalışmasını minimum riskle ve bilinen DEV bağlamında başlatın.

## Adımlar

1. SQL Server Management Studio'yu açın.
2. DEV SQL Server örneğine bağlanın.
3. `database/ssms/00__open_first_safety_check.sql` dosyasını açın.
4. `Query > SQLCMD Mode` etkinleştirin.
5. `YAFES_SQL_DATABASE`'i DEV veri tabanı adına ayarlayın.
6. Script'i çalıştırın.
7. Results Grid'in beklenen sunucu, makine ve veri tabanını gösterdiğini doğrulayın.
8. `database/ssms/05__operator_dashboard_home.sql` dosyasını açın.

## Bilgi İpuçları

- Veri tabanı adı `DEV` içermiyorsa durun.
- Sunucu veya makine adı üretim gibi görünüyorsa durun.
- Dashboard'u ilk SSMS sekmesi olarak açık tutun.
- ID'leri bridge şablonlarına kopyalamak için sorgu kütüphanesi sonuçlarını kullanın.

## Günlük Başlangıç

Bu script'leri sırayla çalıştırın:

1. `05__operator_dashboard_home.sql`
2. `10__daily_operator_checklist.sql`
3. `02__operations_dashboard.sql`

Modeli öğrenirken veya tablo/şablon değişikliklerini planlarken, veri girişinden
önce şunları çalıştırın:

1. `11__schema_working_logic_map.sql`
2. `13__visual_workflow_board.sql`
3. `12__table_catalog_and_relationships.sql`

Veri girişinden önce tüm `AKSIYON` satırlarını çözüme kavuşturun.
