# Sorgulama ve Arama

## Amaç

Oluşturma/düzenleme şablonlarını kullanmadan önce kayıtları güvenle bulun.

## Ana Script

Kullanın:

```text
database/ssms/06__query_library_shortcuts.sql
```

## Yaygın İş Akışı

1. `TENANT_CODE`'u ayarlayın.
2. Belirli bir kişi, kuruluş veya araç arıyorsanız `SEARCH_TEXT`'i ayarlayın.
3. Script'i çalıştırın.
4. Results Grid'den ID'leri kopyalayarak veri girişi veya düzenleme bridge
   script'lerine yapıştırın.

## Arama Bölümleri

- Müşteriler: `person.SP_SearchPerson`
- Kurumlar: `institution.SP_SearchInstitution`
- Araçlar: `risk.SP_SearchVehicle`
- Son poliçeler: `policy.VW_PolicyDashboard`
- Açık hasarlar: `claim.VW_ClaimDashboard`
- Açık görevler: `tasking.VW_OpenTaskDashboard`
- Arama yardımcısı: durum, domain, öncelik ve iş akışı değerleri

## Bilgi İpuçları

- Results Grid'den kopyalayabilecekken GUID'leri elle yazmayın.
- Büyük sonuç kümelerini sınırlamak için `TOP_ROWS` kullanın.
- Önce arayın, sonra düzenleyin.
