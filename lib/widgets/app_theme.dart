import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palet Warna Fintech Profesional & Elegan
  static const Color myfxDarkBg = Color(0xFF101216); // Dark background solid & bersih
  static const Color myfxCardDark = Color(0xFF181B21); // Card baris berita solid
  static const Color myfxHeaderDark = Color(0xFF14171C); // Top bar & tab bar
  static const Color myfxOrange = Color(0xFFFFA500); // Aksen oranye modern
  static const Color myfxAccentOrange = Color(0xFFFF8C00);

  // Palet Glassmorphism (Frosted Glass Transparan saat pakai wallpaper custom)
  static const Color glassDarkCard = Color(0xCC14171C); // 80% opacity dark glass
  static const Color glassDarkBorder = Color(0x2BFFFFFF); // 17% white border
  static const Color glassLightCard = Color(0xEBFFFFFF); // 92% opacity white glass
  static const Color glassLightBorder = Color(0x1F000000); // 12% black border

  // Indikator Dampak (Impact)
  static const Color impactHigh = Color(0xFFE53935); // Merah Terang
  static const Color impactMedium = Color(0xFFFFA000); // Oranye / Kuning Tua
  static const Color impactLow = Color(0xFF43A047); // Hijau
  static const Color impactHoliday = Color(0xFF757575); // Abu-abu

  // Outcome Colors (Aktual vs Konsensus)
  static const Color outcomeBetter = Color(0xFF00C853); // Hijau solid fintech
  static const Color outcomeWorse = Color(0xFFD50000); // Merah solid fintech
  static const Color outcomeNeutral = Color(0xFF78909C); // Abu-abu kebiruan

  // Tema Gelap (Dark Mode Profesional & Bersih - Tanpa Coklat/Krem Aneh)
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: myfxDarkBg,
      primaryColor: myfxOrange,
      colorScheme: const ColorScheme.dark(
        primary: myfxOrange,
        secondary: myfxOrange,
        surface: myfxCardDark,
        surfaceTint: Colors.transparent, // KUNCI: Mencegah warna berubah coklat/krem saat di-scroll
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: myfxHeaderDark,
        surfaceTintColor: Colors.transparent, // KUNCI: Menghilangkan tint coklat scroll
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16.5,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: myfxHeaderDark,
        selectedItemColor: myfxOrange,
        unselectedItemColor: const Color(0xFF888E9B),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: myfxCardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF22262E), width: 0.8),
        ),
      ),
      dividerColor: const Color(0xFF22262E),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFFD0D5DD), fontSize: 13),
        bodySmall: GoogleFonts.inter(color: const Color(0xFF888E9B), fontSize: 11),
      ),
    );
  }

  // Tema Terang (Light Mode Bersih - Tanpa Coklat/Krem Aneh)
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF3F5F8),
      primaryColor: myfxOrange,
      colorScheme: const ColorScheme.light(
        primary: myfxOrange,
        secondary: myfxOrange,
        surface: Colors.white,
        surfaceTint: Colors.transparent, // KUNCI: Mencegah warna berubah krem saat di-scroll
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent, // KUNCI: Menghilangkan tint krem scroll
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E232A)),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.inter(
          color: const Color(0xFF1E232A),
          fontSize: 16.5,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: myfxOrange,
        unselectedItemColor: const Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE2E6EC), width: 0.8),
        ),
      ),
      dividerColor: const Color(0xFFE2E6EC),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: GoogleFonts.inter(color: const Color(0xFF1E232A), fontSize: 14),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFF475467), fontSize: 13),
        bodySmall: GoogleFonts.inter(color: const Color(0xFF667085), fontSize: 11),
      ),
    );
  }

  // Gaya Angka Monospace/Tabular Figures untuk Kolom Angka Forex (Akt./Kons./Sebl.)
  static TextStyle tabularFigures({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.2,
    );
  }
}
