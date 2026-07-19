# SSMS ile Veri Tabanı Kurulumu

Migration dosyalarını dosya adı sırasıyla çalıştırmak için SQL Server Management Studio
kullanın. Tüm script'ler Microsoft SQL Server T-SQL'i hedefler ve SSMS toplu iş
ayırıcıları kullanır.

## İlk İşlem

1. Hedef SQL Server örneğini SSMS'de açın.
2. Depodan statik kalite kapısını çalıştırın.
3. Migration dosyalarını aşağıdaki sırayla çalıştırın.
4. Doğrulama dosyalarını aşağıdaki sırayla çalıştırın.
5. İsteğe bağlı demo verisini yalnızca geliştirme veya test ortamlarında çalıştırın.

Ayrı bir operasyonel onay olmadan üretim veri tabanlarına karşı yıkıcı rollback
script'leri çalıştırmayın.

Azure Windows Server, SQL Server kurulumu, yedek/geri yükleme ve üretim sürüm
prosedürleri için şunları kullanın:

- `azure-windows-server-deployment.md`
- `sql-server-installation-checklist.md`
- `ssms-deployment-runbook.md`
- `backup-restore-strategy.md`
- `production-readiness-checklist.md`

## Migration Sırası

- `000__create_database.sql`
- `001__create_schemas.sql`
- `002__create_core_infrastructure.sql`
- `003__create_person_domain.sql`
- `004__create_institution_domain.sql`
- `005__create_object_domain.sql`
- `006__create_contract_domain.sql`
- `007__create_coverage_domain.sql`
- `008__create_claim_domain.sql`
- `009__create_document_domain.sql`
- `010__create_task_domain.sql`
- `011__create_audit_domain.sql`
- `012__add_constraints.sql`
- `013__add_indexes.sql`
- `014__add_triggers.sql`
- `015__add_views.sql`
- `016__add_stored_procedures.sql`
- `017__seed_lookup_data.sql`
- `018__seed_demo_data.sql` isteğe bağlı

## Doğrulama Sırası

- `001__validate_core_infrastructure.sql`
- `002__validate_person_domain.sql`
- `003__validate_institution_domain.sql`
- `004__validate_risk_domain.sql`
- `005__validate_policy_domain.sql`
- `006__validate_coverage_domain.sql`
- `007__validate_claim_domain.sql`
- `008__validate_document_domain.sql`
- `009__validate_task_domain.sql`
- `010__validate_audit_domain.sql`
- `011__validate_constraints_exist.sql`
- `012__validate_indexes.sql`
- `013__validate_triggers.sql`
- `014__validate_views.sql`
- `015__validate_stored_procedures.sql`
- `016__validate_seed_data.sql`
- `017__validate_demo_data.sql` yalnızca isteğe bağlı demo seed'den sonra

## Rollback

Rollback script'leri onay değişkenleriyle korunur ve üretim veri tabanlarına karşı
kullanılmamalıdır. Nesne düzeyinde rollback yerine geliştirme veri tabanlarını migration
sırasından yeniden oluşturmayı tercih edin.

## Yenileme Görevi Prosedürü

`016__add_stored_procedures.sql` uygulandıktan sonra, görev eklemeden önce SSMS'de
yenileme adaylarını önizleyin:

```sql
DECLARE @TenantId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';

EXEC tasking.SP_CreateRenewalTasks
    @tenant_id = @TenantId,
    @days_ahead = 60,
    @assigned_to_user_id = NULL,
    @created_by_user_id = NULL,
    @dry_run = 1;
```

Aday kümesi doğru olduğunda `@dry_run = 0` ile yeniden çalıştırın. Prosedür
tenant farkındadır ve tenant dışındaki atanan veya oluşturucu kullanıcıları reddeder.
