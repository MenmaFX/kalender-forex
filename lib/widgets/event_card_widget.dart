import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/economic_event.dart';
import '../providers/app_settings_provider.dart';
import '../services/app_strings.dart';
import 'app_theme.dart';

class EventCardWidget extends StatelessWidget {
  final EconomicEvent event;
  final VoidCallback onTap;

  const EventCardWidget({
    Key? key,
    required this.event,
    required this.onTap,
  }) : super(key: key);

  Color _getImpactColor(ImpactLevel level) {
    switch (level) {
      case ImpactLevel.high:
        return AppTheme.impactHigh;
      case ImpactLevel.medium:
        return AppTheme.impactMedium;
      case ImpactLevel.low:
        return AppTheme.impactLow;
      case ImpactLevel.holiday:
      default:
        return AppTheme.impactHoliday;
    }
  }

  String _getTimeAgoOrCountdown(DateTime eventTime, String lang) {
    final now = DateTime.now();
    final diff = eventTime.difference(now);

    if (diff.isNegative) {
      final passed = now.difference(eventTime);
      if (passed.inMinutes < 60) {
        return AppStrings.activeMinutesAgo(lang, passed.inMinutes);
      } else if (passed.inHours < 24) {
        return AppStrings.activeHoursAgo(lang, passed.inHours);
      } else {
        return AppStrings.completed(lang);
      }
    } else {
      if (diff.inMinutes < 60) {
        return AppStrings.inMinutes(lang, diff.inMinutes);
      } else if (diff.inHours < 24) {
        return AppStrings.inHours(lang, diff.inHours);
      } else {
        return DateFormat('d MMM').format(eventTime);
      }
    }
  }

  Color _getActualTextColor(bool isDark) {
    final outcome = event.outcomeComparison;
    if (outcome > 0) return AppTheme.outcomeBetter;
    if (outcome < 0) return AppTheme.outcomeWorse;
    return isDark ? Colors.white : const Color(0xFF1E232A);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final hasCustomBg = settings.hasCustomBackground;
    final lang = settings.language;
    final timeString = DateFormat('HH:mm').format(event.date);
    final impactColor = _getImpactColor(event.impactLevel);

    // Warna permukaan kartu semi-transparan ~0.85 (dark) dan ~0.90 (light) tanpa ImageFilter.blur
    final Color cardBgColor = hasCustomBg
        ? (isDark ? const Color(0xD9181B22) : const Color(0xE6FFFFFF))
        : (isDark ? AppTheme.myfxCardDark : Colors.white);

    final Color cardBorderColor = hasCustomBg
        ? (isDark ? const Color(0x33FFFFFF) : const Color(0x22000000))
        : (isDark ? const Color(0xFF23272F) : const Color(0xFFEDEFF3));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        splashColor: AppTheme.myfxOrange.withOpacity(0.12),
        highlightColor: AppTheme.myfxOrange.withOpacity(0.06),
        child: Container(
          decoration: BoxDecoration(
            color: cardBgColor,
            border: Border(
              bottom: BorderSide(
                color: cardBorderColor,
                width: 0.8,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kolom Waktu & Strip Vertikal Indikator Dampak
                SizedBox(
                  width: 58,
                  child: Row(
                    children: [
                      Container(
                        width: 3.5,
                        height: 38,
                        decoration: BoxDecoration(
                          color: impactColor,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: impactColor.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeString,
                            style: AppTheme.tabularFigures(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1E232A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _getTimeAgoOrCountdown(event.date, lang),
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF888E9B) : const Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // 2. Bendera & Kode Mata Uang
                Container(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Text(
                        event.flagEmoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.country,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isDark ? const Color(0xFFB0B7C3) : const Color(0xFF37474F),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // 3. Judul Berita & Angka Metrik (Tabular Alignment)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: isDark ? Colors.white : const Color(0xFF1E232A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Kolom Angka Tabular (Akt, Kons, Sebl)
                      Row(
                        children: [
                          _buildMetric(
                            label: AppStrings.actualLabel(lang),
                            value: event.actual.isEmpty ? '-' : event.actual,
                            textColor: event.actual.isEmpty ? null : _getActualTextColor(isDark),
                            isBold: true,
                          ),
                          const SizedBox(width: 12),
                          _buildMetric(
                            label: AppStrings.forecastLabel(lang),
                            value: event.forecast.isEmpty ? '-' : event.forecast,
                          ),
                          const SizedBox(width: 12),
                          _buildMetric(
                            label: AppStrings.previousLabel(lang),
                            value: event.previous.isEmpty ? '-' : event.previous,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Badge Sinyal (BUY/SELL Currency/Gold & Proyeksi Event Mendatang)
                if (event.signalBadgeText != null) ...[
                  const SizedBox(width: 4),
                  _buildSignalBadge(event, lang),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    Color? textColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color(0xFF888E9B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          value,
          style: AppTheme.tabularFigures(
            fontSize: 11,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: textColor ?? const Color(0xFFB0B7C3),
          ),
        ),
      ],
    );
  }

  Widget _buildSignalBadge(EconomicEvent event, String lang) {
    final text = event.signalBadgeTextLocalized(lang);
    final type = event.signalType;

    Color bgColor;
    Color borderColor;
    Color textColor;

    switch (type) {
      case SignalType.buyGold:
      case SignalType.buyCurrency:
        bgColor = const Color(0x2E00E676);
        borderColor = const Color(0xFF00E676);
        textColor = const Color(0xFF00E676);
        break;
      case SignalType.sellGold:
      case SignalType.sellCurrency:
        bgColor = const Color(0x2EFF1744);
        borderColor = const Color(0xFFFF1744);
        textColor = const Color(0xFFFF5252);
        break;
      case SignalType.projectedBuy:
        bgColor = const Color(0x2400E676);
        borderColor = const Color(0x8800E676);
        textColor = const Color(0xFF69F0AE);
        break;
      case SignalType.projectedSell:
        bgColor = const Color(0x24FF5252);
        borderColor = const Color(0x88FF5252);
        textColor = const Color(0xFFFF8A80);
        break;
      case SignalType.neutral:
        bgColor = const Color(0x229E9E9E);
        borderColor = const Color(0x669E9E9E);
        textColor = const Color(0xFFBDBDBD);
        break;
      case SignalType.none:
        bgColor = const Color(0x22FFA500);
        borderColor = const Color(0x66FFA500);
        textColor = AppTheme.myfxOrange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Text(
        text ?? '',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
