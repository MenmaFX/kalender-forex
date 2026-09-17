import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/economic_event.dart';
import '../providers/calendar_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/calendar_shimmer_loading.dart';
import '../widgets/event_card_widget.dart';
import '../widgets/filter_dialog.dart';
import 'event_detail_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calendar = Provider.of<CalendarProvider>(context);
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final hasCustomBg = settings.hasCustomBackground;

    final filteredEvents = calendar.getFilteredEvents(
      impactFilters: settings.impactFilter,
      currencyFilters: settings.currencyFilter,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: hasCustomBg
            ? (isDark ? const Color(0xB3181B22) : const Color(0xCCFFFFFF))
            : (isDark ? AppTheme.myfxHeaderDark : Colors.white),
        elevation: 0,
        titleSpacing: 12,
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
              'Kalender',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Masuk
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Halaman Masuk (Login) Myfxbook')),
              );
            },
            child: Text(
              'Masuk',
              style: GoogleFonts.inter(
                color: isDark ? Colors.white : const Color(0xFF1E232A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Tombol Daftar
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Halaman Pendaftaran Akun Myfxbook')),
              );
            },
            child: Text(
              'Daftar',
              style: GoogleFonts.inter(
                color: AppTheme.myfxOrange,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Tombol Filter
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: isDark ? Colors.white : const Color(0xFF1E232A),
            ),
            tooltip: 'Filter Kalender',
            onPressed: () {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (_) => FilterDialog(settings: settings),
              );
            },
          ),
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
                        title: 'Kemarin',
                        isActive: calendar.selectedTab == QuickDateTab.yesterday,
                        onTap: () => calendar.setQuickTab(QuickDateTab.yesterday),
                      ),
                      _buildTimeTab(
                        title: 'Hari Ini',
                        isActive: calendar.selectedTab == QuickDateTab.today,
                        onTap: () => calendar.setQuickTab(QuickDateTab.today),
                      ),
                      _buildTimeTab(
                        title: 'Besok',
                        isActive: calendar.selectedTab == QuickDateTab.tomorrow,
                        onTap: () => calendar.setQuickTab(QuickDateTab.tomorrow),
                      ),
                      _buildTimeTab(
                        title: 'Minggu Ini',
                        isActive: calendar.selectedTab == QuickDateTab.thisWeek,
                        onTap: () => calendar.setQuickTab(QuickDateTab.thisWeek),
                      ),
                      _buildTimeTab(
                        title: 'Minggu Depan',
                        isActive: calendar.selectedTab == QuickDateTab.nextWeek,
                        onTap: () => calendar.setQuickTab(QuickDateTab.nextWeek),
                      ),
                    ],
                  ),
                ),
                // Tombol Popup Kalender (Date Range Picker)
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: AppTheme.myfxOrange, size: 20),
                  tooltip: 'Pilih Rentang Tanggal',
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(const Duration(days: 60)),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
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

          // 2. Bar Penunjuk Tanggal Aktif ("Thursday, September 17, 2026 >")
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
                      calendar.formattedActiveDateHeader,
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
                  ? CalendarShimmerLoading(isDark: isDark)
                  : filteredEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.event_busy, size: 52, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada rilis berita ekonomi untuk filter ini.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
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
            color: isActive ? AppTheme.myfxOrange : const Color(0xFF38404D),
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
            color: isActive ? Colors.black : const Color(0xFFB0B7C3),
          ),
        ),
      ),
    );
  }
}
