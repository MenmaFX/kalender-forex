import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppTheme {
  // Palet Warna Khas Myfxbook
  static const Color myfxDarkBg = Color(0xFF121418); // Dark background utama
  static const Color myfxCardDark = Color(0xFF1B1E24); // Card baris berita solid
  static const Color myfxHeaderDark = Color(0xFF181B20); // Top bar & tab bar
  static const Color myfxOrange = Color(0xFFFFA500); // Oranye khas Myfxbook
  static const Color myfxAccentOrange = Color(0xFFFF8C00);

  // Palet Glassmorphism (Frosted Glass Transparan)
  static const Color glassDarkCard = Color(0xCC161920); // 80% opacity dark glass
  static const Color glassDarkBorder = Color(0x33FFFFFF); // 20% white border
  static const Color glassLightCard = Color(0xD9FFFFFF); // 85% opacity white glass
  static const Color glassLightBorder = Color(0x33000000); // 20% black border

  // Indikator Dampak (Impact)
  static const Color impactHigh = Color(0xFFE53935); // Merah Terang
  static const Color impactMedium = Color(0xFFFFA000); // Oranye / Kuning Tua
  static const Color impactLow = Color(0xFF43A047); // Hijau
  static const Color impactHoliday = Color(0xFF757575); // Abu-abu

  // Outcome Colors (Aktual vs Konsensus)
  static const Color outcomeBetter = Color(0xFF00E676); // Hijau cerah
  static const Color outcomeWorse = Color(0xFFFF1744); // Merah cerah
  static const Color outcomeNeutral = Color(0xFF9E9E9E); // Abu-abu

  // Tema Gelap (Dark Mode Myfxbook Profesional)
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: myfxDarkBg,
      primaryColor: myfxOrange,
      colorScheme: const ColorScheme.dark(
        primary: myfxOrange,
        secondary: myfxOrange,
        surface: myfxCardDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: myfxHeaderDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 17,
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
      cardTheme: CardTheme(
        color: myfxCardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF262B33), width: 0.8),
        ),
      ),
      dividerColor: const Color(0xFF262B33),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFFCCCCCC), fontSize: 13),
        bodySmall: GoogleFonts.inter(color: const Color(0xFF888E9B), fontSize: 11),
      ),
    );
  }

  // Tema Terang (Light Mode Profesional)
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      primaryColor: myfxOrange,
      colorScheme: const ColorScheme.light(
        primary: myfxOrange,
        secondary: myfxOrange,
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1E232A)),
        titleTextStyle: GoogleFonts.inter(
          color: const Color(0xFF1E232A),
          fontSize: 17,
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
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE2E6EC), width: 0.8),
        ),
      ),
      dividerColor: const Color(0xFFE2E6EC),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: GoogleFonts.inter(color: const Color(0xFF212121), fontSize: 14),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFF424242), fontSize: 13),
        bodySmall: GoogleFonts.inter(color: const Color(0xFF757575), fontSize: 11),
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
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: -0.2,
    );
  }
}
