import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/economic_event.dart';
import '../services/notification_service.dart';
import '../providers/app_settings_provider.dart';
import '../services/app_strings.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_background_scaffold.dart';
import 'crop_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _handlePickAndCrop(BuildContext context, AppSettingsProvider settings, bool isPortrait) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 98,
      );

      if (picked == null || !context.mounted) return;

      final croppedPath = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => CropScreen(
            imagePath: picked.path,
            initialIsPortrait: isPortrait,
            language: settings.language,
          ),
        ),
      );

      if (croppedPath != null && context.mounted) {
        await settings.setCroppedWallpaper(
          filePath: croppedPath,
          isPortrait: isPortrait,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.wallpaperApplied(
                  settings.language,
                  isPortrait ? 'Portrait' : 'Landscape',
                ),
              ),
              backgroundColor: const Color(0xFF181B20),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking or cropping image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final lang = settings.language;

    final availableAssets = [
      {'code': 'XAU/USD', 'desc': lang == 'en' ? 'Spot Gold (Global Commodity)' : 'Emas Dunia (Spot Gold)'},
      {'code': 'BTC/USD', 'desc': lang == 'en' ? 'Bitcoin (Crypto Leader)' : 'Bitcoin (Crypto Leader)'},
      {'code': 'EUR/USD', 'desc': lang == 'en' ? 'Euro vs US Dollar' : 'Euro vs Dolar AS'},
      {'code': 'GBP/USD', 'desc': lang == 'en' ? 'British Pound vs US Dollar' : 'Poundsterling vs Dolar AS'},
      {'code': 'USD/JPY', 'desc': lang == 'en' ? 'US Dollar vs Japanese Yen' : 'Dolar AS vs Yen Jepang'},
      {'code': 'AUD/USD', 'desc': lang == 'en' ? 'Australian Dollar vs USD' : 'Dolar Australia vs USD'},
    ];

    final hasCustomBg = settings.hasCustomBackground;

    return CustomBackgroundScaffold(
      appBar: AppBar(
        backgroundColor: hasCustomBg
            ? (isDark ? const Color(0xB3181B22) : const Color(0xCCFFFFFF))
            : (isDark ? AppTheme.myfxHeaderDark : Colors.white),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          AppStrings.settingsTitle(lang),
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        children: [
          // ==========================================
          // 1. OPSI MODE TEMA & TAMPILAN
          // ==========================================
          _buildSectionHeader(AppStrings.themeSection(lang)),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                _buildThemeRadioTile(
                  context: context,
                  title: AppStrings.darkDefaultTitle(lang),
                  subtitle: AppStrings.darkDefaultDesc(lang),
                  value: ThemeModeOption.darkDefault,
                  groupValue: settings.themeModeOption,
                  isDark: isDark,
                  onChanged: (val) {
                    if (val != null) settings.setThemeModeOption(val);
                  },
                ),
                _buildThemeRadioTile(
                  context: context,
                  title: AppStrings.lightDefaultTitle(lang),
                  subtitle: AppStrings.lightDefaultDesc(lang),
                  value: ThemeModeOption.lightDefault,
                  groupValue: settings.themeModeOption,
                  isDark: isDark,
                  onChanged: (val) {
                    if (val != null) settings.setThemeModeOption(val);
                  },
                ),
                _buildThemeRadioTile(
                  context: context,
                  title: AppStrings.darkGlassTitle(lang),
                  subtitle: AppStrings.darkGlassDesc(lang),
                  value: ThemeModeOption.darkGlassCustom,
                  groupValue: settings.themeModeOption,
                  isDark: isDark,
                  onChanged: (val) {
                    if (val != null) settings.setThemeModeOption(val);
                  },
                ),
                _buildThemeRadioTile(
                  context: context,
                  title: AppStrings.lightGlassTitle(lang),
                  subtitle: AppStrings.lightGlassDesc(lang),
                  value: ThemeModeOption.lightGlassCustom,
                  groupValue: settings.themeModeOption,
                  isDark: isDark,
                  onChanged: (val) {
                    if (val != null) settings.setThemeModeOption(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ==========================================
          // 2. ATUR WALLPAPER LATAR DENGAN CROP INTERAKTIF
          // ==========================================
          _buildSectionHeader(AppStrings.wallpaperSection(lang)),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.wallpaperDesc(lang),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFB0B7C3) : const Color(0xFF555F6D),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Baris Wallpaper Portrait (9:16)
                _buildWallpaperPickerRow(
                  context: context,
                  title: AppStrings.portraitWallpaper(lang),
                  subtitle: 'Rasio 9:16 (Crop & Zoom interaktif)',
                  imagePath: settings.portraitWallpaperPath,
                  lang: lang,
                  isDark: isDark,
                  onPick: () => _handlePickAndCrop(context, settings, true),
                  onDelete: () => settings.removeWallpaper(isPortrait: true),
                ),

                const Divider(height: 24),

                // Baris Wallpaper Landscape (16:9)
                _buildWallpaperPickerRow(
                  context: context,
                  title: AppStrings.landscapeWallpaper(lang),
                  subtitle: 'Rasio 16:9 (Crop & Zoom interaktif)',
                  imagePath: settings.landscapeWallpaperPath,
                  lang: lang,
                  isDark: isDark,
                  onPick: () => _handlePickAndCrop(context, settings, false),
                  onDelete: () => settings.removeWallpaper(isPortrait: false),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ==========================================
          // 3. PREFERENSI SISTEM & MULTI-BAHASA
          // ==========================================
          _buildSectionHeader(AppStrings.systemSection(lang)),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AppStrings.appLanguage(lang),
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  subtitle: Text(
                    settings.language == 'id' ? 'Bahasa Indonesia' : 'English',
                    style: GoogleFonts.inter(fontSize: 11.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  trailing: DropdownButton<String>(
                    value: settings.language,
                    underline: const SizedBox(),
                    dropdownColor: isDark ? const Color(0xFF1E222A) : Colors.white,
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (val) {
                      if (val != null) settings.setLanguage(val);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AppStrings.reminderBefore(lang),
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  subtitle: Text(
                    AppStrings.reminderSubtitle(lang, settings.alertMinutesBefore),
                    style: GoogleFonts.inter(fontSize: 11.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  trailing: DropdownButton<int>(
                    value: settings.alertMinutesBefore,
                    underline: const SizedBox(),
                    dropdownColor: isDark ? const Color(0xFF1E222A) : Colors.white,
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    items: [
                      DropdownMenuItem(value: 5, child: Text(AppStrings.minutesSuffix(lang, 5))),
                      DropdownMenuItem(value: 15, child: Text(AppStrings.minutesSuffix(lang, 15))),
                      DropdownMenuItem(value: 30, child: Text(AppStrings.minutesSuffix(lang, 30))),
                    ],
                    onChanged: (val) {
                      if (val != null) settings.setAlertMinutes(val);
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.myfxOrange,
                  title: Text(
                    AppStrings.notifSoundTitle(lang),
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  subtitle: Text(
                    AppStrings.notifSoundSubtitle(lang),
                    style: GoogleFonts.inter(fontSize: 11.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  value: settings.notificationSoundEnabled,
                  onChanged: (val) {
                    settings.setNotificationSoundEnabled(val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.myfxOrange,
                  title: Text(
                    AppStrings.notifVibrateTitle(lang),
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  subtitle: Text(
                    AppStrings.notifVibrateSubtitle(lang),
                    style: GoogleFonts.inter(fontSize: 11.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  value: settings.notificationVibrationEnabled,
                  onChanged: (val) {
                    settings.setNotificationVibrationEnabled(val);
                  },
                ),
                const Divider(height: 1),

                // Volume Notifikasi Slider (bisa diatur pelan/kencang atau dimatikan via sound toggle)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                settings.notificationSoundEnabled
                                    ? (settings.notificationVolume > 0.5 ? Icons.volume_up_rounded : Icons.volume_down_rounded)
                                    : Icons.volume_off_rounded,
                                size: 18,
                                color: isDark ? Colors.white70 : const Color(0xFF555F6D),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.notifVolumeTitle(lang),
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            settings.notificationSoundEnabled
                                ? '${(settings.notificationVolume * 100).round()}%'
                                : (lang == 'en' ? 'Muted' : 'Mati'),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: settings.notificationSoundEnabled ? AppTheme.myfxOrange : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.myfxOrange,
                          inactiveTrackColor: isDark ? const Color(0xFF2E3542) : const Color(0xFFDDE3EA),
                          thumbColor: AppTheme.myfxOrange,
                          overlayColor: AppTheme.myfxOrange.withOpacity(0.2),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: settings.notificationVolume,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          onChanged: settings.notificationSoundEnabled
                              ? (val) => settings.setNotificationVolume(val)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Filter Dampak Notifikasi (High, Medium, Low)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.notifImpactSection(lang),
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark ? const Color(0xFFB0B7C3) : const Color(0xFF555F6D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.notifImpactSubtitle(lang),
                        style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildFilterChoiceChip(
                            label: 'High (Tinggi)',
                            color: const Color(0xFFEF4444),
                            isSelected: settings.notificationImpactFilter.contains('High'),
                            onSelected: () => settings.toggleNotificationImpactFilter('High'),
                            isDark: isDark,
                          ),
                          _buildFilterChoiceChip(
                            label: 'Medium (Sedang)',
                            color: const Color(0xFFF59E0B),
                            isSelected: settings.notificationImpactFilter.contains('Medium'),
                            onSelected: () => settings.toggleNotificationImpactFilter('Medium'),
                            isDark: isDark,
                          ),
                          _buildFilterChoiceChip(
                            label: 'Low (Rendah)',
                            color: const Color(0xFF10B981),
                            isSelected: settings.notificationImpactFilter.contains('Low'),
                            onSelected: () => settings.toggleNotificationImpactFilter('Low'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Filter Mata Uang Notifikasi (USD, EUR, GBP, JPY, dll)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.notifCurrencySection(lang),
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark ? const Color(0xFFB0B7C3) : const Color(0xFF555F6D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.notifCurrencySubtitle(lang),
                        style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ['USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'NZD'].map((curr) {
                          final isSelected = settings.notificationCurrencyFilter.contains(curr);
                          return FilterChip(
                            label: Text(
                              curr,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.black
                                    : (isDark ? Colors.white70 : const Color(0xFF475569)),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppTheme.myfxOrange,
                            backgroundColor: isDark ? const Color(0xFF1E222A) : const Color(0xFFF1F5F9),
                            checkmarkColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.myfxOrange
                                    : (isDark ? const Color(0xFF333B48) : const Color(0xFFCBD5E1)),
                              ),
                            ),
                            onSelected: (_) => settings.toggleNotificationCurrencyFilter(curr),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.myfxOrange,
                        side: const BorderSide(color: AppTheme.myfxOrange, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      icon: const Icon(Icons.notifications_active_rounded, size: 18),
                      label: Text(
                        AppStrings.testNotificationBtn(lang),
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () async {
                        final testEvent = EconomicEvent(
                          title: 'Non-Farm Employment Change',
                          country: 'USD',
                          date: DateTime.now().add(Duration(minutes: settings.alertMinutesBefore)),
                          impact: 'High',
                          forecast: '180K',
                          previous: '165K',
                          actual: '',
                        );
                        await NotificationService().schedulePreReleaseReminder(
                          event: testEvent,
                          minutesBefore: settings.alertMinutesBefore,
                          soundEnabled: settings.notificationSoundEnabled,
                          vibrationEnabled: settings.notificationVibrationEnabled,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF1E222A),
                              content: Text(
                                AppStrings.testNotificationSent(lang),
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ==========================================
          // 4. PASANGAN ASET FAVORIT
          // ==========================================
          _buildSectionHeader(AppStrings.favoriteSection(lang)),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: availableAssets.map((asset) {
                final code = asset['code']!;
                final desc = asset['desc']!;
                final isChecked = settings.favoriteAssets.contains(code);

                return CheckboxListTile(
                  activeColor: AppTheme.myfxOrange,
                  title: Text(
                    code,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  subtitle: Text(
                    desc,
                    style: GoogleFonts.inter(fontSize: 11.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  value: isChecked,
                  onChanged: (_) => settings.toggleFavoriteAsset(code),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          // ==========================================
          // 5. KAMUS RAMAH PEMULA (ADAPTIF WARNA TERANG/GELAP)
          // ==========================================
          _buildSectionHeader(AppStrings.glossarySection(lang)),
          _buildGlossaryCard(
            isDark: isDark,
            title: AppStrings.glossary1Title(lang),
            desc: AppStrings.glossary1Desc(lang),
          ),
          _buildGlossaryCard(
            isDark: isDark,
            title: AppStrings.glossary2Title(lang),
            desc: AppStrings.glossary2Desc(lang),
          ),
          _buildGlossaryCard(
            isDark: isDark,
            title: AppStrings.glossary3Title(lang),
            desc: AppStrings.glossary3Desc(lang),
          ),
          _buildGlossaryCard(
            isDark: isDark,
            title: AppStrings.glossary4Title(lang),
            desc: AppStrings.glossary4Desc(lang),
          ),
          _buildGlossaryCard(
            isDark: isDark,
            title: AppStrings.glossary5Title(lang),
            desc: AppStrings.glossary5Desc(lang),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'FX Impact • version 1.16.0',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTheme.myfxOrange,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildThemeRadioTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required ThemeModeOption value,
    required ThemeModeOption groupValue,
    required bool isDark,
    required ValueChanged<ThemeModeOption?> onChanged,
  }) {
    return RadioListTile<ThemeModeOption>(
      activeColor: AppTheme.myfxOrange,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
    );
  }

  Widget _buildWallpaperPickerRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String? imagePath,
    required String lang,
    required bool isDark,
    required VoidCallback onPick,
    required VoidCallback onDelete,
  }) {
    final bool hasImage = imagePath != null && File(imagePath).existsSync();

    return Row(
      children: [
        // Thumbnail Preview
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF38404D) : const Color(0xFFCFD8DC),
              width: 1,
            ),
            color: isDark ? const Color(0xFF1E222A) : const Color(0xFFECEFF1),
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    size: 24,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        // Title & Actions
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.myfxOrange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    onPressed: onPick,
                    icon: const Icon(Icons.crop_rotate_rounded, size: 14),
                    label: Text(hasImage ? AppStrings.changePhoto(lang) : AppStrings.choosePhoto(lang)),
                  ),
                  if (hasImage) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 14),
                      label: Text(AppStrings.deletePhoto(lang)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlossaryCard({
    required bool isDark,
    required String title,
    required String desc,
  }) {
    // KONTRAST TINGGI ADAPTIF: Hitam pekat #1A1A1A untuk Light Mode, Putih/abu terang untuk Dark Mode
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color descColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF2E3842);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: descColor,
                fontWeight: isDark ? FontWeight.w400 : FontWeight.w500,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChoiceChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onSelected,
    required bool isDark,
  }) {
    return FilterChip(
      avatar: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
              : (isDark ? Colors.white60 : const Color(0xFF64748B)),
        ),
      ),
      selected: isSelected,
      selectedColor: color.withValues(alpha: isDark ? 0.35 : 0.2),
      backgroundColor: isDark ? const Color(0xFF1E222A) : const Color(0xFFF1F5F9),
      checkmarkColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? color : (isDark ? const Color(0xFF333B48) : const Color(0xFFCBD5E1)),
          width: isSelected ? 1.2 : 0.8,
        ),
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
