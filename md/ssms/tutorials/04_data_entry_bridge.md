# Veri Girişi Bridge'i

## Amaç

Doğrudan tablo düzenlemeleri yerine stored procedure'ler aracılığıyla kayıt
oluşturun.

## Ana Script

Kullanın:

```text
database/ssms/07__data_entry_bridge_templates.sql
```

## Desteklenen Aksiyonlar

- `CREATE_NATURAL_PERSON`
- `CREATE_POLICY`
- `CREATE_POLICY_VERSION`
- `ADD_POLICY_PARTY`
- `CREATE_VEHICLE_OBJECT`
- `ADD_POLICY_OBJECT`
- `CREATE_CLAIM`
- `CLOSE_CLAIM`
- `CREATE_TASK`
- `ADD_TASK_COMMENT`
- `ADD_TASK_REMINDER`

## Güvenli Oluşturma Akışı

1. `ACTION_NAME`'i ayarlayın.
2. `EXECUTE_ACTION = 0` tutun.
3. Yalnızca seçilen aksiyon için değişkenleri doldurun.
4. Çalıştırın ve önizleme sonuç kümelerini inceleyin.
5. Eksik veya geçersiz arama değerlerini düzeltin.
6. `EXECUTE_ACTION = 1` ayarlayın.
7. Tekrar çalıştırın.
8. Gerekirse döndürülen ID'yi bir sonraki şablona kopyalayın.

## Bilgi İpuçları

- Prosedür tabanlı oluşturmalar, geçici INSERT'lere göre tenant ve anahtar
  kurallarını daha iyi uygular.
- Bir arama doğrulaması `EKSİK` diyorsa yürütmeyin.
- Script gövdesini düzenleyerek birden fazla oluşturma aksiyonu çalıştırmayın;
  `ACTION_NAME` kullanın.
- Araç poliçeleri için önce aracı oluşturun veya arayın, ardından
  `created_insurable_object_id`'yi `ADD_POLICY_OBJECT`'e kopyalayın.
- Görev takibi için önce görevi oluşturun, ardından `created_task_id`'yi
  `ADD_TASK_COMMENT` veya `ADD_TASK_REMINDER`'a kopyalayın.
