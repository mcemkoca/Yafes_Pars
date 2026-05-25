# Tutorial Audit - Bulunan Eksikler ve Tutarsizliklar

## Kritik: Tutorial icerigi Gercek Proje ile Uyusmuyor!

### 1. Sayfa Isimleri - Tamamen Yanlis
| Tutorial'da | Gercekte | Durum |
|-------------|----------|-------|
| Klanten | Personen | YANLIS |
| Polissen | Contracten | YANLIS |
| Makelaars | Instellingen | YANLIS |
| Schades | Schadeclaims | YANLIS |
| Facturen | (Yok) | EKSTRA |
| Producten | Objecten | YANLIS |
| Rapporten | Rapporten | DOGRU |
| Instellingen | Beheer | YANLIS |

### 2. API Endpoint Isimleri - Yanlis
| Tutorial'da | Gercekte |
|-------------|----------|
| /api/v1/klanten | /api/v1/personen |
| /api/v1/polissen | /api/v1/contracten |
| /api/v1/makelaars | /api/v1/instellingen |
| /api/v1/schades | /api/v1/schadeclaims |
| /api/v1/facturen | YOK |

### 3. SQL Script Isimleri - Yanlis
| Tutorial'da | Gercekte |
|-------------|----------|
| 02_create_tables.sql | 02_schema.sql |
| 03_create_constraints.sql | 03_constraints.sql |
| 04_create_indexes.sql | 04_seeds.sql |
| 05_create_views.sql | 05_triggers.sql |
| 06_create_stored_procedures.sql | 06_stored_procedures.sql |
| 07_create_triggers.sql | 07_views.sql |
| 08_test_data.sql | 08_test_data.sql |

### 4. Mimari Diyagram Tablolari - Yanlis
| Tutorial'da | Gercekte |
|-------------|----------|
| Klanten, Polissen, Makelaars, Schades, Facturen | Person, Contract, Institution, Claim, Object |

### 5. Eksik Icerik
- Personen sayfasi detaylari yok (en onemli sayfa!)
- Objecten sayfasi detaylari yok (6 kategori)
- Contracten wizard anlatilmamis
- Schadeclaims acil indikatoru anlatilmamis
- CRUD modal formlari detayli anlatilmamis
- Toast sisteminden bahsedilmis ama DetailDrawer, FilterBar, StatusBadge, KPICard yok
- Recharts grafiklerinden bahsedilmiyor
- 08_test_data.sql dosyasindan hic bahsedilmiyor

### 6. Tutorial'da Olmamasi Gereken Icerik
- Facturen sayfasi (yok)
- api/v1/facturen endpoint (yok)
