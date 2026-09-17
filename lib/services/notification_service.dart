import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/economic_event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Local notifications init exception (simulator/fallback mode): $e');
    }
  }

  // Notifikasi Pengingat Pra-Rilis Berita
  Future<void> schedulePreReleaseReminder({
    required EconomicEvent event,
    required int minutesBefore,
  }) async {
    final title = '⚠️ Pengingat Rilis Ekonomi (${event.country})';
    final body =
        '${event.title} rilis dalam $minutesBefore menit! Potensi gejolak pasar pada ${event.country} & XAU/USD.';

    await _showNotification(
      id: event.title.hashCode,
      title: title,
      body: body,
      payload: 'event_reminder:${event.title}',
    );
  }

  // Notifikasi Sinyal Pasca-Rilis XAU/USD & BTC/USD
  Future<void> sendPostReleaseSignal({
    required EconomicEvent event,
  }) async {
    if (event.country.toUpperCase() != 'USD') return;

    String signalTitle = '🔔 Sinyal Pasar USD Rilis!';
    String signalBody = '';

    switch (event.signalRecommendation) {
      case SignalRecommendation.strongSellGoldBtc:
        signalTitle = '🚨 SINYAL SELL XAU/USD & BTC!';
        signalBody =
            'Aktual USD (${event.actual}) > Ramalan (${event.forecast})! Dolar menguat perkasa. Emas & Kripto berpotensi koreksi tajam.';
        break;
      case SignalRecommendation.strongBuyGoldBtc:
        signalTitle = '🚀 SINYAL BUY XAU/USD & BTC!';
        signalBody =
            'Aktual USD (${event.actual}) < Ramalan (${event.forecast})! Dolar melemah. Emas & Kripto berpeluang melonjak naik.';
        break;
      case SignalRecommendation.neutral:
        signalTitle = '⚖️ Data USD Sesuai Ekspektasi';
        signalBody =
            'Aktual (${event.actual}) sesuai ramalan (${event.forecast}). Pasar stabil/netral. Saran: Wait & See.';
        break;
      case SignalRecommendation.notApplicable:
        return;
    }

    await _showNotification(
      id: (event.title + '_signal').hashCode,
      title: signalTitle,
      body: signalBody,
      payload: 'signal:${event.title}',
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('🔔 [NOTIFICATION DISPATCHED] ID: $id | $title | $body');

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'fx_calendar_channel',
        'Kalender Ekonomi & Sinyal Forex',
        channelDescription: 'Pemberitahuan rilis data ekonomi & rekomendasi trading emas/kripto',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Fallback notification log: $e');
    }
  }
}
