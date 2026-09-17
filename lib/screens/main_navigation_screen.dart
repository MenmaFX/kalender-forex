import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_background_scaffold.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Indeks 3 adalah Kalender Ekonomi (Halaman Utama)
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final hasCustomBg = settings.hasCustomBackground;

    final List<Widget> pages = [
      _buildPlaceholderTab(
        title: 'Home Pasar Forex',
        icon: Icons.dashboard_rounded,
        desc: 'Pantau ikhtisar harga instrumen forex, indeks, dan komoditas global secara real-time.',
      ),
      _buildPlaceholderTab(
        title: 'Portofolio Akun',
        icon: Icons.pie_chart_rounded,
        desc: 'Sinkronisasi riwayat trading, drawdown, dan persentase return akun Anda.',
      ),
      _buildPlaceholderTab(
        title: 'Sistem Trading',
        icon: Icons.analytics_rounded,
        desc: 'Jelajahi algoritma trading, Expert Advisor (EA), dan strategi trader terverifikasi.',
      ),
      const CalendarScreen(), // Kalender Ekonomi 1:1 Myfxbook
      const SettingsScreen(), // Pengaturan Tema, Custom Wallpaper & Kamus
    ];

    return CustomBackgroundScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: hasCustomBg
              ? (isDark ? const Color(0xB3181B22) : const Color(0xCCFFFFFF))
              : (isDark ? AppTheme.myfxHeaderDark : Colors.white),
          border: Border(
            top: BorderSide(
              color: hasCustomBg
                  ? (isDark ? const Color(0x22FFFFFF) : const Color(0x1A000000))
                  : (isDark ? const Color(0xFF262B33) : const Color(0xFFE2E6EC)),
              width: 0.8,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline_rounded),
              activeIcon: Icon(Icons.pie_chart_rounded),
              label: 'Portofolio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics_rounded),
              label: 'Sistem',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Kalender',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              activeIcon: Icon(Icons.tune),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab({
    required String title,
    required IconData icon,
    required String desc,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.myfxOrange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: AppTheme.myfxOrange),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12.5, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.myfxOrange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentIndex = 3; // Pindah ke tab Kalender
                  });
                },
                icon: const Icon(Icons.calendar_month, size: 16),
                label: const Text('Buka Kalender Ekonomi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
