# ZERO ERROR AUDIT PLAN - AssureManager

## Hedef
Tum kod tabanini (frontend + backend + sql + vm) en ufak hata kalmayacak sekilde incelemek, duzeltmek, ve butunlestirmek.

## Kategoriler

### Stage 1: Paralel Derin Inceleme (6 Ajans)
1. **Frontend Core** - App.tsx, Layout, Navbar, TopBar, Footer, all shared components, main.tsx, index.css, hooks
2. **Frontend Pages A** - Dashboard, Personen, Instellingen + data files
3. **Frontend Pages B** - Objecten, Contracten, Schadeclaims + data files  
4. **Frontend Pages C** - Rapporten, Beheer + data files
5. **Backend API** - server.js, db.js, mockData.js, all routes
6. **SQL + VM** - All sql scripts, all vm scripts, docker files

### Stage 2: Build Test
- TypeScript compile check
- npm run build
- Butun error'lar duzeltilir

### Stage 3: Final Paketleme
- Tum dosyalar ZIP
- README update
- 0 hata garantisi
