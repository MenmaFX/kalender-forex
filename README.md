# 📅 Kalender Forex (FX Impact)

Aplikasi kalender ekonomi dan berita forex berbasis Flutter dengan analisis proyeksi instrumen pasar yang dirancang untuk trader valuta asing (Forex), komoditas (Emas/XAU), dan kripto (Bitcoin/BTC).

---

## ✨ Fitur Utama

- **📊 Kalender Ekonomi Real-time**: Memantau jadwal rilis berita ekonomi global (High, Medium, Low impact) langsung secara berkala dengan status live.
- **🔍 Filter Fleksibel & Terarah**:
  - Filter rentang waktu: Kemarin, Hari Ini, Besok, Minggu Ini, Minggu Depan, hingga Custom Date Range.
  - Filter tingkat dampak (*High, Medium, Low*).
  - Filter mata uang utama (*USD, EUR, GBP, JPY, AUD, CAD, CHF, NZD*).
- **🎨 Dark Mode & Clean Theme**: Tampilan antarmuka bernuansa fintech profesional, bersih, elegan, dan tanpa artefak warna yang mengganggu.
- **🖼️ Custom Wallpaper Cropper (Pemotong & Penyesuaian Foto Latar)**:
  - Dukungan wallpaper latar transparan (*Frosted Glassmorphism*) baik orientasi *Portrait* (9:16) maupun *Landscape* (16:9).
  - Interaksi *pinch-to-zoom* dan *panning* yang halus, mulus, dan terkunci rapi di dalam batas pemotongan.
- **⚡ Proyeksi Fundamental & Sinyal Pasar**: Memberikan edukasi probabilitas arah pergerakan Dolar AS, Emas (XAU/USD), dan Bitcoin (BTC/USD) pasca rilis data.
- **🔔 Notifikasi & Pengingat Cerdas**:
  - Pengingat pra-rilis (5, 15, atau 30 menit sebelum berita keluar).
  - Khusus hanya memicu pengingat untuk berita yang belum rilis / masa mendatang.
  - Filter notifikasi independen per dampak dan per mata uang.
  - Pengaturan suara & getaran yang fleksibel.
- **✨ Animasi Splash Screen Estetik**: Tampilan pembuka yang halus dan elegan dengan branding *"Aplikasi By MenmaFX"*.

---

## 🛠️ Tech Stack & Requirements

- **Framework**: [Flutter](https://flutter.dev/) (v3.19+ / v3.32+ recommended)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Java Development Kit**: JDK 17
- **Build Tool**: Gradle 8.x (Android Gradle Plugin 8.x)
- **Target Platform**: Android (minSdkVersion 21, targetSdkVersion 34) & iOS

---

## 🚀 Panduan Instalasi & Menjalankan Aplikasi

Pastikan Flutter SDK dan Android Studio / VS Code sudah terpasang di perangkat Anda.

### 1. Kloning Repositori
```bash
git clone https://github.com/MenmaFX/kalender-forex.git
cd kalender-forex
```

### 2. Pasang Dependensi
Unduh seluruh package yang diperlukan:
```bash
flutter pub get
```

### 3. Jalankan Aplikasi di Perangkat / Emulator
Pastikan perangkat Android / emulator sudah tersambung:
```bash
flutter run
```

### 4. Build APK Rilis (Opsional)
Untuk mengompilasi file APK siap pasang (release):
```bash
flutter build apk --release
```
File APK yang dihasilkan akan berada di:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📂 Struktur Proyek

```text
lib/
├── main.dart                      # Titik awal aplikasi & inisialisasi provider
├── models/
│   └── economic_event.dart        # Model data rilis ekonomi & kalkulasi sinyal
├── providers/
│   ├── app_settings_provider.dart # Pengaturan tema, wallpaper, dan filter notifikasi
│   └── calendar_provider.dart     # Manajemen event kalender & alert waktu nyata
├── screens/
│   ├── splash_screen.dart         # Layar animasi pembuka
│   ├── calendar_screen.dart       # Layar utama kalender ekonomi & tab navigasi
│   ├── event_detail_screen.dart   # Detail rilis, riwayat grafik, & analisis sinyal
│   ├── crop_screen.dart           # Pemotong interaktif wallpaper background
│   └── settings_screen.dart       # Pengaturan preferensi, bahasa, & notifikasi
├── services/
│   ├── calendar_service.dart      # Pengambilan data event ekonomi
│   ├── notification_service.dart  # Layanan notifikasi lokal Android
│   └── app_strings.dart           # Lokalisasi multibahasa (ID / EN)
└── widgets/
    ├── app_theme.dart             # Tema warna fintech gelap & terang
    ├── custom_background_scaffold.dart # Scaffold pendukung frosted glass background
    ├── event_card_widget.dart     # Kartu baris data ekonomi
    └── filter_dialog.dart         # Dialog modal filter mata uang & dampak
```

---

## 📄 Lisensi & Kredit

Dikembangkan dengan dedikasi untuk komunitas trader.  
**Aplikasi By MenmaFX**
