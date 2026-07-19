# Güvenlik ve Denetim

## Amaç

RBAC, rol izinleri, tenant kullanıcı atamaları, en az ayrıcalık kontrolleri,
denetim trigger'ları, denetim günlükleri ve açık bütünlük sorunlarını inceleyin.

## Ana Script

Kullanın:

```text
database/ssms/14__admin_role_permission_matrix.sql
database/ssms/04__admin_security_audit_queries.sql
```

## İncelenecekler

- Beklenen sistem rol kapsamı
- Rol/izin matrisi
- Tenant kullanıcı rol atamaları
- En az ayrıcalık kontrol listesi
- Kullanıcılar ve roller
- Rol izinleri
- Denetim trigger envanteri
- Son denetim olayları
- Teminat kalemi olmayan aktif paketler
- Domain'siz aktif teminatlar
- Tenant dışındaki görev atananlar

## Önerilen Rutin

Bu script'i şu durumlarda çalıştırın:

- migration'lardan sonra
- toplu veri girişinden sonra
- devir öncesinde
- bir kullanıcı/rol sorunu şüphelenildiğinde
- admin veya broker roller atamadan önce

## Bilgi İpuçları

- Güvenlik incelemesi salt okunur olmalıdır.
- İnsan dostu RBAC için önce `14__admin_role_permission_matrix.sql` çalıştırın,
  ardından teknik denetim kanıtı için `04__admin_security_audit_queries.sql` çalıştırın.
- SSMS sorgu sekmelerine kimlik bilgileri yapıştırmayın.
- Depo düzeyindeki güvenlik açığı yönetimi için `SECURITY.md` kullanın.
