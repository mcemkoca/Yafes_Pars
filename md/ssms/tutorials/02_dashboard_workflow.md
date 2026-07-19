# Dashboard İş Akışı

## Amaç

Dashboard, SSMS ana ekranıdır. Veri değiştirmeksizin kısayol ızgaraları, sağlık
sinyalleri ve sonraki aksiyonlar döndürür.

## Ana Script

Kullanın:

```text
database/ssms/05__operator_dashboard_home.sql
```

## Sonuç Kümelerini Okuma

- `Operatör kısayolları`: güvenlik modu ve amacıyla script kataloğu.
- `Mevcut çalışma bağlamı`: sunucu, veri tabanı, tenant ve oturum açma bilgileri.
- `Sağlık sinyalleri`: hızlı operasyonel durum.
- `Önerilen sonraki aksiyonlar`: önerilen sonraki SSMS sekmeleri.

## Kısayol Güvenlik Modları

- `READ_ONLY`: veri değiştirmeden güvenle çalıştırılabilir.
- `BACKUP_REQUIRED`: yalnızca yedek yolu yapılandırıldıktan sonra çalıştırın.
- `DRY_RUN_FIRST`: ekle/güncelle öncesinde önizleme çalıştırın.
- `REVIEW_BEFORE_COMMIT`: yürütmeden önce önizleme ızgaralarını inceleyin.
- `ROLLBACK_DEFAULT`: commit açıkça etkinleştirilmedikçe değişiklikler geri alınır.

## Bilgi İpuçları

- Dashboard'u veri giriş formu olarak değil, kontrol paneli olarak ele alın.
- Yeni SSMS sekmelerinde script açmak için kısayol dosya adlarını kullanın.
- `TENANT_CODE`'u tüm açık sekmelerde tutarlı tutun.
