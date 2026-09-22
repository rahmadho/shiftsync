# PRD — ShiftSync (HR & Workforce Management Mobile App)

> **Single Source of Truth** untuk seluruh delegasi sub-agent.
> Versi dokumen: 1.0 · Status: DRAFT — menunggu approval User
> Target platform: Android + iOS (+ Web/Desktop opsional) dari **satu codebase Flutter**.

---

## BAGIAN 1 — Overview

**Nama produk:** ShiftSync — HR & Workforce Management (v1.0.2)
**Deskripsi:** Aplikasi mobile absensi karyawan (clock in/out), riwayat kehadiran,
statistik, pengajuan cuti, dan profil.

**Filosofi v1:** **UI-First**. Semua screen diselesaikan 100% dengan **data mock**.
Integrasi backend/geolocation nyata ditunda ke fase berikutnya.

### Tech Stack
| Aspek | Pilihan | Alasan |
|---|---|---|
| Framework | Flutter (stable, terbaru) | 1 base → Android + iOS |
| State Mgmt | **Riverpod** | Testable, compile-safe, async-native |
| Routing | go_router | Deklaratif, cocok deep-link |
| Font | **Arimo** (bundle lokal). Ganti ke Liberation Sans cukup tukar file `.ttf` + `pubspec.yaml` saat lisensi tersedia | Metrik identik Arial/Liberation Sans |
| Lokalisasi | `intl` (locale `id_ID`) | Format tanggal/jam Indonesia |
| Kalender | `syncfusion_flutter_datepicker` | Date-range picker sesuai desain (page 7) |

---

## BAGIAN 2 — Design System

### 2.1 Warna (hasil sampling PDF desain)
```dart
// app_colors.dart
static const primary      = Color(0xFF2A8CED); // biru utama
static const background   = Color(0xFFF6F6F8);
static const surface      = Color(0xFFFFFFFF);
static const textPrimary  = Color(0xFF111318);
static const textMuted    = Color(0xFF55575B);
static const border       = Color(0xFFE2EBF6);

// Status tokens
static const onTime = primary;        // On-time = BIRU (dikonfirmasi User)
static const lateBg = Color(0xFFFFEDD4); lateFg = Color(0xFFC1410C);  // amber
static const absentBg = Color(0xFFFDF2F2); absentFg = Color(0xFFB81C1C); // merah
```

### 2.2 Status Badge — mapping (FINAL)
| Status | Warna bg | Warna teks |
|---|---|---|
| On-time | biru muda `#EAF3FD` | `#2A8CED` (biru) |
| Late | `#FFEDD4` | `#C1410C` |
| Absent | `#FDF2F2` | `#B81C1C` |
| Approved | hijau muda `#E8F7EE` | `#1B7F45` |
| Pending | `#FFEDD4` | `#C1410C` |
| Rejected | `#FDF2F2` | `#B81C1C` |

### 2.3 Tipografi
- Family: **Arimo** (Regular 400, Medium 500, SemiBold 600, Bold 700). Siap diganti Liberation Sans.
- Skala: Display 32/28 · H1 24 · H2 20 · Body 16 · Body-sm 14 · Caption 12
- Bundle di `assets/fonts/` + deklarasikan di `pubspec.yaml`

### 2.4 Spacing & Radius
- Base unit 4. Padding layar 20. Gap antar-card 16. Radius card 16, tombol 12–16.

---

## BAGIAN 3 — Screen Inventory (8 layar dari desain)

| ID | Screen | Komponen kunci |
|---|---|---|
| S0 | My Statistics | Attendance Ratio 95% (donut/ring), kartu Present/Late/Absent, Total Hours 160h, Overtime 4h, banner apresiasi, Recent Flags + View All |
| S1 | Splash/About | Logo, "ShiftSync", "HR & Workforce Management", versi v1.0.2 © 2024 |
| S2 | Home Dashboard | Salam "Hello, Alex K", jam+tanggal live, kartu Upcoming Shift, tombol **Check In** & **Check Out**, teks geolocation, Monthly Overview (20/1/0), Bottom Nav |
| S3 | Attendance History | Month selector "October 2023", ringkasan 20/2/0, list per-minggu ("WEEK OF OCT 23 - 29"), baris jam masuk/keluar + status badge |
| S4 | Attendance (aktif) | Lokasi "Headquarters", tanggal, jam live besar, **Hold to record** button, geofence status, kartu SHIFT 09:00-18:00 & SCHEDULED 8h 00m, Bottom Nav |
| S5 | My Profile | Avatar, "Sarah Jenkins", ID #EMP-2024-89, Dept Marketing, shift Mon-Fri, Account Settings list (Edit/Password/Notifications/Logout) |
| S6 | Login | "Welcome Back", subtitle, field Email-or-ID, Password, Remember me, Forgot Password?, tombol Log In, footer "Contact HR" |
| S7 | Leave Request | Dropdown Leave Type, Duration (date range + label), **kalender date-range picker** (Oct 2023, S M T W T F S), field Reason, Submit, Recent Requests |

