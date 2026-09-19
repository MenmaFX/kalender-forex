import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/economic_event.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';

enum QuickDateTab { yesterday, today, tomorrow, thisWeek, nextWeek, custom }

class CalendarProvider with ChangeNotifier {
  final CalendarService _service = CalendarService();
  final NotificationService _notificationService = NotificationService();
  Timer? _realtimeTimer;

  List<EconomicEvent> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  QuickDateTab _selectedTab = QuickDateTab.today;
  DateTime _selectedDate = DateTime.now();
  DateTimeRange? _customDateRange;

  List<EconomicEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  QuickDateTab get selectedTab => _selectedTab;
  DateTime get selectedDate => _selectedDate;
  DateTimeRange? get customDateRange => _customDateRange;

  final Set<int> _notifiedEventIds = {};

  CalendarProvider() {
    loadEvents();
    // Real-time automatic background polling every 30 seconds for live releases & alerts
    _realtimeTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkAndDispatchRealtimeAlerts();
      _silentRefresh();
    });
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }

  // Monitor waktu nyata: membunyikan notifikasi otomatis pra-rilis & sinyal rilis saat waktu tiba
  Future<void> _checkAndDispatchRealtimeAlerts() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    final notifImpacts = (prefs.getStringList('notif_impact_filters') ?? ['High', 'Medium', 'Low']).toSet();
    final notifCurrencies = (prefs.getStringList('notif_currency_filters') ?? ['USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'NZD']).toSet();
    final soundEnabled = prefs.getBool('notif_sound_enabled') ?? true;
    final vibrationEnabled = prefs.getBool('notif_vibration_enabled') ?? true;

    for (final event in _events) {
      final currency = event.country.toUpperCase();
      final impact = event.impact;

      // Cek apakah mata uang atau impact masuk dalam filter notifikasi aktif
      if (!notifCurrencies.contains(currency)) continue;
      if (!notifImpacts.contains(impact)) continue;

      final diffMinutes = event.date.difference(now).inMinutes;

      // 1. Notifikasi Pra-Rilis Otomatis:
      // Hanya kirim jika berita belum keluar (actual kosong) dan jadwalnya masih di masa depan
      if (event.actual.isEmpty && event.date.isAfter(now) && diffMinutes >= 0 && diffMinutes <= 15) {
        final alertKey = event.title.hashCode ^ event.date.day;
        if (!_notifiedEventIds.contains(alertKey)) {
          _notifiedEventIds.add(alertKey);
          await _notificationService.schedulePreReleaseReminder(
            event: event,
            minutesBefore: diffMinutes == 0 ? 1 : diffMinutes,
            soundEnabled: soundEnabled,
            vibrationEnabled: vibrationEnabled,
          );
        }
      }

      // 2. Notifikasi Sinyal Pasca-Rilis Otomatis (ketika aktual terisi dan rilis baru saja terjadi)
      if (event.actual.isNotEmpty) {
        final signalKey = (event.title + '_signal').hashCode ^ event.date.day;
        if (!_notifiedEventIds.contains(signalKey)) {
          _notifiedEventIds.add(signalKey);
          await _notificationService.sendPostReleaseSignal(
            event: event,
            soundEnabled: soundEnabled,
            vibrationEnabled: vibrationEnabled,
          );
        }
      }
    }
  }

  Future<void> _silentRefresh() async {
    try {
      final updated = await _service.fetchCalendarEvents();
      if (updated.isNotEmpty) {
        updated.sort((a, b) => a.date.compareTo(b.date));
        _events = updated;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _service.fetchCalendarEvents();
      _events.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      _errorMessage = 'Gagal memuat kalender: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Alias untuk kompatibilitas nama pemanggilan method
  Future<void> fetchEvents() => loadEvents();
  Future<void> getEvents() => loadEvents();
  Future<void> refresh() => loadEvents();

  void setQuickTab(QuickDateTab tab) {
    _selectedTab = tab;
    final now = DateTime.now();
    switch (tab) {
      case QuickDateTab.yesterday:
        _selectedDate = now.subtract(const Duration(days: 1));
        break;
      case QuickDateTab.today:
        _selectedDate = now;
        break;
      case QuickDateTab.tomorrow:
        _selectedDate = now.add(const Duration(days: 1));
        break;
      case QuickDateTab.thisWeek:
      case QuickDateTab.nextWeek:
      case QuickDateTab.custom:
        break;
    }
    notifyListeners();
  }

  void setCustomRange(DateTimeRange range) {
    _selectedTab = QuickDateTab.custom;
    _customDateRange = range;
    notifyListeners();
  }

  void shiftDate(int days) {
    if (_selectedTab == QuickDateTab.thisWeek || _selectedTab == QuickDateTab.nextWeek) {
      // Jika sedang di tab minggu, geser 7 hari
      _selectedDate = _selectedDate.add(Duration(days: days * 7));
    } else {
      _selectedDate = _selectedDate.add(Duration(days: days));
    }
    _customDateRange = null;
    _selectedTab = QuickDateTab.custom;
    notifyListeners();
  }

  // Filter Event Berdasarkan Tanggal & Preferensi Pengguna
  List<EconomicEvent> getFilteredEvents({
    required Set<String> impactFilters,
    required Set<String> currencyFilters,
  }) {
    return _events.where((event) {
      // 1. Filter Dampak
      if (!impactFilters.contains(event.impact)) {
        return false;
      }

      // 2. Filter Mata Uang
      if (currencyFilters.isNotEmpty && !currencyFilters.contains(event.country.toUpperCase())) {
        return false;
      }

      // 3. Filter Waktu/Tanggal
      final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      switch (_selectedTab) {
        case QuickDateTab.yesterday:
          final yest = today.subtract(const Duration(days: 1));
          return eventDate.isAtSameMomentAs(yest);

        case QuickDateTab.today:
          return eventDate.isAtSameMomentAs(today);

        case QuickDateTab.tomorrow:
          final tomo = today.add(const Duration(days: 1));
          return eventDate.isAtSameMomentAs(tomo);

        case QuickDateTab.thisWeek:
          // Dari Senin sampai Minggu minggu ini
          final monday = today.subtract(Duration(days: today.weekday - 1));
          final sunday = monday.add(const Duration(days: 6));
          return !eventDate.isBefore(monday) && !eventDate.isAfter(sunday);

        case QuickDateTab.nextWeek:
          final nextMonday = today.add(Duration(days: 8 - today.weekday));
          final nextSunday = nextMonday.add(const Duration(days: 6));
          return !eventDate.isBefore(nextMonday) && !eventDate.isAfter(nextSunday);

        case QuickDateTab.custom:
          if (_customDateRange != null) {
            final start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
            final end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day);
            return !eventDate.isBefore(start) && !eventDate.isAfter(end);
          }
          final chosenDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
          return eventDate.isAtSameMomentAs(chosenDay);
      }
    }).toList();
  }

  // Pemicu Notifikasi Pengingat
  Future<void> triggerEventReminder(EconomicEvent event, int minutes) async {
    await _notificationService.schedulePreReleaseReminder(
      event: event,
      minutesBefore: minutes,
    );
  }

  // Pemicu Notifikasi Sinyal Emas / Kripto
  Future<void> triggerSignalAlert(EconomicEvent event, {bool isSimulation = false}) async {
    await _notificationService.sendPostReleaseSignal(event: event, isSimulation: isSimulation);
  }

  // Riwayat Masa Lalu
  List<HistoricalRelease> getHistoricalData(EconomicEvent event) {
    return _service.getHistoricalReleases(event);
  }

  String formattedActiveDateHeaderLocalized(String lang) {
    if (_selectedTab == QuickDateTab.thisWeek) {
      return lang == 'en' ? 'This Week' : 'Minggu Ini';
    } else if (_selectedTab == QuickDateTab.nextWeek) {
      return lang == 'en' ? 'Next Week' : 'Minggu Depan';
    } else if (_selectedTab == QuickDateTab.custom && _customDateRange != null) {
      final s = DateFormat('dd MMM yyyy', lang == 'en' ? 'en_US' : 'id_ID').format(_customDateRange!.start);
      final e = DateFormat('dd MMM yyyy', lang == 'en' ? 'en_US' : 'id_ID').format(_customDateRange!.end);
      return '$s - $e';
    }

    // Format Hari: "Thursday, September 17, 2026"
    return DateFormat('EEEE, MMMM d, yyyy', lang == 'en' ? 'en_US' : 'id_ID').format(_selectedDate);
  }

  String get formattedActiveDateHeader => formattedActiveDateHeaderLocalized('id');
}
