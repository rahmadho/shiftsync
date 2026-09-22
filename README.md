# ShiftSync — HR & Workforce Management

Aplikasi mobile absensi karyawan (clock-in/out), riwayat kehadiran, statistik,
pengajuan cuti, dan profil. Dibangun dengan **Flutter** dari satu codebase untuk
**Android + iOS** (+ web/desktop).

## ✨ Fitur

- **Login** — validasi Email/Employee ID (`#EMP-YYYY-XX`) & password
- **Home Dashboard** — jam live, kartu shift mendatang, tombol Check In/Out,
  ringkasan bulanan
- **Absensi aktif** — tombol **Hold to Record** (tahan 1.5 detik), status geofence
- **Attendance History** — ringkasan & daftar dikelompokkan per minggu, badge status
- **My Statistics** — rasio kehadiran, total jam, lembur, recent flags
- **Leave Request** — **date range picker** kalender + durasi otomatis + riwayat
- **Profile** — data karyawan, pengaturan akun, logout

## 🧱 Teknologi

| Aspek | Pilihan |
|---|---|
| Framework | Flutter (stable 3.32) |
| State management | Riverpod |
| Routing | go_router |
| Kalender | syncfusion_flutter_datepicker |
| Format tanggal | intl |
| Font | Arimo (metrik kompatibel dengan Arial/Liberation Sans) |

Data saat ini memakai **mock** (`lib/data/mock/`). Arsitektur model + kontrak API
sudah disiapkan agar penggantian ke backend nyata tidak mengubah UI.

## 🚀 Menjalankan

```bash
flutter pub get
flutter run                 # device/emulator yang terdeteksi
flutter run -d chrome       # coba cepat di browser
```

Cek environment: `flutter doctor`

## 🧪 Testing

```bash
flutter analyze             # harapkan: No issues found!
flutter test                # unit test validators, date math, warna
```

## 📂 Struktur

```
lib/
├── core/        theme, constants, utils (validators, date)
├── data/        models, mock
├── features/    splash, auth, home, attendance, history,
│                statistics, request, profile
├── providers/   riverpod
├── router/      go_router
└── widgets/     komponen bersama (status badge, card, button, bottom nav)
```

## 📄 Dokumentasi

Lihat **[PRD_ShiftSync.md](PRD_ShiftSync.md)** — single source of truth: design
system, screen inventory, DB schema, API contracts, business rules, dan log eksekusi.

## 🗺️ Roadmap

- [ ] Integrasi backend nyata (ganti mock → REST)
- [ ] Geolocation & geofence sungguhan
- [ ] Ganti font Arimo → Liberation Sans (tukar `.ttf` + pubspec)
- [ ] Build & rilis APK / IPA
