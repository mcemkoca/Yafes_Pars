# Teslimat Boşluk Kaydı

Commit, PR veya müşteri incelemesinin ardından şu soru gündeme geldiğinde bu
ekranı kullanın: ne kapandı, ne geçersiz kaldı ve hangileri hâlâ sahip veya
ortam kanıtı gerektiriyor?

## Açma

```text
database/ssms/16__delivery_gap_register.sql
```

`Query > SQLCMD Mode` etkinleştirin, veri tabanı adının `DEV` içerdiğini doğrulayın,
ardından script'i çalıştırın.

## Izgaraları Okuma

1. `01 - Teslimat inceleme bağlamı`, tenant, veri tabanı, tablo sayısı ve
   migration sayısını doğrular.
2. `02 - Mevcut uygulama sinyalleri`, gerçek veri tabanı hazırlığını gösterir:
   108 tablo modeli, migration deftesi, prosedür bridge kapsamı ve planlanan
   019+ alanları.
3. `03 - Prosedür destekli bridge hazırlığı`, günlük oluşturma/bağlantı/kapanış
   iş akışlarının prosedür destekli olduğunu doğrular.
4. `04 - Teslimat boşluk kaydı`, açık iş listesidir.
5. `05 - Listelenen commit inceleme kapanması`, incelenen commit'leri mevcut ürün
   durumuna eşler.
6. `06 - Önerilen sonraki SSMS aksiyonları`, operatöre hangi SSMS script'ini veya
   kanıt şablonunu açacağını söyler.

## Operatör Kuralı

Bu ekrandan finans, içe/dışa aktarma, ürün veya varlık notu tabloları oluşturmayın.
Bunlar, sahip onaylı ileri migration `019+` gerektirir.
