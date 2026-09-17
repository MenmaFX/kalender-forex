import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/economic_event.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';

enum QuickDateTab { yesterday, today, tomorrow, thisWeek, nextWeek, custom }

class CalendarProvider with ChangeNotifier {
  final CalendarService _service = CalendarService();
  final NotificationService _notificationService = NotificationService();

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

  CalendarProvider() {
    loadEvents();
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
  Future<void> triggerSignalAlert(EconomicEvent event) async {
    await _notificationService.sendPostReleaseSignal(event: event);
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
