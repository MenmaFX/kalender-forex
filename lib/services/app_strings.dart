class AppStrings {
  // Common / App Name
  static String appName(String lang) => 'FX Impact';
  static String appSubtitle(String lang) =>
      lang == 'en' ? 'Economic Calendar & Signals' : 'Kalender Ekonomi & Sinyal';

  // Navigation & Screen Titles
  static String calendarTitle(String lang) =>
      lang == 'en' ? 'Calendar' : 'Kalender';
  static String settingsTitle(String lang) =>
      lang == 'en' ? 'Settings & Appearance' : 'Pengaturan & Tampilan';
  static String filterTitle(String lang) =>
      lang == 'en' ? 'Calendar Filter' : 'Filter Kalender';
  static String eventDetailTitle(String lang) =>
      lang == 'en' ? 'Event Detail' : 'Detail Berita';

  // Quick Date Tabs
  static String yesterday(String lang) =>
      lang == 'en' ? 'Yesterday' : 'Kemarin';
  static String today(String lang) =>
      lang == 'en' ? 'Today' : 'Hari Ini';
  static String tomorrow(String lang) =>
      lang == 'en' ? 'Tomorrow' : 'Besok';
  static String thisWeek(String lang) =>
      lang == 'en' ? 'This Week' : 'Minggu Ini';
  static String nextWeek(String lang) =>
      lang == 'en' ? 'Next Week' : 'Minggu Depan';
  static String selectDateRange(String lang) =>
      lang == 'en' ? 'Select Date Range' : 'Pilih Rentang Tanggal';

  // Calendar List States
  static String noEvents(String lang) =>
      lang == 'en'
          ? 'No economic releases found for this filter.'
          : 'Tidak ada rilis berita ekonomi untuk filter ini.';
  static String refresh(String lang) =>
      lang == 'en' ? 'Refresh' : 'Muat Ulang';

  // Metrics Labels
  static String actualLabel(String lang) =>
      lang == 'en' ? 'Act:' : 'Akt:';
  static String forecastLabel(String lang) =>
      lang == 'en' ? 'Cons:' : 'Kons:';
  static String previousLabel(String lang) =>
      lang == 'en' ? 'Prev:' : 'Sebl:';

  static String actualFull(String lang) =>
      lang == 'en' ? 'Actual' : 'Aktual';
  static String forecastFull(String lang) =>
      lang == 'en' ? 'Consensus' : 'Konsensus';
  static String previousFull(String lang) =>
      lang == 'en' ? 'Previous' : 'Sebelumnya';

  // Impact Levels
  static String impactHigh(String lang) =>
      lang == 'en' ? 'High' : 'Tinggi';
  static String impactMedium(String lang) =>
      lang == 'en' ? 'Medium' : 'Sedang';
  static String impactLow(String lang) =>
      lang == 'en' ? 'Low' : 'Rendah';
  static String impactLevel(String lang) =>
      lang == 'en' ? 'Impact Level' : 'Tingkat Dampak';
  static String impactHighLabel(String lang) =>
      lang == 'en' ? 'High (Red)' : 'Tinggi (Merah)';
  static String impactMediumLabel(String lang) =>
      lang == 'en' ? 'Medium (Orange)' : 'Sedang (Oranye)';
  static String impactLowLabel(String lang) =>
      lang == 'en' ? 'Low (Green)' : 'Rendah (Hijau)';

  // Currencies Filter
  static String currencies(String lang) =>
      lang == 'en' ? 'Currencies' : 'Mata Uang (Currencies)';
  static String close(String lang) =>
      lang == 'en' ? 'Close' : 'Tutup';

  // Signals
  static String buyGold(String lang) => 'BUY GOLD';
  static String sellGold(String lang) => 'SELL GOLD';
  static String buyCurrency(String curr) => 'BUY $curr';
  static String sellCurrency(String curr) => 'SELL $curr';
  static String neutral(String lang) =>
      lang == 'en' ? 'NEUTRAL' : 'NETRAL';
  static String waitingRelease(String lang) =>
      lang == 'en' ? 'WAITING' : 'MENUNGGU RILIS';
  static String projectedBuy(String target) =>
      'PROYEKSI: BUY $target';
  static String projectedSell(String target) =>
      'PROYEKSI: SELL $target';

  // Time Countdown & Passed
  static String activeMinutesAgo(String lang, int m) =>
      lang == 'en' ? 'Act. ${m}m ago' : 'Akt. ${m}m';
  static String activeHoursAgo(String lang, int h) =>
      lang == 'en' ? 'Act. ${h}h ago' : 'Akt. ${h}j';
  static String completed(String lang) =>
      lang == 'en' ? 'Completed' : 'Selesai';
  static String inMinutes(String lang, int m) =>
      lang == 'en' ? 'in ${m}m' : 'dlm ${m}m';
  static String inHours(String lang, int h) =>
      lang == 'en' ? 'in ${h}h' : 'dlm ${h}j';

  // Settings Screen
  static String themeSection(String lang) =>
      lang == 'en' ? 'APP THEME & DISPLAY' : 'TEMA & TAMPILAN APLIKASI';
  static String darkDefaultTitle(String lang) =>
      lang == 'en' ? 'Default Dark Mode (Dark Theme)' : 'Mode Gelap Default (Dark Theme)';
  static String darkDefaultDesc(String lang) =>
      lang == 'en' ? 'Clean & elegant dark theme (#101216)' : 'Tema gelap elegan dan bersih (#101216)';
  static String lightDefaultTitle(String lang) =>
      lang == 'en' ? 'Default Light Mode (Light Theme)' : 'Mode Terang Default (Light Theme)';
  static String lightDefaultDesc(String lang) =>
      lang == 'en' ? 'Clean look, high contrast & sharp' : 'Tampilan bersih, kontras tinggi & rapi';
  static String darkGlassTitle(String lang) =>
      lang == 'en' ? 'Dark Mode with Custom Background' : 'Mode Gelap dengan Custom Background';
  static String darkGlassDesc(String lang) =>
      lang == 'en' ? 'Dark frosted surface over your wallpaper' : 'Kontainer semi-transparan gelap di atas wallpaper galeri Anda';
  static String lightGlassTitle(String lang) =>
      lang == 'en' ? 'Light Mode with Custom Background' : 'Mode Terang dengan Custom Background';
  static String lightGlassDesc(String lang) =>
      lang == 'en' ? 'Light frosted surface over your wallpaper' : 'Kontainer semi-transparan terang di atas wallpaper galeri Anda';

  static String wallpaperSection(String lang) =>
      lang == 'en' ? 'CUSTOM WALLPAPER FROM GALLERY' : 'ATUR WALLPAPER LATAR DARI GALERI';
  static String wallpaperDesc(String lang) =>
      lang == 'en'
          ? 'Select photos from your gallery. Crop interactively with 9:16 or 16:9 ratio. Displays sharp without blur!'
          : 'Pilih foto langsung dari galeri HP Anda. Potong gambar secara interaktif dengan rasio 9:16 atau 16:9. Tampil tajam tanpa blur!';
  static String portraitWallpaper(String lang) =>
      lang == 'en' ? 'Portrait Wallpaper (Vertical Mode)' : 'Wallpaper Portrait (Mode Tegak)';
  static String landscapeWallpaper(String lang) =>
      lang == 'en' ? 'Landscape Wallpaper (Horizontal Mode)' : 'Wallpaper Landscape (Mode Miring)';
  static String choosePhoto(String lang) =>
      lang == 'en' ? 'Choose Photo' : 'Pilih Foto';
  static String changePhoto(String lang) =>
      lang == 'en' ? 'Change Photo' : 'Ganti Foto';
  static String deletePhoto(String lang) =>
      lang == 'en' ? 'Delete' : 'Hapus';
  static String wallpaperApplied(String lang, String mode) =>
      lang == 'en' ? '✅ $mode wallpaper applied!' : '✅ Wallpaper $mode berhasil dipasang!';

  // Crop Screen
  static String cropTitle(String lang) =>
      lang == 'en' ? 'Crop & Adjust Background' : 'Potong & Sesuaikan Background';
  static String applyBackground(String lang) =>
      lang == 'en' ? 'Apply Background' : 'Terapkan Background';
  static String portraitRatio(String lang) => 'Portrait (9:16)';
  static String landscapeRatio(String lang) => 'Landscape / Fit (16:9)';
  static String dragToAdjust(String lang) =>
      lang == 'en' ? 'Drag and pinch to adjust crop area' : 'Geser dan cubit untuk mengatur posisi crop';

  // System Preferences
  static String systemSection(String lang) =>
      lang == 'en' ? 'SYSTEM PREFERENCES' : 'PREFERENSI SISTEM';
  static String appLanguage(String lang) =>
      lang == 'en' ? 'Application Language' : 'Bahasa Aplikasi';
  static String reminderBefore(String lang) =>
      lang == 'en' ? 'Pre-Release Alert Reminder' : 'Pengingat Pra-Rilis Berita';
  static String reminderSubtitle(String lang, int m) =>
      lang == 'en' ? 'Notification alerts $m minutes before data release' : 'Notifikasi berbunyi $m menit sebelum data rilis';
  static String minutesSuffix(String lang, int m) =>
      lang == 'en' ? '$m Minutes' : '$m Menit';
  static String testNotificationBtn(String lang) =>
      lang == 'en' ? '🔔 Test Pre-Release Notification' : '🔔 Uji Coba Notifikasi Sekarang';
  static String testNotificationSent(String lang) =>
      lang == 'en' ? 'Notification test triggered! Check your notification tray.' : 'Notifikasi uji coba dikirim! Periksa bar notifikasi Anda.';
  static String notifSoundTitle(String lang) =>
      lang == 'en' ? 'Notification Sound' : 'Suara Notifikasi';
  static String notifSoundSubtitle(String lang) =>
      lang == 'en' ? 'Play sound when calendar alert arrives' : 'Bunyikan nada saat ada sinyal & pengingat';
  static String notifVibrateTitle(String lang) =>
      lang == 'en' ? 'Notification Vibration' : 'Getaran Notifikasi';
  static String notifVibrateSubtitle(String lang) =>
      lang == 'en' ? 'Vibrate device for upcoming forex events' : 'Getarkan HP saat data ekonomi dirilis';
  static String notifVolumeTitle(String lang) =>
      lang == 'en' ? 'Notification Volume' : 'Volume Notifikasi';
  static String notifImpactSection(String lang) =>
      lang == 'en' ? 'FILTER NOTIFICATION IMPACT' : 'FILTER DAMPAK NOTIFIKASI';
  static String notifImpactSubtitle(String lang) =>
      lang == 'en' ? 'Choose which impact levels trigger notifications' : 'Pilih tingkat dampak berita yang memicu notifikasi';
  static String notifCurrencySection(String lang) =>
      lang == 'en' ? 'FILTER NOTIFICATION CURRENCIES' : 'FILTER MATA UANG NOTIFIKASI';
  static String notifCurrencySubtitle(String lang) =>
      lang == 'en' ? 'Turn off currency to mute its news alerts' : 'Matikan mata uang tertentu untuk menghentikan notifikasinya';

  // Favorite Assets
  static String favoriteSection(String lang) =>
      lang == 'en' ? 'FAVORITE ASSET PAIRS' : 'PASANGAN ASET FAVORIT';

  // Beginner Friendly Dictionary (Glossary)
  static String glossarySection(String lang) =>
      lang == 'en' ? 'BEGINNER FRIENDLY DICTIONARY (GLOSSARY)' : 'KAMUS RAMAH PEMULA (GLOSARIUM)';
  static String glossary1Title(String lang) =>
      lang == 'en' ? '1. What is "Actual" (Act.)?' : '1. Apa itu "Aktual" (Akt.)?';
  static String glossary1Desc(String lang) =>
      lang == 'en'
          ? 'Official data figure just released by the government or financial statistics bureau today.'
          : 'Angka resmi yang baru saja dirilis oleh pemerintah atau lembaga statistik keuangan hari ini.';
  static String glossary2Title(String lang) =>
      lang == 'en' ? '2. What is "Consensus / Forecast" (Cons.)?' : '2. Apa itu "Konsensus / Ramalan" (Kons.)?';
  static String glossary2Desc(String lang) =>
      lang == 'en'
          ? 'The average estimate projected by leading global economic analysts prior to the public release.'
          : 'Perkiraan rata-rata analis dan ekonom ternama dunia sebelum data dirilis ke publik.';
  static String glossary3Title(String lang) =>
      lang == 'en' ? '3. What is "Previous" (Prev.)?' : '3. Apa itu "Sebelumnya" (Sebl.)?';
  static String glossary3Desc(String lang) =>
      lang == 'en'
          ? 'The official published data figure from the preceding month or economic quarter.'
          : 'Angka data rilis resmi pada periode bulan atau kuartal terdahulu.';
  static String glossary4Title(String lang) =>
      lang == 'en' ? '4. Impact Indicator Colors Meaning' : '4. Arti Warna Indikator Dampak';
  static String glossary4Desc(String lang) =>
      lang == 'en'
          ? '🔴 Red (High): Volatile market swing across dozens to hundreds of pips.\n🟡 Orange (Medium): Moderate and measurable price fluctuation.\n🟢 Green (Low): Minimal expected price deviation.'
          : '🔴 Merah (Tinggi): Pasar bergerak volatil puluhan hingga ratusan pips.\n🟡 Oranye (Sedang): Pergerakan harga wajar terukur.\n🟢 Hijau (Rendah): Pengaruh fluktuasi harga relatif minim.';
  static String glossary5Title(String lang) =>
      lang == 'en' ? '5. Gold (XAU/USD) & Bitcoin (BTC/USD) Signals' : '5. Sinyal Emas (XAU/USD) & Bitcoin (BTC/USD)';
  static String glossary5Desc(String lang) =>
      lang == 'en'
          ? 'Gold and Bitcoin are traded against the US Dollar (USD):\n• USD Data Stronger than Consensus ➔ Dollar rallies strongly ➔ Gold & Crypto face selling pressure (Action: SELL).\n• USD Data Weaker than Consensus ➔ Dollar slumps ➔ Gold & Crypto likely rally upwards (Action: BUY).'
          : 'Emas dan Bitcoin diperdagangkan berpasangan terhadap Dolar AS (USD):\n• Data USD Lebih Kuat dari Konsensus ➔ Dolar menguat perkasa ➔ Emas & Kripto tertekan (Saran: SELL).\n• Data USD Lebih Lemah dari Konsensus ➔ Dolar melemah lesu ➔ Emas & Kripto berpeluang reli naik (Saran: BUY).';

  // Event Detail Screen
  static String latestRelease(String lang) =>
      lang == 'en' ? 'Latest Release' : 'Rilis Terbaru';
  static String resultBetter(String lang, String country) =>
      lang == 'en'
          ? 'Result Better than Expected (Bullish for $country)'
          : 'Hasil Lebih Baik dari Perkiraan (Kuat untuk $country)';
  static String resultWorse(String lang, String country) =>
      lang == 'en'
          ? 'Result Weaker than Expected (Bearish for $country)'
          : 'Hasil Lebih Rendah dari Perkiraan (Lemah untuk $country)';
  static String resultNeutral(String lang) =>
      lang == 'en'
          ? 'Result In Line with Market Expectations'
          : 'Hasil Sesuai Ekspektasi Pasar';
  static String marketSignalTitleGold(String lang) =>
      lang == 'en' ? 'Market Signal: XAU/USD (Gold) & US Dollar' : 'Sinyal Pasar: XAU/USD (Emas) & Dolar AS';
  static String marketSignalTitleCurr(String lang, String curr) =>
      lang == 'en' ? 'Market Position Signal: $curr' : 'Sinyal Posisi Pasar: $curr';
  static String testSignalButton(String lang) =>
      lang == 'en' ? 'Send Test Signal Notification' : 'Kirim Tes Notifikasi Sinyal';
  static String reminderSetNotice(String lang, int min, String title) =>
      lang == 'en' ? '🔔 Reminder set: $min minutes before $title!' : '🔔 Pengingat disetel: $min menit sebelum $title!';
  static String testSignalNotice(String lang) =>
      lang == 'en' ? 'Simulation signal notification sent!' : 'Notifikasi simulasi sinyal pasar telah dikirim!';
  static String beginnerExplanationTitle(String lang) =>
      lang == 'en' ? 'Beginner Friendly Explanation' : 'Penjelasan Ramah Pemula';
  static String chartTabTitle(String lang) =>
      lang == 'en' ? 'Trend Chart' : 'Grafik Tren';
  static String historyTabTitle(String lang) =>
      lang == 'en' ? 'Release History' : 'Riwayat Rilis';
  static String chartSubtitle(String lang) =>
      lang == 'en' ? 'Previous 12 Periods Trend' : 'Tren Rilis 12 Periode Terdahulu';
  static String traderWarningTitle(String lang) =>
      lang == 'en' ? '⚠️ RISK WARNING & PRE-ENTRY ANALYSIS' : '⚠️ PERINGATAN RISIKO & WAJIB ANALISA';
  static String traderWarningBody(String lang) =>
      lang == 'en'
          ? 'Fundamental news recommendations are probability models. Traders MUST ALWAYS perform comprehensive technical analysis (Support/Resistance, Price Action, Trend) and enforce strict Risk/Money Management before placing any trade. Never FOMO during news volatility!'
          : 'Rekomendasi rilis berita merupakan estimasi probabilitas fundamental. Trader WAJIB SELALU menganalisa secara menyeluruh (Support/Resistance, Price Action, Konfirmasi Trend) dan menerapkan Risk & Money Management ketat sebelum melakukan Entry! Jangan pernah FOMO saat berita rilis!';
}
