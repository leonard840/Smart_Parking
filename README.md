
## ⚙️ Si ta Ekzekutoni Aplikacionin

### Kërkesat Paraprake
Sigurohuni që keni të instaluar:
- ✅ [Flutter SDK](https://flutter.dev/docs/get-started/install) (versioni 3.x ose më i ri)
- ✅ [Git](https://git-scm.com/downloads)
- ✅ [Visual Studio Code](https://code.visualstudio.com/) me extensionet Flutter dhe Dart
- ✅ [Google Chrome](https://www.google.com/chrome/) (për ekzekutim si Web App)
- ✅ [Node.js](https://nodejs.org/) (për Firebase CLI)

### Hapi 1 — Klono Projektin
```bash
git clone https://github.com/leonard840/Smart_Parking.git
cd Smart_Parking
```

### Hapi 2 — Instalo Paketat
```bash
flutter pub get
```

### Hapi 3 — Ekzekuto Aplikacionin në Chrome
```bash
flutter run -d chrome
```

Pas disa sekondash do të hapet automatikisht **Google Chrome** me aplikacionin!

---

## 🔑 Kredencialet për Testim

### Llogaria e Administratorit
```
Email:      admin@smartparking.com
Fjalëkalim: admin123456
```
> Accesi i adminit të jep qasje në **Admin Panel** me statistika live, menaxhim parkingesh dhe lista të rezervimeve.

### Llogaria e Përdoruesit (Krijoni të re)
- Shkoni te **"Nuk ke llogari? Regjistrohu"**
- Plotësoni: Emri, Email, Telefoni, Fjalëkalimi (min. 6 karaktere)

---

## 📂 Struktura e Projektit

```
smart_parking/
├── lib/
│   ├── main.dart                  # Hyrja kryesore + LoginPage
│   ├── splash_screen.dart         # Ekrani fillestar
│   ├── home_page.dart             # Faqja kryesore me lista parkingesh
│   ├── map_page.dart              # Harta interaktive OpenStreetMap
│   ├── parking_detail_page.dart   # Detajet e parkingut
│   ├── reservation_page.dart      # Faqja e rezervimit
│   ├── payment_page.dart          # Pagesa + QR Code
│   ├── history_page.dart          # Historiku i rezervimeve
│   ├── profile_page.dart          # Profili i përdoruesit
│   ├── register_page.dart         # Regjistrimi i llogarisë
│   ├── admin_page.dart            # Paneli i administratorit
│   └── firebase_options.dart      # Konfigurimi Firebase
├── pubspec.yaml                   # Paketat dhe varësitë
└── README.md                      # Ky skedar
```

---

## 🗺️ Fluksi i Aplikacionit

```
Hap Aplikacionin
      │
      ▼
Splash Screen (2 sek)
      │
      ├──► Admin@smartparking.com ──► Admin Panel
      │                               (Dashboard, Parkinget, Rezervimet, Përdoruesit)
      │
      └──► Përdorues Normal ──► Home Page
                                    │
                          ┌─────────┴─────────┐
                          │                   │
                        Lista              Harta
                       Parkingesh        Interaktive
                          │
                    Parking Detail
                          │
                    Reservation Page
                    (Zgjidhni orët)
                          │
                    Payment Page
                    (Kartë / Cash)
                          │
                    QR Code + Navigim GPS
```

---

## 👤 Sistemi i Roleve

### Përdorues i Zakonshëm
- Shikon listën dhe hartën e parkingeve
- Rezervon dhe paguan vendet
- Merr QR Code dhe navignon drejt parkingut
- Shikon historikun e rezervimeve
- Menaxhon profilin personal

### Administrator (`admin@smartparking.com`)
- Shikon statistikat live (rezervime, të ardhura, parking, përdorues)
- Shton dhe fshin parkinget (reflektohet menjëherë për të gjithë)
- Shikon të gjitha rezervimet me metodën e pagesës
- Shikon listën e të gjithë përdoruesve

---

## 🥇 Sistemi Members

| Niveli | Rezervime | Zbritja | Badge |
|--------|-----------|---------|-------|
| Standard Member | 0 – 2 | 0% | ⭐ |
| Silver Member | 3 – 9 | -10% | 🥈 |
| Gold Member | 10+ | -20% | 🥇 |

---

## 🔥 Firebase — Struktura e Databazës

```
Firestore Database
├── users/
│   └── {userId}
│       ├── name: string
│       ├── email: string
│       ├── phone: string
│       └── createdAt: timestamp
│
├── parkings/
│   └── {parkingId}
│       ├── name: string
│       ├── address: string
│       ├── spots: number
│       ├── price: number
│       ├── distance: string
│       ├── lat: number
│       ├── lng: number
│       └── imageUrl: string
│
└── reservations/
    └── {reservationId}
        ├── userId: string
        ├── userEmail: string
        ├── parkingName: string
        ├── hours: number
        ├── totalPrice: number
        ├── discount: number
        ├── paymentMethod: string (Kartë / Cash)
        ├── status: string
        └── createdAt: timestamp
```


---

*Punim Diplome — Smart Parking | UET 2024-2025*
