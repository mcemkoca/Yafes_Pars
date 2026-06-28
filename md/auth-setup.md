# Kimlik Doğrulama (Auth) Kurulumu

Yafes Pars sağlayıcı-bağımsız JWT Bearer kimlik doğrulaması kullanır. İki mod vardır:

## 1. Development / Demo modu (yerel test, simülasyon)

`appsettings.Development.json` içinde `Authentication:DevSigningKey` ayarlıysa, API
yerel olarak imzalanmış HS256 token'lar kabul eder. Harici bir IdP gerekmez.

Token alma:

```http
POST /api/auth/dev-token
Content-Type: application/json

{ "role": "operator", "userName": "Jan Operator" }
```

Yanıt:

```json
{ "accessToken": "eyJ...", "tokenType": "Bearer", "expiresIn": 28800,
  "tenantId": "10000000-0000-0000-0000-000000000001", "role": "operator" }
```

Sonra korumalı uçları çağırırken: `Authorization: Bearer eyJ...`

Roller: `operator` (günlük), `admin` (tenant yöneticisi), `auditor` (salt-okuma/compliance).

> `dev-token` ucu yalnızca `DevSigningKey` ayarlıyken çalışır; production config'inde
> bu anahtar **yoktur**, dolayısıyla uç 404 döner.

## 2. Production modu (harici OIDC IdP)

`DevSigningKey` olmadan, API standart OIDC doğrulaması yapar:

```json
"Authentication": {
  "Authority": "https://login.microsoftonline.com/<tenant>/v2.0",
  "Audience": "api://yafespars"
}
```

Desteklenen sağlayıcılar (config-only geçiş): **Azure AD B2C** (önerilen, Azure
dağıtımıyla uyumlu), Auth0, Keycloak veya herhangi bir OIDC uyumlu IdP.

### IdP tarafında gerekenler
- `tenant_id` claim'i — kullanıcının ait olduğu tenant GUID'i (zorunlu).
- `role` claim'i — operator / admin / auditor.
- Audience, API ile eşleşmeli.

Claim eşleme: API claim tiplerini ham bırakır (`MapInboundClaims = false`), bu yüzden
IdP'nin `tenant_id` ve `role` claim'lerini tam bu adlarla yayması gerekir (Azure AD
B2C'de custom claim / claims mapping policy ile).

## Yetkilendirme politikaları
- `TenantUser` — kimlik doğrulanmış + geçerli `tenant_id` (tüm write uçları).
- `Admin` — ek olarak `role=admin`.
- `Auditor` — `role=auditor` veya `admin`.
