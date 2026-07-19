# Bridge Departman Kullanım Senaryosu Matrisi

Operasyonel departman ihtiyaçlarını bridge aksiyonlarıyla eşleştirir.

## Hasar Departmanı

| Kullanım Senaryosu | Bridge Aksiyonu | Durum |
|----------|--------------|--------|
| Yeni hasar aç | CREATE_CLAIM | MEVCUT |
| Çözülmüş hasarı kapat | CLOSE_CLAIM | MEVCUT |
| Rezerv tutarını ayarla | UPDATE_CLAIM_RESERVE | MEVCUT |
| Uzlaşma teklifi oluştur | CREATE_SETTLEMENT | MEVCUT |
| Uzlaşmayı onayla | APPROVE_SETTLEMENT | MEVCUT |
| Kapalı hasarı yeniden aç | REOPEN_CLAIM | GELECEK |
| Uzlaşmayı geri çek | WITHDRAW_SETTLEMENT | GELECEK |

## Poliçe / Sigortalama Departmanı

| Kullanım Senaryosu | Bridge Aksiyonu | Durum |
|----------|--------------|--------|
| Yeni gerçek kişi kaydet | CREATE_NATURAL_PERSON | MEVCUT |
| Şirket/kuruluş kaydet | CREATE_LEGAL_PERSON | MEVCUT |
| Poliçe sözleşmesi oluştur | CREATE_POLICY | MEVCUT |
| Poliçe versiyonu ekle | CREATE_POLICY_VERSION | MEVCUT |
| Poliçe sahibini sözleşmeye bağla | ADD_POLICY_PARTY | MEVCUT |
| Araç kaydet | CREATE_VEHICLE_OBJECT | MEVCUT |
| Aracı poliçeye bağla | ADD_POLICY_OBJECT | MEVCUT |
| Aktif sözleşmeyi iptal et | CANCEL_CONTRACT | GELECEK |
| Kişi iletişim bilgilerini güncelle | UPDATE_NATURAL_PERSON | GELECEK |

## Operasyonlar / Tasking

| Kullanım Senaryosu | Bridge Aksiyonu | Durum |
|----------|--------------|--------|
| Takip görevi oluştur | CREATE_TASK | MEVCUT |
| Göreve yorum ekle | ADD_TASK_COMMENT | MEVCUT |
| Göreve hatırlatıcı ekle | ADD_TASK_REMINDER | MEVCUT |

## İçe/Dışa Aktarma (DBA / Raporlama)

| Kullanım Senaryosu | Bridge Aksiyonu | Durum |
|----------|--------------|--------|
| Toplu dışa aktarma çalışması kaydet | REGISTER_EXPORT_JOB | MEVCUT |
| Dışa aktarmayı tamamlandı olarak işaretle | COMPLETE_EXPORT_JOB | MEVCUT |
| Dışa aktarma işine dosya ekle | ADD_EXPORT_JOB_FILE | GELECEK |
