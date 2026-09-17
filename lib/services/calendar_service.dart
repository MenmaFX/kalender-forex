import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/economic_event.dart';

class CalendarService {
  static const String apiUrl = 'https://nfs.faireconomy.media/ff_calendar_thisweek.json';
  static const String cacheKey = 'cached_economic_events';
  static const String lastFetchKey = 'last_fetch_timestamp';

  // Ambil data kalender ekonomi (dengan fallback cache & mock)
  Future<List<EconomicEvent>> fetchCalendarEvents() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        final events = decoded.map((e) => EconomicEvent.fromJson(e)).toList();

        // Simpan ke SharedPreferences Cache
        await prefs.setString(cacheKey, response.body);
        await prefs.setInt(lastFetchKey, DateTime.now().millisecondsSinceEpoch);

        return events;
      }
    } catch (e) {
      debugPrint('Gagal fetch API: $e. Membaca cache lokal.');
    }

    // Ambil dari Cache jika jaringan bermasalah
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(cachedData);
        return decoded.map((e) => EconomicEvent.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Cache parsing error: $e');
      }
    }

    // Fallback Mock Data Lengkap jika offline pertama kali
    return _generateFallbackEvents();
  }

  // Generator Data Riwayat Masa Lalu (Mock Historical) untuk Tab Detail
  List<HistoricalRelease> getHistoricalReleases(EconomicEvent event) {
    final List<HistoricalRelease> history = [];
    final now = event.date;

    // Nilai dasar dari forecast/previous
    final baseNum = double.tryParse(event.previous.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 2.5;
    final isPercent = event.previous.contains('%');
    final isK = event.previous.toUpperCase().contains('K');

    String formatVal(double v) {
      final rounded = v.toStringAsFixed(1);
      if (isPercent) return '$rounded%';
      if (isK) return '${(v.toInt())}K';
      return rounded;
    }

    for (int i = 1; i <= 6; i++) {
      final pastDate = DateTime(now.year, now.month - i, now.day.clamp(1, 28));
      final act = baseNum + ((i % 2 == 0) ? (0.2 * i) : (-0.15 * i));
      final fct = baseNum + 0.1;
      final prev = baseNum - 0.1;

      history.add(HistoricalRelease(
        date: pastDate,
        actual: formatVal(act),
        forecast: formatVal(fct),
        previous: formatVal(prev),
      ));
    }

    return history;
  }

  // Mock Events Komprehensif menyerupai Feed Real Myfxbook
  List<EconomicEvent> _generateFallbackEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      // Hari ini
      EconomicEvent(
        title: 'Core CPI m/m (Indeks Harga Konsumen Inti)',
        country: 'USD',
        date: today.add(const Duration(hours: 19, minutes: 30)), // 19:30 WIB
        impact: 'High',
        forecast: '0.3%',
        previous: '0.2%',
        actual: '0.4%', // Lebih tinggi -> Dolar Kuat -> Sell Gold
      ),
      EconomicEvent(
        title: 'Initial Jobless Claims (Klaim Pengangguran)',
        country: 'USD',
        date: today.add(const Duration(hours: 19, minutes: 30)),
        impact: 'High',
        forecast: '230K',
        previous: '228K',
        actual: '222K', // Klaim lebih sedikit -> Ekonomi Bagus
      ),
      EconomicEvent(
        title: 'ECB Main Refinancing Rate',
        country: 'EUR',
        date: today.add(const Duration(hours: 19, minutes: 15)),
        impact: 'High',
        forecast: '3.65%',
        previous: '3.75%',
        actual: '3.65%',
      ),
      EconomicEvent(
        title: 'Retail Sales m/m',
        country: 'GBP',
        date: today.add(const Duration(hours: 13, minutes: 0)),
        impact: 'Medium',
        forecast: '0.4%',
        previous: '0.5%',
        actual: '0.6%',
      ),
      EconomicEvent(
        title: 'BOJ Monetary Policy Statement',
        country: 'JPY',
        date: today.add(const Duration(hours: 10, minutes: 30)),
        impact: 'High',
        forecast: '0.25%',
        previous: '0.25%',
        actual: '0.25%',
      ),
      EconomicEvent(
        title: 'Natural Gas Storage',
        country: 'USD',
        date: today.add(const Duration(hours: 21, minutes: 30)),
        impact: 'Low',
        forecast: '58B',
        previous: '40B',
        actual: '',
      ),

      // Besok
      EconomicEvent(
        title: 'Non-Farm Employment Change (NFP)',
        country: 'USD',
        date: today.add(const Duration(days: 1, hours: 19, minutes: 30)),
        impact: 'High',
        forecast: '165K',
        previous: '142K',
        actual: '',
      ),
      EconomicEvent(
        title: 'Unemployment Rate (Tingkat Pengangguran)',
        country: 'USD',
        date: today.add(const Duration(days: 1, hours: 19, minutes: 30)),
        impact: 'High',
        forecast: '4.2%',
        previous: '4.3%',
        actual: '',
      ),
      EconomicEvent(
        title: 'Employment Change',
        country: 'CAD',
        date: today.add(const Duration(days: 1, hours: 19, minutes: 30)),
        impact: 'High',
        forecast: '26.4K',
        previous: '-2.8K',
        actual: '',
      ),
      EconomicEvent(
        title: 'Consumer Confidence',
        country: 'EUR',
        date: today.add(const Duration(days: 1, hours: 21, minutes: 0)),
        impact: 'Low',
        forecast: '-13.2',
        previous: '-13.4',
        actual: '',
      ),

      // Kemarin
      EconomicEvent(
        title: 'FOMC Statement & Federal Funds Rate',
        country: 'USD',
        date: today.subtract(const Duration(days: 1, hours: -1)), // Kemarin dini hari
        impact: 'High',
        forecast: '5.00%',
        previous: '5.50%',
        actual: '5.00%',
      ),
      EconomicEvent(
        title: 'CPI y/y',
        country: 'GBP',
        date: today.subtract(const Duration(days: 1, hours: -13)),
        impact: 'High',
        forecast: '2.2%',
        previous: '2.2%',
        actual: '2.2%',
      ),
      EconomicEvent(
        title: 'GDP q/q',
        country: 'NZD',
        date: today.subtract(const Duration(days: 1, hours: -5)),
        impact: 'Medium',
        forecast: '-0.4%',
        previous: '0.2%',
        actual: '-0.2%',
      ),
    ];
  }
}
