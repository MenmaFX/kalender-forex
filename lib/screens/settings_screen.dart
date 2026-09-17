import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_background_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final availableAssets = [
      {'code': 'XAU/USD', 'desc': 'Emas Dunia (Spot Gold)'},
      {'code': 'BTC/USD', 'desc': 'Bitcoin (Crypto Leader)'},
      {'code': 'EUR/USD', 'desc': 'Euro vs Dolar AS'},
      {'code': 'GBP/USD', 'desc': 'Poundsterling vs Dolar AS'},
      {'code': 'USD/JPY', 'desc': 'Dolar AS vs Yen Jepang'},
      {'code': 'AUD/USD', 'desc': 'Dolar Australia vs USD'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Pengaturan & Tampilan',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        children: [
          // ==========================================
          // 1. OPSI MODE TEMA & TAMPILAN
          // ==========================================
          _buildSectionHeader('TEMA & TAMPILAN APLIKASI'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                _buildThemeRadioTile(
                  context: context,
                  title: 'Mode Gelap Default (Dark Theme)',
                  subtitle: 'Tema gelap khas Myfxbook (#121418)',
                  value: ThemeModeOption.darkDefault,
                  groupValue: settings.themeModeOption,
                  onChanged: (val) {
                    if (val != null) settings.setThemeModeOption(val);
                  },
                ),
                _buildThemeRadioTile(
                  context: context,
                  title: 'Mode Terang Default (Light Theme)',
                  subtitle: 'Tampilan bersih, kontras tinggi & rapi',
                  value: ThemeModeOption.lightDefault,
                  groupValue: settings.themeModeOption,
                  onChanged: (val) {
                    if (val != null) settings.setThemeModeOption(val);
                  },
                ),
                _buildThemeRadioTile(
                  context: context,
                  title: 'Mode Gelap dengan Custom Background (Dark Glass)',
                  subtitle: 'Efek frosted glass gelap di atas wallpaper galeri Anda',
                  value: ThemeModeOption.darkGlassCustom,
                  groupValue: settings.themeModeOption,
                  onChanged: (val) {
                    if (val != null) settings.setThemeModeOption(val);
                  },
                ),
                _buildThemeRadioTile(
                  context: context,
                  title: 'Mode Terang dengan Custom Background (Light Glass)',
                  subtitle: 'Efek frosted glass terang di atas wallpaper galeri Anda',
                  value: ThemeModeOption.lightGlassCustom,
                  groupValue: settings.themeModeOption,
                  onChanged: (val) {
                    if (val != null) settings.setThemeModeOption(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ==========================================
          // 2. ATUR WALLPAPER LATAR (PORTRAIT & LANDSCAPE)
          // ==========================================
          _buildSectionHeader('ATUR WALLPAPER LATAR DARI GALERI'),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sesuaikan wallpaper latar belakang saat HP dalam orientasi tegak (Portrait 9:16) maupun miring (Landscape 16:9) dengan fitur potong/crop manual yang presisi.',
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
                  title: 'Wallpaper Portrait (Mode Tegak 9:16)',
                  imagePath: settings.portraitWallpaperPath,
                  onPick: () async {
                    final success = await settings.pickAndCropPortraitWallpaper(context);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Wallpaper Portrait (9:16) berhasil dipasang!'),
                          backgroundColor: Color(0xFF181B20),
                        ),
                      );
                    }
                  },
                  onDelete: () => settings.removeWallpaper(isPortrait: true),
                ),

                const Divider(height: 24),

                // Baris Wallpaper Landscape (16:9)
                _buildWallpaperPickerRow(
                  context: context,
                  title: 'Wallpaper Landscape (Mode Miring 16:9)',
                  imagePath: settings.landscapeWallpaperPath,
                  onPick: () async {
                    final success = await settings.pickAndCropLandscapeWallpaper(context);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Wallpaper Landscape (16:9) berhasil dipasang!'),
                          backgroundColor: Color(0xFF181B20),
                        ),
                      );
                    }
                  },
                  onDelete: () => settings.removeWallpaper(isPortrait: false),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ==========================================
          // 3. PREFERENSI NOTIFIKASI & BAHASA
          // ==========================================
          _buildSectionHeader('PREFERENSI SISTEM'),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Bahasa Aplikasi',
                    style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    settings.language == 'id' ? 'Bahasa Indonesia' : 'English',
                    style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey),
                  ),
                  trailing: DropdownButton<String>(
                    value: settings.language,
                    underline: const SizedBox(),
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
                    'Pengingat Pra-Rilis Berita',
                    style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Notifikasi berbunyi ${settings.alertMinutesBefore} menit sebelum data rilis',
                    style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey),
                  ),
                  trailing: DropdownButton<int>(
                    value: settings.alertMinutesBefore,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 Menit')),
                      DropdownMenuItem(value: 15, child: Text('15 Menit')),
                      DropdownMenuItem(value: 30, child: Text('30 Menit')),
                    ],
                    onChanged: (val) {
                      if (val != null) settings.setAlertMinutes(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ==========================================
          // 4. PASANGAN ASET FAVORIT
          // ==========================================
          _buildSectionHeader('PASANGAN ASET FAVORIT'),
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
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  subtitle: Text(
                    desc,
                    style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey),
                  ),
                  value: isChecked,
                  onChanged: (_) => settings.toggleFavoriteAsset(code),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          // ==========================================
          // 5. KAMUS RAMAH PEMULA
          // ==========================================
          _buildSectionHeader('KAMUS RAMAH PEMULA (GLOSARIUM)'),
          _buildGlossaryCard(
            title: '1. Apa itu "Aktual" (Akt.)?',
            desc: 'Angka resmi yang baru saja dirilis oleh pemerintah atau lembaga statistik keuangan hari ini.',
          ),
          _buildGlossaryCard(
            title: '2. Apa itu "Konsensus / Ramalan" (Kons.)?',
            desc: 'Perkiraan rata-rata analis dan ekonom ternama dunia sebelum data dirilis ke publik.',
          ),
          _buildGlossaryCard(
            title: '3. Apa itu "Sebelumnya" (Sebl.)?',
            desc: 'Angka data rilis resmi pada periode bulan atau kuartal terdahulu.',
          ),
          _buildGlossaryCard(
            title: '4. Arti Warna Indikator Dampak',
            desc: '🔴 Merah (Tinggi): Pasar bergerak volatil puluhan hingga ratusan pips.\n🟡 Oranye (Sedang): Pergerakan harga wajar terukur.\n🟢 Hijau (Rendah): Pengaruh fluktuasi harga relatif minim.',
          ),
          _buildGlossaryCard(
            title: '5. Sinyal Emas (XAU/USD) & Bitcoin (BTC/USD)',
            desc: 'Emas dan Bitcoin diperdagangkan berpasangan terhadap Dolar AS (USD):\n• Data USD Lebih Kuat dari Konsensus ➔ Dolar menguat perkasa ➔ Emas & Kripto tertekan (Saran: SELL).\n• Data USD Lebih Lemah dari Konsensus ➔ Dolar melemah lesu ➔ Emas & Kripto berpeluang reli naik (Saran: BUY).',
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
    required ValueChanged<ThemeModeOption?> onChanged,
  }) {
    return RadioListTile<ThemeModeOption>(
      activeColor: AppTheme.myfxOrange,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
      ),
    );
  }

  Widget _buildWallpaperPickerRow({
    required BuildContext context,
    required String title,
    required String? imagePath,
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
            border: Border.all(color: const Color(0xFF38404D), width: 1),
            color: const Color(0xFF1E222A),
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                )
              : const Center(
                  child: Icon(Icons.image_outlined, color: Colors.grey, size: 24),
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
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
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
                    icon: const Icon(Icons.crop, size: 14),
                    label: Text(hasImage ? 'Ganti' : 'Pilih & Potong'),
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
                      label: const Text('Hapus'),
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

  Widget _buildGlossaryCard({required String title, required String desc}) {
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
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: const Color(0xFFCCCCCC),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
