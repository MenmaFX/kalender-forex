# 📈 Kalender Ekonomi & Sinyal Forex/Kripto (Myfxbook 1:1 Professional Edition)

Aplikasi mobile Flutter berstandar tinggi yang meniru persis estetika **Myfxbook** dengan UI organik, tipografi finansial tabular, efek *Frosted Glassmorphism*, serta dukungan penuh **Custom Background (Portrait 9:16 & Landscape 16:9)** dengan pemotong manual (manual crop).

---

## 💎 Fitur & Peningkatan Versi Terbaru

### 1. Konfigurasi Android SDK Mutakhir
- **`minSdkVersion: 21`** (Android 5.0 Lollipop) – Menjamin kompatibilitas dengan ponsel lama tanpa kendala.
- **`compileSdkVersion` & `targetSdkVersion: 34`** – Mendukung arsitektur Android 14+ secara optimal.
- **Izin Lengkap & Penyimpanan Warisan (`requestLegacyExternalStorage="true"`)**:
  - `READ_EXTERNAL_STORAGE` & `WRITE_EXTERNAL_STORAGE` (Android 12 kebawah).
  - `READ_MEDIA_IMAGES` (Android 13+).
  - `POST_NOTIFICATIONS` & `VIBRATE`.
  - Registrasi activity bawaan crop foto: `com.yalantis.ucrop.UCropActivity`.

### 2. UI/UX Organik & Bebas Kesan Kaku (Human-Crafted Feel)
- **Tipografi Finansial Modern**:
  - Menggunakan font **Google Fonts: Inter** untuk judul dan narasi edukasi.
  - Menggunakan font **Google Fonts: JetBrains Mono** dengan fitur **Tabular Figures** (`FontFeature.tabularFigures()`) untuk seluruh metrik angka (Aktual, Konsensus, Sebelumnya), sehingga tanda desimal dan angka selalu rata vertikal sempurna (*monospaced tabular alignment*).
- **Efek Glassmorphism / Frosted Glass**:
  - Implementasi komponen `GlassCard` dan `CustomBackgroundScaffold` dengan `BackdropFilter` (blur 6–8px) dan border semi-transparan tipis.
  - Teks, angka rilis, dan indikator pasar tetap memiliki kontras 100% terbaca dengan jelas di atas foto wallpaper apapun berkat *adaptive gradient tint layer*.
- **Micro-Interactions & Haptic**:
  - Sentuhan kartu berita, navigasi tab hari, dan filter dilengkapi getaran haptic feedback halus (`HapticFeedback.selectionClick()` dan `HapticFeedback.lightImpact()`).
  - Animasi transisi layar halus dengan `FadeTransition` dan `AnimatedSwitcher`.
- **Shimmer Loading Animation**:
  - Menggantikan spinner generik dengan animasi skeleton loader shimmer (`shimmer: ^3.0.0`) saat memuat data kalender ekonomi.
- **Edge-to-Edge System Bar**:
  - Status bar dan tombol navigasi sistem Android transparan mengikuti mode terang/gelap secara dinamis.

### 3. Fitur Custom Wallpaper Galeri (Portrait 9:16 & Landscape 16:9)
- **Opsi 4 Mode Tema di Halaman Settings**:
  1. *Mode Gelap Default (Dark Theme)* (#121418 khas Myfxbook)
  2. *Mode Terang Default (Light Theme)*
  3. *Mode Gelap dengan Custom Background (Dark Glass)*
  4. *Mode Terang dengan Custom Background (Light Glass)*
- **Manual Crop Terkunci Rasio**:
  - Pemilihan wallpaper portrait otomatis membuka UI pemotong manual yang terkunci pada rasio **9:16**.
  - Pemilihan wallpaper landscape otomatis membuka UI pemotong manual yang terkunci pada rasio **16:9**.
  - Foto hasil potong disimpan secara lokal di internal storage aplikasi dan tersimpan persisten via `SharedPreferences`.
- **Orientation Responsiveness (`OrientationBuilder`)**:
  - Saat posisi ponsel **Portrait**, aplikasi otomatis menampilkan wallpaper portrait (`BoxFit.cover`).
  - Saat ponsel diputar ke **Landscape**, background otomatis beralih ke wallpaper landscape (`BoxFit.cover`).

---

## 📁 Struktur Berkas Proyek
```
fx_calendar_app/
├── android/
│   └── app/
│       ├── build.gradle                   # minSdkVersion 21, compile/targetSdkVersion 34
│       └── src/main/
│           ├── AndroidManifest.xml        # Izin galeri, notifikasi, legacy storage & UCropActivity
│           └── res/values/styles.xml      # Tema launch & normal
├── lib/
│   ├── main.dart                          # Edge-to-edge transparent system bar & inisialisasi
│   ├── models/
│   │   └── economic_event.dart            # Model event, komparasi rilis & sinyal XAU/BTC
│   ├── services/
│   │   ├── calendar_service.dart          # REST fetch, caching, fallback mock riwayat
│   │   └── notification_service.dart      # flutter_local_notifications & dispatch sinyal
│   ├── providers/
│   │   ├── calendar_provider.dart         # State kalender & filter tanggal
│   │   └── app_settings_provider.dart     # State 4 mode tema & crop/pick wallpaper galeri
│   ├── screens/
│   │   ├── main_navigation_screen.dart    # Bottom nav bar dengan CustomBackgroundScaffold
│   │   ├── calendar_screen.dart           # Feed berita 1:1 Myfxbook dengan Shimmer Loading
│   │   ├── event_detail_screen.dart       # Detail berita, analisa XAU/BTC & tren riwayat
│   │   └── settings_screen.dart           # Pengaturan wallpaper 9:16 / 16:9 & glosarium
│   └── widgets/
│       ├── app_theme.dart                 # GoogleFonts Inter & JetBrainsMono Tabular Figures
│       ├── custom_background_scaffold.dart# OrientationBuilder & Frosted GlassCard
│       ├── event_card_widget.dart         # Baris berita dengan haptic & strip warna
│       ├── calendar_shimmer_loading.dart  # Skeleton loading elegan
│       └── filter_dialog.dart             # Dialog filter dampak & mata uang
└── pubspec.yaml                           # Dependensi resmi (image_picker, image_cropper, shimmer, dll)
```

---

## 🚀 Menjalankan Proyek
```bash
cd /data/data/com.termux/files/home/fx_calendar_app
flutter pub get
flutter run
```