### 3.1 Bottom Navigation (FINAL — Opsi A)
Tab: **Home · Request · History · Profile** (4 tab, Material 3 NavigationBar)
- **Home** → Dashboard (S2) + tombol Check In/Check Out → membuka **Attendance aktif (S4)**
- **Request** → Leave Request (S7) — form pengajuan cuti + date range picker + Recent Requests
- **History** → Attendance History (S3)
- **Profile** → My Profile (S5) + menu **My Statistics (S0)** + Logout

**Catatan:** Screen "Schedule" **TIDAK dibuat** (memang tidak menampilkan jadwal).
Attendance aktif diakses dari Home, bukan dari bottom nav.

---

## BAGIAN 4 — Database Schema (untuk fase backend; mock mengikuti bentuk ini)

```sql
-- users
id TEXT PK, name, email_or_employee_id UNIQUE, password_hash,
employee_code (#EMP-2024-89), department, avatar_url,
shift_start TIME, shift_end TIME, created_at

-- shifts
id PK, user_id FK, title (Morning Shift), start_at, end_at,
location_name (Headquarters, Floor 2), created_at

-- attendance
id PK, user_id FK, shift_id FK NULL,
check_in_at, check_out_at,
check_in_lat, check_in_lng, check_out_lat, check_out_lng,
status ENUM('on_time','late','absent'),
note, created_at

-- leave_requests
id PK, user_id FK, type ENUM('sick','annual','personal','unexcused'),
start_date, end_date, duration_days, reason,
status ENUM('pending','approved','rejected'), reviewed_by, created_at

-- flags  (Recent Flags di Statistics)
id PK, user_id FK, type, description, occurred_at, delta_label ("15m","1d")
```

---

## BAGIAN 5 — API Contracts (mock sekarang, REST di masa depan)

Base: `/api/v1`

| Method | Endpoint | Body / Query | Response |
|---|---|---|---|
| POST | `/auth/login` | `{email_or_id, password}` | `{token, user}` |
| POST | `/auth/logout` | — | `204` |
| GET | `/me` | — | `User` |
| GET | `/me/attendance/summary?month=2023-10` | — | `{present, late, absent, total_hours, overtime, ratio}` |
| GET | `/me/attendance?from&to` | range | `[Attendance]` (dikelompokkan per minggu di FE) |
| GET | `/me/shift/upcoming` | — | `Shift` |
| POST | `/attendance/check-in` | `{lat,lng,shift_id}` | `Attendance` |
| POST | `/attendance/check-out` | `{lat,lng}` | `Attendance` |
| GET | `/me/flags?limit=3` | — | `[Flag]` |
| GET | `/leave-requests` | — | `[LeaveRequest]` |
| POST | `/leave-requests` | `{type,start_date,end_date,reason}` | `LeaveRequest` |

**Error contract (WAJIB di-handle FE):**
`200` OK · `400` validasi `{message, errors}` · `401` unauthorized → redirect Login ·
`404` not found · `500` server error → snackbar generik.

---

## BAGIAN 6 — UI Flow & State Machine

```
Splash ──(auto 1.5s / cek token)──▶ Login ──(200)──▶ Home
Login ──(401)──▶ tampilkan error field
Bottom Nav:  Home ◀──▶ Request ◀──▶ History ◀──▶ Profile
Home ──(tap Check In/Out)──▶ Attendance aktif (S4) ──hold──▶ sukses ──back──▶ Home
Profile ──▶ My Statistics (S0)
Hold-to-record ──hold 1.5s+──▶ konfirmasi ──▶ sukses (badge update)
```

**State per screen (Riverpod AsyncValue):**
- `data` → render normal · `loading` → skeleton/shimmer · `error` → retry state
- Check-in flow: `idle → holding(progress) → submitting → success | failure`

---

## BAGIAN 7 — Business Rules & Edge Cases

1. **Hold to record**: harus ditahan ≥1.5s; lepas lebih awal → reset ke idle. Cegah double-submit.
2. **Geofence**: jika di luar radius → tombol Check In/Out *disabled* + pesan "You are outside the geolocation range."
3. **Late**: check-in > shift_start → status `late` (contoh: shift 08:00, check-in 09:15 → Late).
4. **Absent**: tidak ada record check-in pada hari kerja → `absent`, tampilkan `-- : --`.
5. **Date range picker (Leave)**: `start_date` ≤ `end_date`; duration auto-hitung inklusif (Oct 5 → Oct 8 = 4 hari); disable tanggal lampau.
6. **Login validasi**: email/ID tidak boleh kosong; format email valid ATAU cocok pola `#EMP-xxxx-xx`; password min 6.
7. **Timezone**: semua timestamp locale `id_ID`; "hari ini" pakai zona perangkat.
8. **Grouping riwayat**: dikelompokkan per minggu (Senin–Minggu), terbaru di atas.
9. **Empty states**: belum ada absensi/cuti → ilustrasi + teks kosong (bukan list kosong polos).
10. **Logout**: hapus token → kembali ke Login (bukan back ke Home).

