# Plan: Gerçek Test + VHDX + Test Data

## 1. GERÇEK SQL SERVER TEST (SQLite ile Simülasyon)
- Python sqlite3 ile T-SQL'i SQLite dialect'ine çevirip gerçek DB oluştur
- Tüm tabloları, FK'leri, constraint'leri, trigger mantığını test et
- 18 Stored Procedure'nin mantığını Python fonksiyonlarıyla test et
- 6 View'in SQL'ini test et
- Veritabanı boyutu, index boyutu hesapla

## 2. VHDX ALTERNATİFİ (QEMU Sanal Disk)
- QEMU/KVM ile raw disk imajı oluştur
- Disk imajına bootloader + SQL Server kurulum dosyaları entegre et
- 50GB dinamik büyüyen disk
- Otomatik kurulum (unattend) scripti

## 3. KAPSAMLI TEST DATA
- 100+ Person (50 natuurlijk + 50 rechtspersoon)
- 50+ Contract (tüm domain'lerden)
- 30+ Schadeclaim (tüm tiplerden)
- 100+ Object (6 kategori)
- 20+ Instelling
- Gerçekçi Belçika verileri (adres, RRN, KBO, plaka)
- Her tablo için 20-100 arası kayıt
