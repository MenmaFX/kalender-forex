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

  // Pasang custom ErrorWidget.builder agar jika terjadi error widget,
  // tidak menampilkan layar abu-abu mati (Grey Screen of Death) melainkan UI fallback yang rapi
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF121418),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.myfxOrange,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Memuat Tampilan...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Konfigurasi Status Bar & Navigation Bar Android Transparan / Edge-to-Edge
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
        // Update status bar icons sesuai kecerahan tema aktif
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: settings.isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: settings.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'FX Impact',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
