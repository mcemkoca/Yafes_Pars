# Insurance Management System - Server Management Dashboard

## Proje Özeti
Belçika merkezli kapsamlı sigorta yönetim sistemi (Verzekering) için server management dashboard. SQL şemasından tüm domainleri içeren modern, interaktif bir React web uygulaması.

## Domain Analizi (Şema)
1. **Person Domain** - Kişiler (Natural/Legal), adres, telefon, email, sosyal medya, banka, ehliyet
2. **PersonRelation Domain** - Kişiler arası ilişkiler (spouse, child, employee vb.)
3. **Institution Domain** - Kurumlar (sigorta şirketleri, bankalar, KBO/FSMA ID'leri)
4. **Object Domain** - Nesneler (araçlar, emlak, krediler, kişi grupları, eşyalar, aktiviteler)
5. **Contract Domain** - Sözleşmeler (poliçeler, versiyonlar, taraflar, objeler, overnames)
6. **Claim Domain** - Hasar/Şikayet yönetimi (partiler, objeler, circumstances)

## Sayfalar/Dashboard'lar
1. **Ana Dashboard** - KPI kartları, son aktiviteler, istatistik grafikleri
2. **Kişiler Yönetimi** - CRUD tablo, detay modal, adres/telefon/email
3. **Kurumlar** - Sigorta şirketleri, bankalar yönetimi
4. **Sözleşmeler** - Poliçe listesi, versiyonlar, taraflar
5. **Nesneler** - Araçlar, emlak, krediler vb. yönetimi
6. **Hasarlar (Claims)** - Hasar dosyaları, ödemeler, durumlar
7. **Lookup Yönetimi** - Dil, ünvan, telefon tipi, statüler vb.

## Teknoloji Stack
- React + TypeScript + Tailwind CSS + shadcn/ui
- vibecoding-webapp-swarm skill kullanımı
- Charts: recharts
- State: React Context + useReducer
- Data: Mock data (seeds.sql'den)

## Execution Stages
### Stage 1 - Planning & Design
- Skill dosyalarını oku
- Design PRD oluştur

### Stage 2 - Web Application Development
- vibecoding-webapp-swarm ile uygulama geliştir

### Stage 3 - Deploy
- Deploy website
