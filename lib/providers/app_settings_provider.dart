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
  List<String> _favoriteAssets = ['XAU/USD', 'BTC/USD', 'EUR/USD', 'GBP/USD'];
  Set<String> _impactFilter = {'High', 'Medium', 'Low'};
  Set<String> _currencyFilter = {'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'NZD'};

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
  List<String> get favoriteAssets => _favoriteAssets;
  Set<String> get impactFilter => _impactFilter;
  Set<String> get currencyFilter => _currencyFilter;

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
}