---

## BAGIAN 8 — Struktur Proyek

```
lib/
├── core/           theme(app_colors, app_theme, app_text), constants, utils
├── data/           models(user, shift, attendance, leave_request, flag), mock/mock_data
├── features/
│   ├── splash/     splash_screen.dart
│   ├── auth/       login_screen.dart, auth_provider.dart
│   ├── home/       home_screen.dart + widgets(shift_card, checkin_buttons, monthly_overview)
│   ├── attendance/ attendance_screen.dart, hold_to_record_button.dart  (dibuka dari Home)
│   ├── history/    history_screen.dart + widgets(stat_summary, week_group, attendance_row)
│   ├── statistics/ statistics_screen.dart   (dibuka dari Profile)
│   ├── request/    leave_request_screen.dart, leave_date_range.dart   (tab "Request")
│   └── profile/    profile_screen.dart + widgets(account_settings_tile)
├── widgets/        status_badge, app_card, app_bottom_nav, primary_button
└── router/         app_router.dart
```

---

## BAGIAN 9 — Urutan Implementasi (UI-First)

1. `flutter create` + pubspec (deps, font, assets) + theme + router + bottom nav shell
2. Splash (S1) → Login (S6)
3. Home Dashboard (S2)
4. Attendance aktif + Hold-to-record (S4)
5. History (S3)
6. Statistics (S0)
7. Leave Request + date-range picker (S7)
8. Profile (S5)
9. Semua screen terhubung ke `mock_data` → **UI 100% selesai**
10. Verifikasi: `flutter analyze` bersih + build Android & iOS

---

## BAGIAN 10 — Delegasi (sesuai AGENTS.md)

> Hanya dijalankan **setelah User approve PRD ini**.

- `CALL @frontend-dev WITH { task_file: "PRD_ShiftSync.md", scope: "SECTION_2,6,8,9" }`
  → seluruh UI Flutter + Riverpod + mock.
- `CALL @backend-dev WITH { task_file: "PRD_ShiftSync.md", scope: "SECTION_4_AND_5" }`
  → schema + mock API (fase backend, ditunda sampai disetujui).
- `CALL @qa-engineer WITH { task_file: "PRD_ShiftSync.md", scope: "SECTION_7" }`
  → unit test + edge case (hold-to-record, late/absent, date range, validasi login).

---

## BAGIAN 11 — Log Eksekusi

- [x] **Setup**: Flutter 3.32.0 (stable) di `/opt/data/tools/flutter`. Project di `~/projects/shiftsync`.
  Arimo (4 weight) di-bundle. Deps: riverpod 2.6.1, go_router 14.6.2, intl 0.19.0, syncfusion 28.2.12.
- [x] **Core layer** dibangun langsung oleh Supervisor (delegasi @frontend-dev pertama keluar dari scope
  PRD → dibatalkan & dikerjakan sendiri demi akurasi: warna `#2A8CED`, 8 screen absensi, bukan scope lain).
- [x] **8 screens** selesai: Splash, Login, Home, Attendance(+HoldToRecord), History, Statistics, Request(+date range picker), Profile.
- [x] **Refinement & Localization**: Dual language system (English / Bahasa Indonesia) added via Riverpod `localeProvider` & `AppStrings`. Language switchers added to Login (top-right chip) and Profile screen (segmented control). Default language is English to match original Figma design. All UI strings, form validators, dates, and badges fully localized.
- [x] **Remote Attendance & Selfie Verification**: Added segmented toggle between In-Office and Outside-Office (Remote/Field) mode in `attendance_screen.dart`. When in Remote mode, geofence radius check is disabled, selfie camera capture (`image_picker`) is enabled, and `HoldToRecordButton` is disabled until a selfie is taken.
- [x] **QA**: `flutter analyze` → **No issues found**. Unit test 21/21 lulus.
- [x] **Build**: `flutter build web --release` sukses.
- [ ] Build APK Android / iOS — butuh Android SDK + Xcode.

## OPEN ITEMS
- [x] Font: pakai **Arimo** dulu; tukar ke Liberation Sans saat file `.ttf` siap.
- [x] On-time = **BIRU** (dikonfirmasi User).
- [x] Navigasi: **Home · Request · History · Profile** (Opsi A). Screen "Schedule" tidak dibuat.
- [x] Statistics: diakses sebagai **menu di Profile**.
- [x] Attendance aktif: diakses dari **Home** (tombol Check In/Out).
- [ ] (Opsional, saat implementasi) Verifikasi visual presisi warna vs screenshot desain.
