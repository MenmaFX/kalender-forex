import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption {
  darkDefault, // Mode Gelap Default
  lightDefault, // Mode Terang Default
  darkGlassCustom, // Mode Gelap dengan Custom Background
  lightGlassCustom, // Mode Terang dengan Custom Background
}

class AppSettingsProvider with ChangeNotifier {
  ThemeModeOption _themeModeOption = ThemeModeOption.darkDefault;
  String _language = 'id'; // 'id' atau 'en'
  int _alertMinutesBefore = 15; // 5, 15, 30 menit
  bool _notificationSoundEnabled = true; // True = suara aktif, False = hening / mute
  bool _notificationVibrationEnabled = true; // True = getar aktif
  double _notificationVolume = 0.8; // 0.0 s/d 1.0
  List<String> _favoriteAssets = ['XAU/USD', 'BTC/USD', 'EUR/USD', 'GBP/USD'];
  Set<String> _impactFilter = {'High', 'Medium', 'Low'};
  Set<String> _currencyFilter = {'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'NZD'};

  // Filter Khusus untuk Notifikasi (User bisa pilih/centang Low, Med, High & Mata Uang mana yang memicu notifikasi)
  Set<String> _notificationImpactFilter = {'High', 'Medium', 'Low'};
  Set<String> _notificationCurrencyFilter = {'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'NZD'};

  // Path file background tersimpan
  String? _portraitWallpaperPath;
  String? _landscapeWallpaperPath;

  ThemeModeOption get themeModeOption => _themeModeOption;
  bool get isDarkMode =>
      _themeModeOption == ThemeModeOption.darkDefault ||
      _themeModeOption == ThemeModeOption.darkGlassCustom;
  bool get hasCustomBackground =>
      _themeModeOption == ThemeModeOption.darkGlassCustom ||
      _themeModeOption == ThemeModeOption.lightGlassCustom;

  String? get portraitWallpaperPath => _portraitWallpaperPath;
  String? get landscapeWallpaperPath => _landscapeWallpaperPath;
  String get language => _language;
  int get alertMinutesBefore => _alertMinutesBefore;
  bool get notificationSoundEnabled => _notificationSoundEnabled;
  bool get notificationVibrationEnabled => _notificationVibrationEnabled;
  double get notificationVolume => _notificationVolume;
  List<String> get favoriteAssets => _favoriteAssets;
  Set<String> get impactFilter => _impactFilter;
  Set<String> get currencyFilter => _currencyFilter;
  Set<String> get notificationImpactFilter => _notificationImpactFilter;
  Set<String> get notificationCurrencyFilter => _notificationCurrencyFilter;

  AppSettingsProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt('theme_mode_option_idx') ?? 0;
    if (themeIndex >= 0 && themeIndex < ThemeModeOption.values.length) {
      _themeModeOption = ThemeModeOption.values[themeIndex];
    } else {
      _themeModeOption = ThemeModeOption.darkDefault;
    }

    _portraitWallpaperPath = prefs.getString('wallpaper_portrait_path');
    _landscapeWallpaperPath = prefs.getString('wallpaper_landscape_path');

    // Validasi file apakah masih ada di storage
    if (_portraitWallpaperPath != null && !File(_portraitWallpaperPath!).existsSync()) {
      _portraitWallpaperPath = null;
    }
    if (_landscapeWallpaperPath != null && !File(_landscapeWallpaperPath!).existsSync()) {
      _landscapeWallpaperPath = null;
    }

    _language = prefs.getString('language') ?? 'id';
    _alertMinutesBefore = prefs.getInt('alert_minutes_before') ?? 15;
    _notificationSoundEnabled = prefs.getBool('notif_sound_enabled') ?? true;
    _notificationVibrationEnabled = prefs.getBool('notif_vibration_enabled') ?? true;
    _notificationVolume = prefs.getDouble('notif_volume') ?? 0.8;
    final favs = prefs.getStringList('favorite_assets');
    if (favs != null) _favoriteAssets = favs;
    final impacts = prefs.getStringList('impact_filters');
    if (impacts != null && impacts.isNotEmpty) {
      _impactFilter = impacts.toSet();
    } else {
      _impactFilter = {'High', 'Medium', 'Low'};
    }
    final currs = prefs.getStringList('currency_filters');
    if (currs != null && currs.isNotEmpty) {
      _currencyFilter = currs.toSet();
    } else {
      _currencyFilter = {'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'NZD'};
    }

    final notifImpacts = prefs.getStringList('notif_impact_filters');
    if (notifImpacts != null && notifImpacts.isNotEmpty) {
      _notificationImpactFilter = notifImpacts.toSet();
    } else {
      _notificationImpactFilter = {'High', 'Medium', 'Low'};
    }

    final notifCurrs = prefs.getStringList('notif_currency_filters');
    if (notifCurrs != null && notifCurrs.isNotEmpty) {
      _notificationCurrencyFilter = notifCurrs.toSet();
    } else {
      _notificationCurrencyFilter = {'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'NZD'};
    }

    notifyListeners();
  }

  Future<void> setThemeModeOption(ThemeModeOption option) async {
    _themeModeOption = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode_option_idx', option.index);
    notifyListeners();
  }

  Future<bool> pickPortraitWallpaper() async {
    return _pickWallpaper(isPortrait: true);
  }

  Future<bool> pickLandscapeWallpaper() async {
    return _pickWallpaper(isPortrait: false);
  }

  Future<bool> _pickWallpaper({required bool isPortrait}) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (pickedFile == null) return false;

      // Simpan file wallpaper permanen ke App Directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = isPortrait ? 'wallpaper_portrait.jpg' : 'wallpaper_landscape.jpg';
      final savedImage = File('${appDir.path}/$fileName');

      // Tulis file gambar
      final imageBytes = await pickedFile.readAsBytes();
      await savedImage.writeAsBytes(imageBytes);

      final prefs = await SharedPreferences.getInstance();
      if (isPortrait) {
        _portraitWallpaperPath = savedImage.path;
        await prefs.setString('wallpaper_portrait_path', savedImage.path);
      } else {
        _landscapeWallpaperPath = savedImage.path;
        await prefs.setString('wallpaper_landscape_path', savedImage.path);
      }

      // Jika user belum dalam mode custom, otomatis aktifkan ke Dark Glass
      if (!hasCustomBackground) {
        _themeModeOption = ThemeModeOption.darkGlassCustom;
        await prefs.setInt('theme_mode_option_idx', _themeModeOption.index);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error pick wallpaper image: $e');
      return false;
    }
  }

  Future<void> setCroppedWallpaper({
    required String filePath,
    required bool isPortrait,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (isPortrait) {
      _portraitWallpaperPath = filePath;
      await prefs.setString('wallpaper_portrait_path', filePath);
    } else {
      _landscapeWallpaperPath = filePath;
      await prefs.setString('wallpaper_landscape_path', filePath);
    }

    if (!hasCustomBackground) {
      _themeModeOption = ThemeModeOption.darkGlassCustom;
      await prefs.setInt('theme_mode_option_idx', _themeModeOption.index);
    }

    notifyListeners();
  }

  Future<void> removeWallpaper({required bool isPortrait}) async {
    final prefs = await SharedPreferences.getInstance();
    if (isPortrait) {
      if (_portraitWallpaperPath != null) {
        try {
          final file = File(_portraitWallpaperPath!);
          if (file.existsSync()) await file.delete();
        } catch (_) {}
      }
      _portraitWallpaperPath = null;
      await prefs.remove('wallpaper_portrait_path');
    } else {
      if (_landscapeWallpaperPath != null) {
        try {
          final file = File(_landscapeWallpaperPath!);
          if (file.existsSync()) await file.delete();
        } catch (_) {}
      }
      _landscapeWallpaperPath = null;
      await prefs.remove('wallpaper_landscape_path');
    }
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> setAlertMinutes(int minutes) async {
    _alertMinutesBefore = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('alert_minutes_before', minutes);
    notifyListeners();
  }

  Future<void> setNotificationSoundEnabled(bool enabled) async {
    _notificationSoundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_sound_enabled', enabled);
    notifyListeners();
  }

  Future<void> setNotificationVibrationEnabled(bool enabled) async {
    _notificationVibrationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_vibration_enabled', enabled);
    notifyListeners();
  }

  Future<void> setNotificationVolume(double volume) async {
    _notificationVolume = volume;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('notif_volume', volume);
    notifyListeners();
  }

  Future<void> toggleFavoriteAsset(String asset) async {
    if (_favoriteAssets.contains(asset)) {
      _favoriteAssets.remove(asset);
    } else {
      _favoriteAssets.add(asset);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_assets', _favoriteAssets);
    notifyListeners();
  }

  Future<void> toggleImpactFilter(String impact) async {
    if (_impactFilter.contains(impact)) {
      if (_impactFilter.length > 1) {
        _impactFilter.remove(impact);
      }
    } else {
      _impactFilter.add(impact);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('impact_filters', _impactFilter.toList());
    notifyListeners();
  }

  Future<void> toggleCurrencyFilter(String currency) async {
    if (_currencyFilter.contains(currency)) {
      if (_currencyFilter.length > 1) {
        _currencyFilter.remove(currency);
      }
    } else {
      _currencyFilter.add(currency);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('currency_filters', _currencyFilter.toList());
    notifyListeners();
  }

  Future<void> toggleNotificationImpactFilter(String impact) async {
    if (_notificationImpactFilter.contains(impact)) {
      if (_notificationImpactFilter.length > 1) {
        _notificationImpactFilter.remove(impact);
      }
    } else {
      _notificationImpactFilter.add(impact);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notif_impact_filters', _notificationImpactFilter.toList());
    notifyListeners();
  }

  Future<void> toggleNotificationCurrencyFilter(String currency) async {
    if (_notificationCurrencyFilter.contains(currency)) {
      if (_notificationCurrencyFilter.length > 1) {
        _notificationCurrencyFilter.remove(currency);
      }
    } else {
      _notificationCurrencyFilter.add(currency);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notif_currency_filters', _notificationCurrencyFilter.toList());
    notifyListeners();
  }
}
