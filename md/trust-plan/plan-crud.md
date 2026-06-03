# CRUD Simülasyon Planı - Gerçekçi KPI'lar + Çalışan Ekleme

## Problemler
1. KPI sayıları tekrar ediyor (2.856 hem personel hem toplam)
2. Ekleme butonları çalışmıyor (sadece placeholder)
3. Kullanıcı yeni veri ekleyemiyor

## Çözümler
1. Her KPI benzersiz ve tutarlı sayılar
2. Her sayfada çalışan "Nieuw" modal form
3. Form validasyonu (client-side)
4. Toast bildirim sistemi (başarı/hata)
5. Yeni veri state'e eklenip listeye anında yansır

## Gerekli Bileşenler
- Toast/Notification sistemi
- Reusable ModalForm bileşeni
- Sayfa bazlı form alanları
- State management (useState ile yeterli)
