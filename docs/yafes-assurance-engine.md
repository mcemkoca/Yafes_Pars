# Yafes Assurance Engine

Yafes Assurance Engine, Yafes Pars SSMS-first mimarisine eklenen database governance ve change-assurance katmanıdır.

## Amaç

Bu modül SQL Server değişikliklerini sadece çalıştırılabilir script olarak değil; risk, onay, rollback, audit, compliance ve veri koruma boyutlarıyla ele alır.

## V1 kapsamı

| Alan | İçerik |
|---|---|
| SQL script review | Ortam, rollback ve onay ihtiyacına göre kayıt oluşturur |
| Production değişiklik onayı | PROD değişiklikleri pending approval olarak işaretlenir |
| Rollback planı | PROD değişikliklerinde rollback planı takip edilir |
| Audit trail | Review request, finding, approval ve scan kayıtları tutulur |
| Sensitive column detection | Metadata tabanlı email, phone, iban, national id, birth date ve address detection |
| Data masking policy | Column-level masking policy tablosu |
| GDPR/CIS/ISO kontrol matrisi | Seed compliance controls ve scan findings |
| SQL Server config scanner | Audit trigger kontrolü |
| User/role/permission drift | Role atanmamış kullanıcı kontrolü |
| Assurance dashboard | API dashboard endpointleri |

## API endpointleri

```text
GET  /api/assurance/dashboard
GET  /api/assurance/sql-reviews
POST /api/assurance/sql-review
GET  /api/assurance/sql-risk-findings
POST /api/assurance/sensitive-column-scan
POST /api/assurance/compliance-scan
GET  /api/assurance/compliance-findings
POST /api/assurance/permission-drift-scan
GET  /api/assurance/permission-drift
```

## Migration

```text
database/migrations/021__create_assurance_domain.sql
```

## Azure notu

Bu modül Yafes Pars API içinde native endpoint olarak çalışır. Ayrı CloudDM veya Bytebase container'ı gerektirmez. Azure App Service deploy sürecine normal API build/deploy ile dahil olur. SQL tarafında migration 021'in Azure SQL üzerinde çalıştırılması gerekir.

## Program.cs notu

Endpointleri aktif etmek için `Program.cs` içinde `app.MapAuditEndpoints();` sonrasına şu satır eklenmelidir:

```csharp
app.MapAssuranceEndpoints();
```
