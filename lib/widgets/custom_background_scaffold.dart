import 'dart:io';
import 'dart:ui';
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
              // 1. Layer Background Image (Orientation Responsive Portrait/Landscape)
              if (hasValidImageFile) ...[
                Image.file(
                  File(activeImagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                // 2. Layer Overlay Frosted & Tint agar teks tetap 100% kontras dan terbaca
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                const Color(0xCC0D0F13), // 80% Dark Tint
                                const Color(0xE6121418), // 90% Dark Tint
                              ]
                            : [
                                const Color(0xCCFFFFFF), // 80% Light Tint
                                const Color(0xE6F4F6F9), // 90% Light Tint
                              ],
                      ),
                    ),
                  ),
                ),
              ],

              // 3. Konten Aplikasi Utama
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

// Widget Glass Card dengan BackdropFilter Blur dan Border Halus
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

    final cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: hasCustomBg
            ? (isDark ? const Color(0xBF181B22) : const Color(0xCCFFFFFF))
            : (isDark ? AppTheme.myfxCardDark : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: hasCustomBg
              ? (isDark ? const Color(0x2EFFFFFF) : const Color(0x22000000))
              : (isDark ? const Color(0xFF262B33) : const Color(0xFFE2E6EC)),
          width: 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: hasCustomBg ? 8.0 : 0.0,
            sigmaY: hasCustomBg ? 8.0 : 0.0,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(12.0),
            child: child,
          ),
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
