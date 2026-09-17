import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';
import '../providers/app_settings_provider.dart';
import '../services/app_strings.dart';
import '../widgets/app_theme.dart';
import '../widgets/calendar_shimmer_loading.dart';
import '../widgets/custom_background_scaffold.dart';
import '../widgets/event_card_widget.dart';
import '../widgets/filter_dialog.dart';
import 'event_detail_screen.dart';
import 'settings_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Null safety & defensive provider lookup
    CalendarProvider? calendar;
    AppSettingsProvider? settings;

    try {
      calendar = Provider.of<CalendarProvider>(context);
      settings = Provider.of<AppSettingsProvider>(context);
    } catch (e) {
      debugPrint('Error accessing providers in CalendarScreen: $e');
    }

    // Jika provider belum siap atau data null, tampilkan indikator loading aman bukan grey screen
    if (calendar == null || settings == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121418),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: AppTheme.myfxOrange),
              SizedBox(height: 16),
              Text(
                'Menyiapkan Kalender...',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = settings.isDarkMode;
    final hasCustomBg = settings.hasCustomBackground;
    final lang = settings.language;

    final filteredEvents = calendar.getFilteredEvents(
      impactFilters: settings.impactFilter,
      currencyFilters: settings.currencyFilter,
    );

    return CustomBackgroundScaffold(
      // Scaffold murni single-screen: TIDAK ADA BottomNavigationBar, TIDAK ADA tombol Masuk/Daftar
      appBar: AppBar(
        backgroundColor: hasCustomBg
            ? (isDark ? const Color(0xB3181B22) : const Color(0xCCFFFFFF))
            : (isDark ? AppTheme.myfxHeaderDark : Colors.white),
        elevation: 0,
        titleSpacing: 14,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: AppTheme.myfxOrange,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.myfxOrange.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                'fx',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.calendarTitle(lang),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                letterSpacing: -0.2,
                color: isDark ? Colors.white : const Color(0xFF1E232A),
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Filter (Sebelah Kiri Tombol Pengaturan, Ikon 22-24dp, compact padding/splash 8dp)
          IconButton(
            iconSize: 22,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            splashRadius: 20,
            icon: Icon(
              Icons.tune_rounded,
              color: isDark ? Colors.white : const Color(0xFF1E232A),
            ),
            tooltip: AppStrings.filterTitle(lang),
            onPressed: () {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (_) => FilterDialog(settings: settings),
              );
            },
          ),
          // Tombol Pengaturan (Paling Pojok Kanan, Ikon 22-24dp, compact padding/splash 8dp)
          IconButton(
            iconSize: 22,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            splashRadius: 20,
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : const Color(0xFF1E232A),
            ),
            tooltip: AppStrings.settingsTitle(lang),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // 1. Tab Bar Waktu Cepat (Horizontal Chips) + Date Range Picker
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: hasCustomBg
                  ? (isDark ? const Color(0x99181B22) : const Color(0xB3FFFFFF))
                  : (isDark ? AppTheme.myfxHeaderDark : Colors.white),
              border: Border(
                bottom: BorderSide(
                  color: hasCustomBg
                      ? (isDark ? const Color(0x22FFFFFF) : const Color(0x1A000000))
                      : (isDark ? const Color(0xFF262B33) : const Color(0xFFE2E6EC)),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    children: [
                      _buildTimeTab(
                        title: AppStrings.yesterday(lang),
                        isActive: calendar.selectedTab == QuickDateTab.yesterday,
                        isDark: isDark,
                        onTap: () => calendar.setQuickTab(QuickDateTab.yesterday),
                      ),
                      _buildTimeTab(
                        title: AppStrings.today(lang),
                        isActive: calendar.selectedTab == QuickDateTab.today,
                        isDark: isDark,
                        onTap: () => calendar.setQuickTab(QuickDateTab.today),
                      ),
                      _buildTimeTab(
                        title: AppStrings.tomorrow(lang),
                        isActive: calendar.selectedTab == QuickDateTab.tomorrow,
                        isDark: isDark,
                        onTap: () => calendar.setQuickTab(QuickDateTab.tomorrow),
                      ),
                      _buildTimeTab(
                        title: AppStrings.thisWeek(lang),
                        isActive: calendar.selectedTab == QuickDateTab.thisWeek,
                        isDark: isDark,
                        onTap: () => calendar.setQuickTab(QuickDateTab.thisWeek),
                      ),
                      _buildTimeTab(
                        title: AppStrings.nextWeek(lang),
                        isActive: calendar.selectedTab == QuickDateTab.nextWeek,
                        isDark: isDark,
                        onTap: () => calendar.setQuickTab(QuickDateTab.nextWeek),
                      ),
                    ],
                  ),
                ),
                // Tombol Popup Kalender (Date Range Picker)
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: AppTheme.myfxOrange, size: 20),
                  tooltip: AppStrings.selectDateRange(lang),
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      initialDateRange: DateTimeRange(
                        start: DateTime.now(),
                        end: DateTime.now().add(const Duration(days: 3)),
                      ),
                      builder: (context, child) {
                        return Theme(
                          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      calendar.setCustomRange(picked);
                    }
                  },
                ),
              ],
            ),
          ),

          // 2. Bar Penunjuk Tanggal Aktif (Multi-bahasa & adaptif)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: hasCustomBg
                  ? (isDark ? const Color(0x80121418) : const Color(0x99FFFFFF))
                  : (isDark ? const Color(0xFF14171C) : const Color(0xFFEDEFF3)),
              border: Border(
                bottom: BorderSide(
                  color: hasCustomBg
                      ? (isDark ? const Color(0x1FFFFFFF) : const Color(0x14000000))
                      : (isDark ? const Color(0xFF262B33) : const Color(0xFFDCE2EC)),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    calendar.shiftDate(-1);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.chevron_left, size: 20, color: Colors.grey),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      calendar.formattedActiveDateHeaderLocalized(lang),
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.myfxOrange),
                  ],
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    calendar.shiftDate(1);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          // 3. Daftar Berita Kalender dengan Shimmer Loading Elegan & Transisi Halus
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: calendar.isLoading
                  ? CalendarShimmerLoading(key: const ValueKey('loading'), isDark: isDark)
                  : filteredEvents.isEmpty
                      ? Center(
                          key: const ValueKey('empty'),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.event_busy, size: 52, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(
                                AppStrings.noEvents(lang),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[400] : const Color(0xFF424242),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          key: const ValueKey('data_list'),
                          color: AppTheme.myfxOrange,
                          onRefresh: () async {
                            HapticFeedback.mediumImpact();
                            await calendar.loadEvents();
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: filteredEvents.length,
                            itemBuilder: (context, index) {
                              final event = filteredEvents[index];
                              return EventCardWidget(
                                event: event,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 250),
                                      pageBuilder: (_, animation, secondaryAnimation) =>
                                          FadeTransition(
                                        opacity: animation,
                                        child: EventDetailScreen(event: event),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTab({
    required String title,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5.5),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.myfxOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppTheme.myfxOrange
                : (isDark ? const Color(0xFF38404D) : const Color(0xFFCFD8DC)),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.myfxOrange.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive
                ? Colors.black
                : (isDark ? const Color(0xFFB0B7C3) : const Color(0xFF37474F)),
          ),
        ),
      ),
    );
  }
}
