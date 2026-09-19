import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calendar_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _shimmerProgress;
  late Animation<double> _pulseGlow;
  late Animation<double> _textFade;
  late Animation<double> _textSlide;

  @override
  void initState() {
    super.initState();

    // Durasi total animasi pembuka ~1.9 detik (tidak terlalu lama & tidak terlalu cepat)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    // 1. Logo pop-in elegan dari 0.75 ke 1.0 dengan Curve elastis lembut
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // 2. Logo fade in
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // 3. Efek denyut cahaya (Pulse Glow) ambient emas
    _pulseGlow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.15, end: 0.50)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.50, end: 0.25)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // 4. Efek rotasi sweep berkilau di sekitar logo (shimmer radar)
    _shimmerProgress = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    // 5. Teks judul & subtitle meluncur halus dari bawah dengan fade-in
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.75, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Navigasi mulus ke layar utama setelah durasi selesai
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToMain();
      }
    });
  }

  void _navigateToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const CalendarScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101216), // Dark Luxury Background
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stack Logo Mewah: Ambient Glow Ring + Full Unclipped Calendar Art + Radar Shimmer Halo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ambient Pulse Glow
                    Opacity(
                      opacity: _logoFade.value,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB300).withValues(alpha: _pulseGlow.value),
                              blurRadius: 50,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Rotating Light Shimmer Accent Halo (menambah kesan sinyal & waktu hidup)
                    Opacity(
                      opacity: _logoFade.value * 0.7,
                      child: Transform.rotate(
                        angle: _shimmerProgress.value,
                        child: Container(
                          width: 195,
                          height: 195,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFFFFD54F).withValues(alpha: 0.0),
                                const Color(0xFFFFB300).withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.65, 0.85, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Logo Asli Kalender (TIDAK DIPOTONG / TANPA CLIP CIRCLE YANG MEMOTONG BINGKAI)
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: Container(
                          width: 175,
                          height: 175,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/icons/app_logo.png',
                              fit: BoxFit.contain, // Memastikan gambar kalender utuh 100% tanpa kepotong
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF1E222A),
                                  child: const Icon(
                                    Icons.calendar_today_rounded,
                                    color: Color(0xFFFFB300),
                                    size: 72,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Teks FX Impact & Subtitle dengan Slide + Fade In
                Transform.translate(
                  offset: Offset(0, _textSlide.value),
                  child: Opacity(
                    opacity: _textFade.value,
                    child: Column(
                      children: [
                        Text(
                          'FX Impact',
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFB300),
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Economic Calendar & Signals',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9E9E9E),
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'Aplikasi By MenmaFX',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFFB300),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
