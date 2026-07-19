# Veri Düzenleme Güvenceleri

## Amaç

Mevcut kayıtları önizleme ve varsayılan rollback davranışıyla güncelleyin.

## Ana Script

Kullanın:

```text
database/ssms/08__data_editing_guardrails.sql
```

## Desteklenen Aksiyonlar

- `UPDATE_TASK_STATUS`
- `CLOSE_CLAIM`
- `SOFT_DELETE_DOCUMENT`

## Güvenli Düzenleme Akışı

1. Tam ID'yi bulmak için `06__query_library_shortcuts.sql` kullanın.
2. `ACTION_NAME`'i ayarlayın.
3. `COMMIT_CHANGES = 0` ayarlayın.
4. ID ve hedef değerleri doldurun.
5. Çalıştırın ve öncesi/sonrası sonuç kümelerini inceleyin.
6. Beklenen satır sayısının tam olarak bir olduğunu doğrulayın.
7. `COMMIT_CHANGES = 1` ayarlayın.
8. Yalnızca önizleme doğru olduğunda tekrar çalıştırın.

## Bilgi İpuçları

- Birden fazla satır etkileniyorsa script hata verir.
- Önizleme beklenmedik ise `COMMIT_CHANGES = 0` bırakın.
- Önemli düzenleme oturumlarının ardından denetim sorgularını çalıştırın.
