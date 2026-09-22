import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { en, id }

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLanguage>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<AppLanguage> {
  LocaleNotifier() : super(AppLanguage.en);

  void setLanguage(AppLanguage lang) => state = lang;
  void toggleLanguage() => state = state == AppLanguage.en ? AppLanguage.id : AppLanguage.en;
}

class AppStrings {
  AppStrings._();

  static const Map<String, Map<AppLanguage, String>> _values = {
    // General / Common
    'appName': {AppLanguage.en: 'ShiftSync', AppLanguage.id: 'ShiftSync'},
    'appTagline': {AppLanguage.en: 'HR & Workforce Management', AppLanguage.id: 'Manajemen SDM & Tenaga Kerja'},
    'appVersion': {AppLanguage.en: 'v1.0.2 © 2024 ShiftSync Inc.', AppLanguage.id: 'v1.0.2 © 2024 ShiftSync Inc.'},
    'viewAll': {AppLanguage.en: 'View All', AppLanguage.id: 'Lihat Semua'},
    'days': {AppLanguage.en: 'Days', AppLanguage.id: 'Hari'},
    'hoursUnit': {AppLanguage.en: 'h', AppLanguage.id: 'j'},
    'hoursWord': {AppLanguage.en: 'hours', AppLanguage.id: 'jam'},

    // Nav
    'navHome': {AppLanguage.en: 'Home', AppLanguage.id: 'Beranda'},
    'navRequest': {AppLanguage.en: 'Request', AppLanguage.id: 'Pengajuan'},
    'navHistory': {AppLanguage.en: 'History', AppLanguage.id: 'Riwayat'},
    'navProfile': {AppLanguage.en: 'Profile', AppLanguage.id: 'Profil'},

    // Status Badges
    'statusOnTime': {AppLanguage.en: 'On-time', AppLanguage.id: 'Tepat Waktu'},
    'statusLate': {AppLanguage.en: 'Late', AppLanguage.id: 'Terlambat'},
    'statusAbsent': {AppLanguage.en: 'Absent', AppLanguage.id: 'Absen'},
    'statusApproved': {AppLanguage.en: 'Approved', AppLanguage.id: 'Disetujui'},
    'statusPending': {AppLanguage.en: 'Pending', AppLanguage.id: 'Menunggu'},
    'statusRejected': {AppLanguage.en: 'Rejected', AppLanguage.id: 'Ditolak'},

    // Login
    'welcomeBack': {AppLanguage.en: 'Welcome Back', AppLanguage.id: 'Selamat Datang Kembali'},
    'signInSubtitle': {AppLanguage.en: 'Please sign in to view your shifts.', AppLanguage.id: 'Silakan masuk untuk melihat shift Anda.'},
    'emailOrId': {AppLanguage.en: 'Email or Employee ID', AppLanguage.id: 'Email atau ID Karyawan'},
    'emailOrIdHint': {AppLanguage.en: 'Enter your email or ID', AppLanguage.id: 'Masukkan email atau ID'},
    'password': {AppLanguage.en: 'Password', AppLanguage.id: 'Kata Sandi'},
    'passwordHint': {AppLanguage.en: 'Enter your password', AppLanguage.id: 'Masukkan kata sandi'},
    'rememberMe': {AppLanguage.en: 'Remember me', AppLanguage.id: 'Ingat saya'},
    'forgotPassword': {AppLanguage.en: 'Forgot Password?', AppLanguage.id: 'Lupa Kata Sandi?'},
    'logIn': {AppLanguage.en: 'Log In', AppLanguage.id: 'Masuk'},
    'contactHr': {AppLanguage.en: "Don't have an account? Contact HR", AppLanguage.id: 'Belum punya akun? Hubungi HR'},

    // Home
    'hello': {AppLanguage.en: 'Hello', AppLanguage.id: 'Halo'},
    'upcomingShift': {AppLanguage.en: 'UPCOMING SHIFT', AppLanguage.id: 'SHIFT MENDATANG'},
    'checkIn': {AppLanguage.en: 'Check In', AppLanguage.id: 'Masuk'},
    'checkOut': {AppLanguage.en: 'Check Out', AppLanguage.id: 'Keluar'},
    'withinGeofenceMsg': {
      AppLanguage.en: 'You are currently within the geolocation range.',
      AppLanguage.id: 'Anda saat ini berada dalam radius absensi.'
    },
    'monthlyOverview': {AppLanguage.en: 'Monthly Overview', AppLanguage.id: 'Ringkasan Bulanan'},
    'present': {AppLanguage.en: 'Present', AppLanguage.id: 'Hadir'},
    'late': {AppLanguage.en: 'Late', AppLanguage.id: 'Terlambat'},
    'absent': {AppLanguage.en: 'Absent', AppLanguage.id: 'Tidak Hadir'},

    // Attendance
    'attendance': {AppLanguage.en: 'Attendance', AppLanguage.id: 'Absensi'},
    'modeOffice': {AppLanguage.en: 'In Office', AppLanguage.id: 'Di Kantor'},
    'modeRemote': {AppLanguage.en: 'Outside Office', AppLanguage.id: 'Luar Kantor'},
    'withinGeofence': {AppLanguage.en: 'Within geofence', AppLanguage.id: 'Dalam radius'},
    'outsideGeofence': {AppLanguage.en: 'Outside geofence', AppLanguage.id: 'Luar radius'},
    'remoteModeActive': {AppLanguage.en: 'Remote mode active', AppLanguage.id: 'Mode luar kantor aktif'},
    'takeSelfie': {AppLanguage.en: 'Take Selfie', AppLanguage.id: 'Ambil Selfie'},
    'retakeSelfie': {AppLanguage.en: 'Retake', AppLanguage.id: 'Foto Ulang'},
    'selfieRequiredMsg': {AppLanguage.en: 'Please take a selfie first to record outside office', AppLanguage.id: 'Harap ambil foto selfie terlebih dahulu untuk absen luar kantor'},
    'notesOptional': {AppLanguage.en: 'Notes (e.g. Client Visit, WFH)', AppLanguage.id: 'Catatan (mis. Kunjungan Klien, WFH)'},
    'holdToRecord': {AppLanguage.en: 'Hold to record', AppLanguage.id: 'Tahan untuk absen'},
    'recorded': {AppLanguage.en: 'Recorded', AppLanguage.id: 'Tercatat'},
    'holdToCheckIn': {AppLanguage.en: 'Hold to Check In', AppLanguage.id: 'Tahan untuk Masuk'},
    'holdToCheckOut': {AppLanguage.en: 'Hold to Check Out', AppLanguage.id: 'Tahan untuk Keluar'},
    'attendanceDoneToday': {AppLanguage.en: "Today's attendance completed", AppLanguage.id: 'Absen hari ini selesai'},
    'labelCheckIn': {AppLanguage.en: 'CHECK IN', AppLanguage.id: 'ABSEN MASUK'},
    'labelCheckOut': {AppLanguage.en: 'CHECK OUT', AppLanguage.id: 'ABSEN KELUAR'},
    'notCheckedInYet': {AppLanguage.en: 'Not checked in', AppLanguage.id: 'Belum absen'},
    'shift': {AppLanguage.en: 'SHIFT', AppLanguage.id: 'SHIFT'},
    'standardShift': {AppLanguage.en: 'Standard Shift', AppLanguage.id: 'Shift Standar'},
    'geoFailMsg': {
      AppLanguage.en: 'Failed: You are outside the geofence radius',
      AppLanguage.id: 'Gagal: Anda di luar radius absensi'
    },
    'geoSuccessMsg': {
      AppLanguage.en: 'Success: Attendance recorded',
      AppLanguage.id: 'Berhasil: Absensi tercatat'
    },
    'remoteSuccessMsg': {
      AppLanguage.en: 'Success: Remote attendance with selfie recorded',
      AppLanguage.id: 'Berhasil: Absensi luar kantor dengan selfie tercatat'
    },
    // Security / anti-fraud
    'securityCheck': {AppLanguage.en: 'Security Check', AppLanguage.id: 'Pemeriksaan Keamanan'},
    'secVerified': {AppLanguage.en: 'Device verified', AppLanguage.id: 'Perangkat terverifikasi'},
    'secMockLocation': {
      AppLanguage.en: 'Fake GPS detected. Turn off mock location to record attendance.',
      AppLanguage.id: 'Fake GPS terdeteksi. Matikan mock location untuk absen.'
    },
    'secRooted': {
      AppLanguage.en: 'This device is rooted. Attendance is blocked for security.',
      AppLanguage.id: 'Perangkat ini ter-root. Absensi diblokir demi keamanan.'
    },
    'secJailbroken': {
      AppLanguage.en: 'This device is jailbroken. Attendance is blocked for security.',
      AppLanguage.id: 'Perangkat ini di-jailbreak. Absensi diblokir demi keamanan.'
    },
    'secEmulator': {
      AppLanguage.en: 'Emulator detected. Attendance is only allowed on real devices.',
      AppLanguage.id: 'Emulator terdeteksi. Absensi hanya diizinkan di perangkat asli.'
    },
    'secNoOfficeWifi': {
      AppLanguage.en: 'You are not connected to the office Wi-Fi network.',
      AppLanguage.id: 'Anda tidak terhubung ke jaringan Wi-Fi kantor.'
    },
    'secWifiOk': {AppLanguage.en: 'Office network found', AppLanguage.id: 'Jaringan kantor terdeteksi'},
    'secGpsOff': {
      AppLanguage.en: 'Location services are off. Please enable GPS.',
      AppLanguage.id: 'Layanan lokasi mati. Aktifkan GPS.'
    },
    'secPermDenied': {
      AppLanguage.en: 'Location permission denied. Grant it in Settings.',
      AppLanguage.id: 'Izin lokasi ditolak. Berikan izin di Pengaturan.'
    },
    'secOpenSettings': {AppLanguage.en: 'Open Settings', AppLanguage.id: 'Buka Pengaturan'},
    'secWaitLocating': {AppLanguage.en: 'Getting your location…', AppLanguage.id: 'Mengambil lokasi Anda…'},
    'secLocatingFailed': {AppLanguage.en: 'Could not get location', AppLanguage.id: 'Gagal mengambil lokasi'},

    // Leave Request
    'leaveRequest': {AppLanguage.en: 'Leave Request', AppLanguage.id: 'Pengajuan Cuti'},
    'leaveType': {AppLanguage.en: 'Leave Type', AppLanguage.id: 'Jenis Cuti'},
    'sickLeave': {AppLanguage.en: 'Sick Leave', AppLanguage.id: 'Cuti Sakit'},
    'annualLeave': {AppLanguage.en: 'Annual Leave', AppLanguage.id: 'Cuti Tahunan'},
    'personalLeave': {AppLanguage.en: 'Personal', AppLanguage.id: 'Cuti Pribadi'},
    'unexcusedLeave': {AppLanguage.en: 'Unexcused', AppLanguage.id: 'Tanpa Keterangan'},
    'duration': {AppLanguage.en: 'Duration', AppLanguage.id: 'Durasi'},
    'selectRange': {AppLanguage.en: 'Select a range', AppLanguage.id: 'Pilih rentang tanggal'},
    'from': {AppLanguage.en: 'From', AppLanguage.id: 'Dari'},
    'to': {AppLanguage.en: 'To', AppLanguage.id: 'Sampai'},
    'attachment': {AppLanguage.en: 'Attachment Document', AppLanguage.id: 'Lampiran Dokumen'},
    'attachmentHint': {AppLanguage.en: 'Attach document/letter (PDF/JPG)', AppLanguage.id: 'Lampirkan dokumen/surat (PDF/JPG)'},
    'chooseFile': {AppLanguage.en: 'Choose', AppLanguage.id: 'Pilih'},
    'changeFile': {AppLanguage.en: 'Change', AppLanguage.id: 'Ganti'},
    'filePickFailed': {AppLanguage.en: 'Failed to select file', AppLanguage.id: 'Gagal memilih file'},
    'reason': {AppLanguage.en: 'Reason', AppLanguage.id: 'Alasan'},
    'reasonHint': {AppLanguage.en: 'Please describe the reason for your leave...', AppLanguage.id: 'Jelaskan alasan pengajuan cuti Anda...'},
    'submitRequest': {AppLanguage.en: 'Submit Request', AppLanguage.id: 'Kirim Pengajuan'},
    'recentRequests': {AppLanguage.en: 'Recent Requests', AppLanguage.id: 'Pengajuan Terbaru'},
    'requestSubmitted': {AppLanguage.en: 'Leave request submitted', AppLanguage.id: 'Pengajuan cuti berhasil dikirim'},
    'selectDateRangePrompt': {AppLanguage.en: 'Please select a date range', AppLanguage.id: 'Silakan pilih rentang tanggal'},

    // History
    'attendanceHistory': {AppLanguage.en: 'Attendance History', AppLanguage.id: 'Riwayat Kehadiran'},
    'noAttendanceData': {AppLanguage.en: 'No attendance records', AppLanguage.id: 'Tidak ada data kehadiran'},
    'noRecordForMonth': {AppLanguage.en: 'No records for', AppLanguage.id: 'Belum ada catatan untuk'},

    // Statistics
    'myStatistics': {AppLanguage.en: 'My Statistics', AppLanguage.id: 'Statistik Saya'},
    'score': {AppLanguage.en: 'Score', AppLanguage.id: 'Skor'},
    'attendanceRatio': {AppLanguage.en: 'ATTENDANCE RATIO', AppLanguage.id: 'RASIO KEHADIRAN'},
    'totalHours': {AppLanguage.en: 'TOTAL HOURS', AppLanguage.id: 'TOTAL JAM'},
    'overtime': {AppLanguage.en: 'OVERTIME', AppLanguage.id: 'LEMBUR'},
    'lateHoursLabel': {AppLanguage.en: 'LATE ARRIVAL', AppLanguage.id: 'TERLAMBAT'},
    'totalLateDesc': {AppLanguage.en: 'Total late hours', AppLanguage.id: 'Total keterlambatan'},
    'earlyLeaveLabel': {AppLanguage.en: 'EARLY DEPARTURE', AppLanguage.id: 'PULANG CEPAT'},
    'totalEarlyDesc': {AppLanguage.en: 'Total early leave', AppLanguage.id: 'Total pulang cepat'},
    'greatJob': {AppLanguage.en: 'Great job!', AppLanguage.id: 'Kerja bagus!'},
    'encouragementMsg': {
      AppLanguage.en: 'Your punctuality has improved by 5% compared to last month. Keep it up!',
      AppLanguage.id: 'Ketepatan waktu Anda meningkat 5% dibanding bulan lalu. Pertahankan!'
    },
    'recentFlags': {AppLanguage.en: 'Recent Flags', AppLanguage.id: 'Peringatan Terbaru'},

    // Profile
    'myProfile': {AppLanguage.en: 'My Profile', AppLanguage.id: 'Profil Saya'},
    'department': {AppLanguage.en: 'Department', AppLanguage.id: 'Departemen'},
    'shiftLabel': {AppLanguage.en: 'Shift', AppLanguage.id: 'Shift'},
    'accountSettings': {AppLanguage.en: 'ACCOUNT SETTINGS', AppLanguage.id: 'PENGATURAN AKUN'},
    'language': {AppLanguage.en: 'Language', AppLanguage.id: 'Bahasa'},
    'editProfile': {AppLanguage.en: 'Edit Profile', AppLanguage.id: 'Ubah Profil'},
    'changePassword': {AppLanguage.en: 'Change Password', AppLanguage.id: 'Ganti Kata Sandi'},
    'notifications': {AppLanguage.en: 'Notifications', AppLanguage.id: 'Notifikasi'},
    'logOut': {AppLanguage.en: 'Log Out', AppLanguage.id: 'Keluar'},

    // Change Password
    'changePasswordDesc': {
      AppLanguage.en: 'Enter your current password and your new password.',
      AppLanguage.id: 'Masukkan kata sandi saat ini lalu kata sandi baru Anda.'
    },
    'currentPassword': {AppLanguage.en: 'Current Password', AppLanguage.id: 'Kata Sandi Saat Ini'},
    'currentPasswordHint': {AppLanguage.en: 'Enter current password', AppLanguage.id: 'Masukkan kata sandi saat ini'},
    'newPassword': {AppLanguage.en: 'New Password', AppLanguage.id: 'Kata Sandi Baru'},
    'newPasswordHint': {AppLanguage.en: 'Minimum 6 characters', AppLanguage.id: 'Minimal 6 karakter'},
    'confirmNewPassword': {AppLanguage.en: 'Confirm New Password', AppLanguage.id: 'Konfirmasi Kata Sandi Baru'},
    'confirmNewPasswordHint': {AppLanguage.en: 'Repeat new password', AppLanguage.id: 'Ulangi kata sandi baru'},
    'savePassword': {AppLanguage.en: 'Save Password', AppLanguage.id: 'Simpan Kata Sandi'},
    'passwordChangedSuccess': {AppLanguage.en: 'Password successfully changed', AppLanguage.id: 'Kata sandi berhasil diubah'},
    'passwordsDoNotMatch': {AppLanguage.en: 'Passwords do not match', AppLanguage.id: 'Konfirmasi kata sandi tidak cocok'},
  };

  static String tr(String key, AppLanguage lang) {
    return _values[key]?[lang] ?? key;
  }
}

extension AppLanguageExtension on WidgetRef {
  String tr(String key) {
    final lang = watch(localeProvider);
    return AppStrings.tr(key, lang);
  }
}
