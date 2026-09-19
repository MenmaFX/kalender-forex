import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import 'app_theme.dart';

class CustomBackgroundScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const CustomBackgroundScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final hasCustomBg = settings.hasCustomBackground;

    return OrientationBuilder(
      builder: (context, orientation) {
        String? activeImagePath;
        if (hasCustomBg) {
          if (orientation == Orientation.portrait) {
            activeImagePath = settings.portraitWallpaperPath ?? settings.landscapeWallpaperPath;
          } else {
            activeImagePath = settings.landscapeWallpaperPath ?? settings.portraitWallpaperPath;
          }
        }

        final bool hasValidImageFile = activeImagePath != null && File(activeImagePath).existsSync();

        return Scaffold(
          backgroundColor: backgroundColor ??
              (hasValidImageFile
                  ? Colors.transparent
                  : (isDark ? AppTheme.myfxDarkBg : const Color(0xFFF4F6F9))),
          appBar: appBar,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Layer Background Image murni jernih 100% (TANPA ImageFilter.blur & BackdropFilter)
              if (hasValidImageFile) ...[
                Image.file(
                  File(activeImagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                // Lapisan tint gradien lembut agar elemen di atasnya tetap terbaca tanpa buram
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0x660D0F13), // 40% subtle dark tint
                              const Color(0x8A121418), // 54% subtle dark tint
                            ]
                          : [
                              const Color(0x55FFFFFF), // 33% subtle light tint
                              const Color(0x7AFFFFFF), // 48% subtle light tint
                            ],
                    ),
                  ),
                ),
              ],

              // 2. Konten Aplikasi Utama
              SafeArea(
                bottom: false,
                child: body,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget Glass/Surface Card transparan dengan opacity ~0.85 (dark) dan ~0.90 (light) tanpa ImageFilter.blur
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 8.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final hasCustomBg = settings.hasCustomBackground;

    // Opacity ~0.85 untuk Dark Mode (0xD9) dan ~0.90 untuk Light Mode (0xE6)
    final Color cardBgColor = hasCustomBg
        ? (isDark ? const Color(0xD9181B22) : const Color(0xE6FFFFFF))
        : (isDark ? AppTheme.myfxCardDark : Colors.white);

    // Border kontras tipis untuk ketajaman kartu
    final Color borderColor = hasCustomBg
        ? (isDark ? const Color(0x40FFFFFF) : const Color(0x33000000))
        : (isDark ? const Color(0xFF262B33) : const Color(0xFFE2E6EC));

    final cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: 0.9,
        ),
        boxShadow: hasCustomBg
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(12.0),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppTheme.myfxOrange.withOpacity(0.15),
          highlightColor: AppTheme.myfxOrange.withOpacity(0.08),
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
