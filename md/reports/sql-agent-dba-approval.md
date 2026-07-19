# SQL Agent İş Kurulumu — DBA Onay Paketi

**Script:** `database/ssms/18__sql_agent_job_setup.sql`  
**Durum:** DBA İMZASI BEKLENİYOR  
**Sorumlu:** Deuterium12{MCK}

---

## Özet

Günlük / haftalık otomatik işlemler için üç SQL Server Agent işi.
Script idempotent — zaten var olan işi atlar. `YAFES_SQL_DATABASE` değişkeni
DEV, TEST veya ACC içermiyorsa RAISERROR level 16 ile işlemi durdurur.

---

## İstenen İşler

### İş 1 — YafesPars_DailyMarkOverdueInvoices

| Alan | Değer |
|---|---|
| Zamanlama | Her gün 06:00 (sunucu yerel saati) |
| Çağrılan SP | `finance.SP_MarkOverdueInvoices @dry_run = 0` |
| Veritabanı | `$(YAFES_SQL_DATABASE)` (SQLCMD değişkeni) |
| Alt sistem | TSQL |
| Başarı durumu | Başarıyla çık |
| Hata durumu | Hatayla çık |
| Tenant kapsamı | Veritabanındaki tüm tenant'lar |
| Yan etkiler | Vadesi geçmiş PENDING faturaları OVERDUE yapar |
| Geri alınabilir mi? | Hayır — durum değişikliği denetim izine kaydedilir |

### İş 2 — YafesPars_DailyRenewalTasks

| Alan | Değer |
|---|---|
| Zamanlama | Her gün 07:00 (sunucu yerel saati) |
| Çağrılan SP | `tasking.SP_CreateRenewalTasks @tenant_id = <çözümlendi>, @days_ahead = 60, @dry_run = 0` |
| Veritabanı | `$(YAFES_SQL_DATABASE)` (SQLCMD değişkeni) |
| Alt sistem | TSQL |
| Başarı durumu | Başarıyla çık |
| Hata durumu | Hatayla çık |
| Tenant kapsamı | İş oluşturma anında `$(TENANT_CODE)` ile çözümlenen tek tenant |
| Yan etkiler | 60 gün içinde sona erecek sözleşmeler için yenileme görevi oluşturur (sözleşme başına idempotent) |
| Geri alınabilir mi? | Görevler manuel olarak kapatılabilir / iptal edilebilir |

### İş 3 — YafesPars_WeeklyFsmaPortfolioCheck

| Alan | Değer |
|---|---|
| Zamanlama | Her Pazartesi 08:00 (sunucu yerel saati) |
| Çağrılan SP | Satır içi SELECT (aktif poliçeler, süresi dolmuş poliçeler, bekleyen komisyonlar) |
| Veritabanı | `$(YAFES_SQL_DATABASE)` (SQLCMD değişkeni) |
| Alt sistem | TSQL |
| Başarı durumu | Başarıyla çık |
| Hata durumu | Hatayla çık |
| Tenant kapsamı | Veritabanındaki tüm tenant'lar |
| Yan etkiler | SALT OKUNUR — sonuçlar yalnızca SQL Agent iş geçmişinde görünür |
| Geri alınabilir mi? | Geçerli değil — salt okunur |

---

## Güvenlik İncelemesi

| Kontrol | Sonuç |
|---|---|
| DEV/TEST/ACC koruması | ✅ DB adı DEV, TEST veya ACC içermiyorsa RAISERROR level 16 + RETURN |
| Sabit kodlanmış DB adı | ✅ Yok — İş 2, SQLCMD değişkeniyle `sp_executesql` kullanır |
| Sahip girişi | `:setvar JOB_OWNER "sa"` ile yapılandırılabilir — PROD için özel servis hesabıyla değiştirilmeli |
| İdempotent | ✅ İş başına IF NOT EXISTS kontrolü |
| Gereken izinler | msdb üzerinde `sysadmin` veya `SQLAgentOperatorRole` |
| Üretim verisi okuma | İş 3 poliçe/komisyon sayılarını okur — KKB/PII çıkarımı yapılmaz |
| Üretim verisi yazma | İş 1 fatura durumunu günceller; İş 2 görev oluşturur |

---

## Çalıştırma Öncesi Kontrol Listesi

- [ ] Hedef örnekte SQLServerAgent servisi çalışıyor
- [ ] `YAFES_SQL_DATABASE` doğru DB adına ayarlı (DEV veya TEST içermeli)
- [ ] `TENANT_CODE` İş 2 için doğru tenant koduna ayarlı
- [ ] `JOB_OWNER` değeri `sa`'dan onaylı servis hesabına değiştirildi
- [ ] `database/ssms/18__sql_agent_job_setup.sql` incelendi — mevcut SHA: ______
- [ ] Önce DEV'de çalıştırılarak doğrulandı
- [ ] DEV işleri doğrulandıktan sonra TEST'e alındı

---

## DBA İmza

| Alan | Değer |
|---|---|
| DBA adı | |
| İnceleme tarihi (UTC) | |
| Ortam | |
| Veritabanı | |
| Onaylanan işler | YafesPars_DailyMarkOverdueInvoices / YafesPars_DailyRenewalTasks / YafesPars_WeeklyFsmaPortfolioCheck |
| JOB_OWNER girişi onaylandı | |
| Notlar | |
| DBA imzası | |
| Onaylayan | Deuterium12 <mcemkoca0@gmail.com> |
| Onay tarihi | |
