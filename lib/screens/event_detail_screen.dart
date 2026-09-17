import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/economic_event.dart';
import '../providers/calendar_provider.dart';
import '../providers/app_settings_provider.dart';
import '../services/app_strings.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_background_scaffold.dart';

class EventDetailScreen extends StatefulWidget {
  final EconomicEvent event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final hasCustomBg = settings.hasCustomBackground;
    final lang = settings.language;
    final historyList = calendarProvider.getHistoricalData(widget.event);

    return CustomBackgroundScaffold(
      appBar: AppBar(
        backgroundColor: hasCustomBg
            ? (isDark ? const Color(0xB3181B22) : const Color(0xCCFFFFFF))
            : (isDark ? AppTheme.myfxHeaderDark : Colors.white),
        elevation: 0,
        title: Text(
          '${widget.event.country} - ${widget.event.title}',
          style: GoogleFonts.inter(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E232A),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: AppTheme.myfxOrange),
            tooltip: AppStrings.reminderBefore(lang),
            onPressed: () {
              calendarProvider.triggerEventReminder(
                widget.event,
                settings.alertMinutesBefore,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF181B20),
                  content: Text(
                    AppStrings.reminderSetNotice(
                      lang,
                      settings.alertMinutesBefore,
                      widget.event.title,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Ringkasan Berita
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.event.flagEmoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.country,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy • HH:mm', lang == 'en' ? 'en_US' : 'id_ID')
                                .format(widget.event.date),
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getImpactColor(widget.event.impactLevel).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _getImpactColor(widget.event.impactLevel),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.event.impact.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _getImpactColor(widget.event.impactLevel),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.event.title,
                    style: GoogleFonts.inter(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. Bagian Rilis Terbaru (Aktual, Konsensus, Sebelumnya)
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.latestRelease(lang),
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricBox(
                        AppStrings.actualFull(lang),
                        widget.event.actual.isEmpty ? '-' : widget.event.actual,
                        isDark: isDark,
                        isAccent: true,
                      ),
                      _buildMetricBox(
                        AppStrings.forecastFull(lang),
                        widget.event.forecast.isEmpty ? '-' : widget.event.forecast,
                        isDark: isDark,
                      ),
                      _buildMetricBox(
                        AppStrings.previousFull(lang),
                        widget.event.previous.isEmpty ? '-' : widget.event.previous,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  // Analisa Badge Sorotan Hasil
                  if (widget.event.actual.isNotEmpty && widget.event.forecast.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: widget.event.outcomeComparison > 0
                            ? const Color(0x2E00E676)
                            : (widget.event.outcomeComparison < 0
                                ? const Color(0x2EFF1744)
                                : const Color(0x229E9E9E)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.event.outcomeComparison > 0
                                ? Icons.check_circle_outline
                                : (widget.event.outcomeComparison < 0
                                    ? Icons.error_outline
                                    : Icons.info_outline),
                            color: widget.event.outcomeComparison > 0
                                ? const Color(0xFF00E676)
                                : (widget.event.outcomeComparison < 0
                                    ? const Color(0xFFFF5252)
                                    : Colors.grey),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.event.outcomeComparison > 0
                                  ? AppStrings.resultBetter(lang, widget.event.country)
                                  : (widget.event.outcomeComparison < 0
                                      ? AppStrings.resultWorse(lang, widget.event.country)
                                      : AppStrings.resultNeutral(lang)),
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: widget.event.outcomeComparison > 0
                                    ? const Color(0xFF00E676)
                                    : (widget.event.outcomeComparison < 0
                                        ? const Color(0xFFFF5252)
                                        : (isDark ? Colors.grey[300] : Colors.grey[800])),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 3. Sinyal Khusus XAU/USD (Emas) & Pasangan Valas
            if (widget.event.country.toUpperCase().isNotEmpty && widget.event.country.toUpperCase() != 'ALL') ...[
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: AppTheme.myfxOrange, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          widget.event.country.toUpperCase() == 'USD'
                              ? AppStrings.marketSignalTitleGold(lang)
                              : AppStrings.marketSignalTitleCurr(lang, widget.event.country.toUpperCase()),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.myfxOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getSignalNarrative(widget.event, lang),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.45,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.myfxOrange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        calendarProvider.triggerSignalAlert(widget.event);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppStrings.testSignalNotice(lang))),
                        );
                      },
                      icon: const Icon(Icons.send_rounded, size: 15),
                      label: Text(AppStrings.testSignalButton(lang)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // 4. Kartu Penjelasan Ramah Pemula
            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: AppTheme.myfxOrange, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.beginnerExplanationTitle(lang),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.beginnerExplanationLocalized(lang),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.45,
                      color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF2E3842),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 5. Tab Bar: Grafik vs Riwayat
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.myfxOrange,
                    indicatorWeight: 3,
                    labelColor: AppTheme.myfxOrange,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: [
                      Tab(text: AppStrings.chartTabTitle(lang)),
                      Tab(text: AppStrings.historyTabTitle(lang)),
                    ],
                  ),
                  SizedBox(
                    height: 250,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildChartTab(historyList, isDark, lang),
                        _buildHistoryTab(historyList, isDark, lang),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(String label, String value, {required bool isDark, bool isAccent = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF888E9B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: AppTheme.tabularFigures(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isAccent
                ? AppTheme.myfxOrange
                : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
        ),
      ],
    );
  }

  String _getSignalNarrative(EconomicEvent event, String lang) {
    final c = event.country.toUpperCase();
    final isEn = lang == 'en';

    if (event.actual.isEmpty) {
      final proj = event.projectionComparison;
      if (c == 'USD') {
        if (proj > 0) {
          return isEn
              ? '📅 UPCOMING EVENT (PROJECTED: SELL GOLD / BUY USD):\nConsensus (${event.forecast}) is higher than previous (${event.previous}). If actual matches or beats forecast, the US Dollar is projected to surge, triggering selling pressure on Gold (SELL GOLD) and a USD rally.'
              : '📅 EVENT MENDATANG (PROYEKSI: SELL GOLD / BUY USD):\nKonsensus (${event.forecast}) lebih tinggi dari sebelumnya (${event.previous}). Jika rilis aktual sesuai atau melampaui ramalan, Dolar AS diproyeksikan menguat kuat, memicu tekanan jual pada Emas (SELL GOLD) dan lonjakan Dolar (BUY USD).';
        } else if (proj < 0) {
          return isEn
              ? '📅 UPCOMING EVENT (PROJECTED: BUY GOLD / SELL USD):\nConsensus (${event.forecast}) is lower than previous (${event.previous}). If actual weakens, the US Dollar risks depreciating, fueling Gold prices (BUY GOLD) and Dollar weakening.'
              : '📅 EVENT MENDATANG (PROYEKSI: BUY GOLD / SELL USD):\nKonsensus (${event.forecast}) lebih rendah dari sebelumnya (${event.previous}). Jika rilis aktual melemah, Dolar AS berisiko terdepresiasi, mendorong kenaikan harga Emas (BUY GOLD) dan pelemahan Dolar (SELL USD).';
        } else {
          return isEn
              ? '📅 UPCOMING EVENT:\nData not yet released. If actual USD exceeds forecast (${event.forecast}), Dollar may surge (Action: SELL GOLD / BUY USD). Conversely, if below forecast (Action: BUY GOLD / SELL USD).'
              : '📅 EVENT MENDATANG:\nData belum dirilis. Jika angka aktual USD melampaui ramalan (${event.forecast}), Dolar AS berpotensi melonjak (Saran: SELL GOLD / BUY USD). Sebaliknya jika di bawah ramalan (Saran: BUY GOLD / SELL USD).';
        }
      } else {
        if (proj > 0) {
          return isEn
              ? '📅 UPCOMING EVENT (PROJECTED: BUY $c):\nConsensus (${event.forecast}) is better than previous period (${event.previous}). A positive release supports bullish sentiment for $c.'
              : '📅 EVENT MENDATANG (PROYEKSI: BUY $c):\nKonsensus (${event.forecast}) diproyeksikan lebih baik dibanding periode lalu (${event.previous}). Jika aktual terkonfirmasi positif, mata uang $c berpotensi menguat terhadap pasangannya.';
        } else if (proj < 0) {
          return isEn
              ? '📅 UPCOMING EVENT (PROJECTED: SELL $c):\nConsensus (${event.forecast}) is weaker. Be cautious of selling pressure on $c post-release.'
              : '📅 EVENT MENDATANG (PROYEKSI: SELL $c):\nKonsensus (${event.forecast}) diperkirakan lebih lemah. Waspadai potensi tekanan jual pada mata uang $c pasca rilis.';
        } else {
          return isEn
              ? '📅 UPCOMING EVENT:\nData pending. Monitor actual release relative to forecast (${event.forecast}).'
              : '📅 EVENT MENDATANG:\nData belum dirilis. Pantau rilis aktual terhadap ramalan (${event.forecast}). Angka aktual yang lebih tinggi memberi sentimen positif (BUY $c).';
        }
      }
    }

    if (c == 'USD') {
      switch (event.signalRecommendation) {
        case SignalRecommendation.strongSellGoldBtc:
          return isEn
              ? '🔥 STRONG USD ACTUAL (Actual > Forecast):\nUS Dollar surges. Demand for Spot Gold (XAU/USD) & Bitcoin faces steep selling pressure.\n👉 Action Signal: SELL GOLD / BUY USD.'
              : '🔥 HASIL AKTUAL USD SANGAT KUAT (Actual > Forecast):\nDolar AS melonjak naik. Permintaan terhadap Emas (XAU/USD) & Bitcoin tertekan turun tajam.\n👉 Rekomendasi Posisi: SELL GOLD / BUY USD.';
        case SignalRecommendation.strongBuyGoldBtc:
          return isEn
              ? '🟢 WEAK USD ACTUAL (Actual < Forecast):\nUS Dollar slumps. Safe-haven assets like Spot Gold (XAU/USD) & Crypto have room to rally higher.\n👉 Action Signal: BUY GOLD / SELL USD.'
              : '🟢 HASIL AKTUAL USD DI BAWAH PREDIKSI (Actual < Forecast):\nDolar AS melemah. Aset lindung nilai seperti Emas (XAU/USD) berpeluang melesat naik tinggi.\n👉 Rekomendasi Posisi: BUY GOLD / SELL USD.';
        case SignalRecommendation.neutral:
          return isEn
              ? '⚖️ ACTUAL IN LINE WITH EXPECTATIONS:\nInstant volatility remains balanced.\n👉 Action: NEUTRAL / Wait for candle confirmation.'
              : '⚖️ HASIL AKTUAL SESUAI EKSPEKTASI:\nDampak volatilitas instan relatif seimbang.\n👉 Rekomendasi Posisi: NETRAL / Tunggu konfirmasi pola candlestick.';
        default:
          return isEn
              ? 'Monitor price action after 15-minute candle closes.'
              : 'Pantau reaksi harga saat penutupan candle 15 menit pasca rilis.';
      }
    } else {
      switch (event.signalRecommendation) {
        case SignalRecommendation.buyCurrency:
          return isEn
              ? '🟢 ACTUAL DATA FOR $c BEATS CONSENSUS:\nEconomic indicators point to positive growth. Bullish sentiment for $c.\n👉 Action Signal: BUY $c.'
              : '🟢 HASIL DATA $c LEBIH BAIK DARI KONSENSUS:\nEkonomi $c menunjukkan performa positif. Sentimen bullish untuk $c.\n👉 Rekomendasi Posisi: BUY $c.';
        case SignalRecommendation.sellCurrency:
          return isEn
              ? '🔴 ACTUAL DATA FOR $c WEAKER THAN CONSENSUS:\nEconomic indicators suggest a slowdown. Bearish sentiment for $c.\n👉 Action Signal: SELL $c.'
              : '🔴 HASIL DATA $c LEBIH BURUK DARI KONSENSUS:\nEkonomi $c mengalami perlambatan relatif. Sentimen bearish untuk $c.\n👉 Rekomendasi Posisi: SELL $c.';
        case SignalRecommendation.neutral:
          return isEn
              ? '⚖️ ACTUAL IN LINE WITH EXPECTATIONS:\nModerate volatility expected.\n👉 Action: NEUTRAL.'
              : '⚖️ HASIL AKTUAL SESUAI EKSPEKTASI:\nVolatilitas diperkirakan moderat.\n👉 Rekomendasi Posisi: NETRAL.';
        default:
          return isEn
              ? 'Monitor trend on $c currency pairs post-release.'
              : 'Pantau tren pergerakan mata uang $c pasca rilis berita.';
      }
    }
  }

  Widget _buildChartTab(List<HistoricalRelease> history, bool isDark, String lang) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.chartSubtitle(lang),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: history.reversed.map((item) {
                final double? numVal = double.tryParse(item.actual.replaceAll(RegExp(r'[^0-9.-]'), ''));
                final barHeight = ((numVal ?? 2.0).abs() * 30).clamp(25.0, 140.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item.actual,
                      style: AppTheme.tabularFigures(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 22,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: AppTheme.myfxOrange,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.myfxOrange.withOpacity(0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMM', lang == 'en' ? 'en_US' : 'id_ID').format(item.date),
                      style: GoogleFonts.inter(fontSize: 9.5, color: Colors.grey),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<HistoricalRelease> history, bool isDark, String lang) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = history[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMM yyyy', lang == 'en' ? 'en_US' : 'id_ID').format(item.date),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              Row(
                children: [
                  Text('${AppStrings.actualLabel(lang)} ', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.grey)),
                  Text(
                    item.actual,
                    style: AppTheme.tabularFigures(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${AppStrings.forecastLabel(lang)} ', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.grey)),
                  Text(
                    item.forecast,
                    style: AppTheme.tabularFigures(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(width: 10),
                  Text('${AppStrings.previousLabel(lang)} ', style: GoogleFonts.inter(fontSize: 10.5, color: Colors.grey)),
                  Text(
                    item.previous,
                    style: AppTheme.tabularFigures(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
