import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      // Request runtime permission for Android 13+ (POST_NOTIFICATIONS)
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Local notifications init exception (simulator/fallback mode): $e');
    }
  }

  // Notifikasi Pengingat Pra-Rilis Berita (Format BigTextStyle Modern)
  Future<void> schedulePreReleaseReminder({
    required EconomicEvent event,
    required int minutesBefore,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) async {
    final title = '⏰ [${event.country}] Rilis dalam $minutesBefore Menit';
    final summaryText = 'Pengingat Kalender Ekonomi';

    final bigText = StringBuffer();
    bigText.writeln('📊 ${event.title}');
    bigText.writeln('• Dampak Pasar : ${event.impact.toUpperCase()} IMPACT');
    bigText.writeln('• Konsensus     : ${event.forecast.isEmpty ? "-" : event.forecast} | Sebl: ${event.previous.isEmpty ? "-" : event.previous}');
    bigText.write('⚠️ Potensi lonjakan volatilitas pada pasangan ${event.country} & XAU/USD.');

    await _showNotification(
      id: event.title.hashCode,
      title: title,
      body: '${event.title} (${event.country}) rilis dlm $minutesBefore menit. Konsensus: ${event.forecast}',
      bigText: bigText.toString(),
      summaryText: summaryText,
      accentColor: const Color(0xFFFFA500),
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      payload: 'event_reminder:${event.title}',
    );
  }

  // Notifikasi Sinyal Pasca-Rilis XAU/USD & Valas (Format BigTextStyle Modern)
  Future<void> sendPostReleaseSignal({
    required EconomicEvent event,
    bool isSimulation = false,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) async {
    final country = event.country.toUpperCase();

    String signalTitle = '⚡ Sinyal Data Ekonomi: $country';
    String signalHeadline = '';
    Color accentColor = const Color(0xFFFFA500);

    // Dapatkan rekomendasi sinyal
    SignalRecommendation rec = event.signalRecommendation;

    // Jika sedang dalam simulasi tes dan data belum terisi, simulasikan sinyal rilis yang jelas
    if (rec == SignalRecommendation.notApplicable || isSimulation) {
      if (country == 'USD') {
        rec = SignalRecommendation.strongBuyGoldBtc;
      } else {
        rec = SignalRecommendation.buyCurrency;
      }
    }

    final bigText = StringBuffer();

    switch (rec) {
      case SignalRecommendation.strongSellGoldBtc:
        signalTitle = '🔴 SINYAL SELL XAU/USD & BTC!';
        signalHeadline = 'Aktual USD Menguat Perkasa Di Atas Konsensus';
        accentColor = const Color(0xFFD50000);
        bigText.writeln('📊 ${event.title} (USD)');
        bigText.writeln('• Aktual: ${event.actual.isEmpty ? "Lebih Tinggi" : event.actual} | Konsensus: ${event.forecast}');
        bigText.writeln('• Dolar menguat tajam. Emas & Kripto berpotensi tertekan turun.');
        bigText.write('🎯 Rekomendasi: Waspada Buy, prioritaskan aksi Sell Gold / Buy USD.');
        break;

      case SignalRecommendation.strongBuyGoldBtc:
        signalTitle = '🟢 SINYAL BUY XAU/USD & BTC!';
        signalHeadline = 'Aktual USD Melemah Di Bawah Konsensus';
        accentColor = const Color(0xFF00C853);
        bigText.writeln('📊 ${event.title} (USD)');
        bigText.writeln('• Aktual: ${event.actual.isEmpty ? "Lebih Rendah" : event.actual} | Konsensus: ${event.forecast}');
        bigText.writeln('• Dolar AS melemah. Emas (XAU/USD) & Bitcoin berpeluang melonjak naik.');
        bigText.write('🎯 Rekomendasi: Potensi reli bullish Emas & Kripto.');
        break;

      case SignalRecommendation.buyCurrency:
        signalTitle = '🟢 SINYAL BUY $country!';
        signalHeadline = 'Data Ekonomi $country Positif & Menguat';
        accentColor = const Color(0xFF00C853);
        bigText.writeln('📊 ${event.title} ($country)');
        bigText.writeln('• Aktual: ${event.actual.isEmpty ? "Solid" : event.actual} | Konsensus: ${event.forecast}');
        bigText.writeln('• Sentimen positif untuk mata uang $country.');
        bigText.write('🎯 Rekomendasi: Potensi penguatan pasangan $country.');
        break;

      case SignalRecommendation.sellCurrency:
        signalTitle = '🔴 SINYAL SELL $country!';
        signalHeadline = 'Data Ekonomi $country Melemah';
        accentColor = const Color(0xFFD50000);
        bigText.writeln('📊 ${event.title} ($country)');
        bigText.writeln('• Aktual: ${event.actual.isEmpty ? "Mengecewakan" : event.actual} | Konsensus: ${event.forecast}');
        bigText.writeln('• Sentimen negatif menekan mata uang $country.');
        bigText.write('🎯 Rekomendasi: Waspada penurunan nilai $country.');
        break;

      case SignalRecommendation.neutral:
        signalTitle = '⚖️ Data $country Sesuai Ekspektasi';
        signalHeadline = 'Pasar Cenderung Stabil & Netral';
        accentColor = const Color(0xFF78909C);
        bigText.writeln('📊 ${event.title} ($country)');
        bigText.writeln('• Aktual: ${event.actual} | Konsensus: ${event.forecast}');
        bigText.writeln('• Data sejalan dengan ekspektasi analis pasar.');
        bigText.write('🎯 Rekomendasi: Wait & See, hindari entry agresif.');
        break;

      case SignalRecommendation.notApplicable:
        return;
    }

    await _showNotification(
      id: (event.title + '_signal').hashCode,
      title: signalTitle,
      body: '$signalHeadline | ${event.title}',
      bigText: bigText.toString(),
      summaryText: 'Sinyal FX Impact',
      accentColor: accentColor,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      payload: 'signal:${event.title}',
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String bigText,
    required String summaryText,
    required Color accentColor,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? payload,
  }) async {
    debugPrint('🔔 [NOTIFICATION DISPATCHED] ID: $id | $title');

    try {
      // Baca preferensi suara & getar dari SharedPreferences jika tidak dispesifikasikan langsung
      final prefs = await SharedPreferences.getInstance();
      final bool playSound = soundEnabled ?? (prefs.getBool('notif_sound_enabled') ?? true);
      final bool enableVibration = vibrationEnabled ?? (prefs.getBool('notif_vibration_enabled') ?? true);

      final channelId = playSound ? 'fx_impact_sound_channel' : 'fx_impact_silent_channel';
      final channelName = playSound ? 'Kalender & Sinyal Forex (Bersuara)' : 'Kalender & Sinyal Forex (Hening)';

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Pemberitahuan rilis data kalender ekonomi & sinyal trading forex',
        importance: playSound ? Importance.max : Importance.high,
        priority: Priority.high,
        playSound: playSound,
        enableVibration: enableVibration,
        vibrationPattern: enableVibration ? Int64List.fromList([0, 250, 150, 250]) : null,
        color: accentColor,
        styleInformation: BigTextStyleInformation(
          bigText,
          htmlFormatBigText: false,
          contentTitle: title,
          htmlFormatContentTitle: false,
          summaryText: summaryText,
          htmlFormatSummaryText: false,
        ),
        groupKey: 'com.myfxbook.fxcalendar.ALERTS',
        setAsGroupSummary: false,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: playSound,
        ),
      );

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
