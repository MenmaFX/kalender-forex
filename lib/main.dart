import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/calendar_provider.dart';
import 'providers/app_settings_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'widgets/app_theme.dart';

void main() async {
  // 1. Pastikan binding widget diinisialisasi paling awal
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal lokal (Indonesia & Inggris) untuk intl DateFormat
  try {
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en_US', null);
  } catch (e) {
    debugPrint('Init date formatting error: $e');
  }

  // 2. Aktifkan Edge-to-Edge murni di level window Android
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Default Overlay Style awal (sebelum Provider aktif)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Inisialisasi Service Notifikasi dengan aman
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }

  // MultiProvider membungkus seluruh aplikasi di atas MaterialApp
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: const FxCalendarApp(),
    ),
  );
}

class FxCalendarApp extends StatelessWidget {
  const FxCalendarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settings, child) {
        final isDark = settings.isDarkMode;

        // Kontrol penuh ikon status bar & tombol/garis navigasi:
        // Di Mode Gelap: ikon bar atas dan tombol navigasi bawah = PUTIH (Brightness.light)
        // Di Mode Terang: ikon bar atas dan tombol navigasi bawah = HITAM (Brightness.dark)
        final overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        );

        SystemChrome.setSystemUIOverlayStyle(overlayStyle);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: MaterialApp(
            title: 'FX Impact',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
