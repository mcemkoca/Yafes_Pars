# CSV → Yafes Pars Şema Eşleştirmesi

Kaynak: Eski Belçika sigorta sistemi (Willemot/Legacy)  
Hedef: YafesPars SQL Server şeması

## Tablo Eşleştirmeleri

### betrokkenen.csv + betrokken_algemeen.csv → `core.Person`

| CSV Kolonu (betrokken_algemeen) | Yafes Kolon | Notlar |
|---|---|---|
| `bet_id` | `external_ref` / seed key | Legacy ID, eşleştirme için |
| `naam` | `last_name` | |
| `voornaam` | `first_name` | |
| `geboorte_datum` | `date_of_birth` | `0000-00-00` → NULL |
| `geslacht` | `gender_code` | `m`→`M`, `v`→`F` |
| `nummer_rijksregister` | `national_id` | Belçika NN |
| `nummer_identiteitskaart` | `id_card_number` | |
| `nat_of_rechtspersoon` | `person_type` | `1`=persoon, `2`=rechtspersoon |
| `taal` | `language_code` | `0`→`NL`, `1`→`FR`, `2`→`EN` |
| `nationaliteit` | `nationality` | |

### betrokken_contacten.csv + betrokken_email.csv + betrokken_telefoon.csv → `core.PersonContact`

| CSV Kolonu | Yafes Kolon | Notlar |
|---|---|---|
| `bet_id` | FK → `core.Person` | |
| `contact_id` | join key naar contacten.csv | |
| email uit `contacten.csv` | `email` | |
| telefoon uit `contacten.csv` | `phone` | |

### addressen.csv + betrokken_addresses.csv → `core.PersonAddress`

| CSV Kolonu | Yafes Kolon | Notlar |
|---|---|---|
| `address_id` | join key | |
| `straat` / `huisnummer` | `street`, `house_number` | |
| `postcode` | `postal_code` | |
| `gemeente` | `city` | |
| `land` | `country_code` | default `BE` |

### contracten.csv → `policy.Contract`

| CSV Kolonu | Yafes Kolon | Notlar |
|---|---|---|
| `contract_id` | `external_ref` | Legacy ID |
| `bet_id` | FK → `core.Person` (verzekeringnemer) | |
| `polisnummer` | `policy_number` | |
| `maatschappij_id` | FK → `core.Institution` | verzekeraar |
| `domein` | `contract_domain_code` | zie mapping hieronder |
| `polistype` | `contract_type_code` | |
| `status` | `contract_status_code` | zie mapping hieronder |
| `lopend` | `is_active` BIT | |
| `periodiciteit` | `payment_frequency_code` | `1`=maand, `2`=kw, `3`=half, `4`=jaar |
| `beheerder` | `broker_user_id` | |
| `added_time` | `created_at_utc` | |

#### Domein mapping (contracten.domein → contract_domain_code)
| Legacy | Yafes |
|---|---|
| `01` | `AUTO` |
| `02` | `BRAND` |
| `03` | `AANSPRAKELIJKHEID` |
| `04` | `LEVEN` |
| `05` | `GEZONDHEID` |
| `06` | `RECHTSBIJSTAND` |
| `07` | `REIZEN` |
| `08` | `LANDBOUW` |
| `09` | `DIVERS` |
| `99` | `DIVERS` |

#### Status mapping (contracten.status → contract_status_code)
| Legacy | Yafes |
|---|---|
| `1` | `ACTIVE` |
| `2` | `SUSPENDED` |
| `3` | `CANCELLED` |
| `4` | `EXPIRED` |
| `5` | `DRAFT` |

### contract_jaarpremie.csv → `finance.Invoices` (jaarlijkse premie)

| CSV Kolonu | Yafes Kolon | Notlar |
|---|---|---|
| `contract_id` | FK → `policy.Contract` | |
| `bruto_premie` | `gross_amount` | |
| `netto_premie` | `net_amount` | |
| `commissie` | `commission_amount` | → `finance.Commissions` |
| `totaal_te_betalen` | `total_amount` | |

### risicos.csv + risico_auto_algemeen.csv + risico_huis_algemeen.csv → `coverage.ContractCoverageItem`

| CSV Kolonu | Yafes Kolon | Notlar |
|---|---|---|
| `risico_id` | `external_ref` | |
| `risico_type` | `coverage_type_code` | zie mapping hieronder |
| `contract_id` via `risicocontract.csv` | FK → `policy.Contract` | join nodig |

#### Risico type mapping
| Legacy risico_type | coverage_type_code |
|---|---|
| `1` | `AUTO_BA` |
| `2` | `AUTO_OMNIUM` |
| `3` | `BRAND_WONING` |
| `4` | `LEVEN_OVERLIJDEN` |
| `5` | `RECHTSBIJSTAND` |
| `6` | `ARBEIDSONGEVALLEN` |

### schadegeval.csv + schadegeval_algemeen.csv → `claim.Claim`

| CSV Kolonu | Yafes Kolon | Notlar |
|---|---|---|
| `schade_id` | `external_ref` | |
| `contract_id` via `schadecontract.csv` | FK → `policy.Contract` | |
| `datum` | `incident_date` | |
| `omstandigheden` | `description` | |
| `aansprakelijkheid` | `liability_flag` | BIT |
| `materiele_schade` | `material_damage_amt` | |
| `lichamelijke_schade` | `bodily_injury_amt` | |

### users.csv → `core.User` / `core.Tenant`

| CSV Kolonu | Yafes Kolon | Notlar |
|---|---|---|
| user ID | `user_id` | |
| naam/login | `username` | |

---

## Import Volgorde (FK afhankelijkheden)

```
1. core.Tenant         (handmatig aanmaken)
2. core.Person         ← betrokkenen + betrokken_algemeen
3. core.PersonContact  ← betrokken_contacten + contacten
4. core.Institution    ← maatschappij
5. policy.Contract     ← contracten
6. coverage.ContractCoverageItem ← risicos + risicocontract
7. claim.Claim         ← schadegeval + schadecontract
8. finance.Invoices    ← contract_jaarpremie
9. finance.Commissions ← contract_jaarpremie.commissie
```

## Veri Kwaliteit Notities

- `0000-00-00` datums → NULL
- Lege strings → NULL
- `bet_id` is de legacy sleutel; bewaar als `external_ref` voor reconciliatie
- Alle records krijgen de DEV-BE-BROKER tenant_id bij import
- `maatschappij_id` uit contracten moet gemapt worden naar `core.Institution`
