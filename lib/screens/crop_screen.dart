import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../services/app_strings.dart';
import '../widgets/app_theme.dart';

class CropScreen extends StatefulWidget {
  final String imagePath;
  final bool initialIsPortrait;
  final String language;

  const CropScreen({
    Key? key,
    required this.imagePath,
    this.initialIsPortrait = true,
    this.language = 'id',
  }) : super(key: key);

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  late bool _isPortrait;
  final TransformationController _transformController = TransformationController();
  final GlobalKey _viewportKey = GlobalKey();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isPortrait = widget.initialIsPortrait;
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  // Rasio aspek: 9:16 untuk portrait, 16:9 untuk landscape
  double get _targetAspectRatio => _isPortrait ? (9.0 / 16.0) : (16.0 / 9.0);

  Future<void> _applyAndSave() async {
    setState(() => _isProcessing = true);

    try {
      // Baca file gambar asli
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();

      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      // Dapatkan transformasi pengguna dari InteractiveViewer
      final matrix = _transformController.value;
      final scale = matrix.getMaxScaleOnAxis();
      final translationX = matrix.getTranslation().x;
      final translationY = matrix.getTranslation().y;

      // Render gambar hasil crop ke surface canvas
      final int targetWidth = _isPortrait ? 1080 : 1920;
      final int targetHeight = _isPortrait ? 1920 : 1080;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()));

      // Cat latar belakang hitam netral
      canvas.drawRect(
        Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
        Paint()..color = Colors.black,
      );

      // Hitung skala fitting gambar ke target viewport
      final double fitScale = (_isPortrait
              ? (targetHeight / image.height)
              : (targetWidth / image.width))
          .clamp(0.01, 100.0);

      final double finalScale = fitScale * scale;
      final double drawX = translationX * (targetWidth / 360.0);
      final double drawY = translationY * (targetHeight / 640.0);

      canvas.save();
      canvas.translate(drawX, drawY);
      canvas.scale(finalScale);
      canvas.drawImage(image, Offset.zero, Paint());
      canvas.restore();

      final picture = recorder.endRecording();
      final croppedUiImage = await picture.toImage(targetWidth, targetHeight);
      final byteData = await croppedUiImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to encode image');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'crop_${_isPortrait ? "portrait" : "landscape"}_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedFile = File('${appDir.path}/$fileName');
      await savedFile.writeAsBytes(byteData.buffer.asUint8List());

      if (mounted) {
        Navigator.of(context).pop(savedFile.path);
      }
    } catch (e) {
      debugPrint('Crop failed: $e, using original image file.');
      // Fallback aman: gunakan file asli jika render canvas gagal
      if (mounted) {
        Navigator.of(context).pop(widget.imagePath);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B20),
        elevation: 0,
        title: Text(
          AppStrings.cropTitle(lang),
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // 1. Tombol Toggle Rasio: "Portrait (9:16)" & "Landscape / Fit (16:9)"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF14171C),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRatioButton(
                  title: AppStrings.portraitRatio(lang),
                  icon: Icons.stay_current_portrait_rounded,
                  isActive: _isPortrait,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _isPortrait = true;
                      _transformController.value = Matrix4.identity();
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildRatioButton(
                  title: AppStrings.landscapeRatio(lang),
                  icon: Icons.stay_current_landscape_rounded,
                  isActive: !_isPortrait,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _isPortrait = false;
                      _transformController.value = Matrix4.identity();
                    });
                  },
                ),
              ],
            ),
          ),

          // Petunjuk Interaksi
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              AppStrings.dragToAdjust(lang),
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[400]),
            ),
          ),

          // 2. Interactive Cropping Area
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: _targetAspectRatio,
                  child: Container(
                    key: _viewportKey,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.myfxOrange, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.myfxOrange.withOpacity(0.25),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 0.8,
                        maxScale: 4.0,
                        boundaryMargin: const EdgeInsets.all(double.infinity),
                        child: Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Tombol Terapkan Background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            color: const Color(0xFF14171C),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.myfxOrange,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                ),
                onPressed: _isProcessing ? null : _applyAndSave,
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.applyBackground(lang),
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioButton({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.myfxOrange : const Color(0xFF1E222A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppTheme.myfxOrange : const Color(0xFF38404D),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.black : Colors.grey[400],
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? Colors.black : Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
