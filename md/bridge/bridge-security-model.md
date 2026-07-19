# Bridge Güvenlik Modeli

## İlkeler

1. **Yalnızca DEV koruması** — `DB_NAME()` `DEV` içermiyorsa bridge script hata fırlatır.
   TEST veya PROD'a karşı çalıştırmak ayrı bir onaylı script gerektirir.

2. **PREVIEW_FIRST** — Her aksiyon varsayılan olarak önizleme modunda çalışır (`EXECUTE_ACTION = 0`).
   Operatör önizleme ızgaralarını incelemeli ve yazmayı gerçekleştirmek için
   `EXECUTE_ACTION = 1` olarak açıkça ayarlamalıdır.

3. **Tenant izolasyonu** — Her aksiyon `@TenantId`'yi `TENANT_CODE`'dan çözer ve
   tüm okumalar/yazmalar o tenant kapsamındadır. Bridge üzerinden
   tenant'lar arası işlemler yapısal olarak mümkün değildir.

4. **Operatör kimliği** — `CREATED_BY_USER_EMAIL`, tenant için aktif bir
   `core.AppUser`'a çözümlenir. `created_by_user_id` gerektiren yazmalar bu
   çözümlenmiş değeri kullanır. NULL yalnızca SP'nin açıkça izin verdiği yerlerde
   tolere edilir.

5. **Ham DML yok** — Bridge aksiyonları yalnızca stored procedure'leri çağırır.
   Bridge script'lerinde operasyonel tablolara doğrudan INSERT, UPDATE veya DELETE
   izin verilmez.

6. **Denetim izi** — Tüm yazma SP'leri operatörün user_id'sini ve UTC
   zaman damgasını ilgili denetim sütunlarına veya denetim günlük tablolarına kaydeder.

7. **Yazmadan önce doğrulama ızgaraları** — Her aksiyon, operatörlerin
   yürütmeden önce incelemesi gereken en az bir doğrulama SELECT'i (adım 03) yayar.

## Tehdit Modeli

| Tehdit | Azaltma |
|--------|-----------|
| Yanlış tenant hedeflendi | TENANT_CODE çalışma zamanında çözümlenir; NULL ise THROW |
| Yanlışlıkla PROD üzerinde çalıştırma | DB_NAME() DEV koruması |
| Kör veri girişi | Varsayılan PREVIEW_FIRST; önizleme ızgarası adım 02 |
| Geçersiz arama değerleri | Adım 03 doğrulama ızgarası her alan için OK/MISSING yayar |
| Yinelenen varlık oluşturma | SP'ler benzersiz kısıtlamaları uygular; bridge DUPLICATE durumunu yansıtır |
| Eksik operatör kimliği | CREATED_BY_USER_EMAIL araması adım 01 önizlemesinde gösterilir |
