import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';

class CropScreen extends StatefulWidget {
  final String imagePath;
  final bool initialIsPortrait;
  final String language;

  const CropScreen({
    Key? key,
    required this.imagePath,
    this.initialIsPortrait = true,
    this.language = 'id',gh auth status
  }) : super(key: key);

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  late bool _isPortrait;
  ui.Image? _decodedImage;
  bool _isProcessing = false;

  // Nilai slider skala (1.0 s/d 3.0)
  double _zoomScale = 1.0;
  // Offset pan foto relatif terhadap tengah kotak crop
  Offset _panOffset = Offset.zero;

  // Nilai acuan saat gesture pinch/pan dimulai (agar mulus tanpa lompat)
  double _startZoomScale = 1.0;

  // Ukuran kotak pemotong (crop viewport)
  Size _cropBoxSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _isPortrait = widget.initialIsPortrait;
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _decodedImage = frame.image;
        });
      }
    } catch (e) {
      debugPrint('Error loading image for crop: $e');
    }
  }

  // Rasio aspek: 9:16 untuk portrait, 16:9 untuk landscape
  double get _targetAspectRatio => _isPortrait ? (9.0 / 16.0) : (16.0 / 9.0);

  // Ukuran dasar gambar saat disesuaikan agar mengisi kotak crop (Cover Base Fit)
  Size _getBaseCoverSize(Size cropBox) {
    if (_decodedImage == null) return cropBox;
    final imgW = _decodedImage!.width.toDouble();
    final imgH = _decodedImage!.height.toDouble();

    final scale = math.max(cropBox.width / imgW, cropBox.height / imgH);
    return Size(imgW * scale, imgH * scale);
  }

  // Batasi agar gambar tidak pernah bisa digeser keluar dari kotak crop (Tidak ada celah hitam!)
  Offset _clampOffset(Offset offset, Size cropBox, double scale) {
    final baseSize = _getBaseCoverSize(cropBox);
    final renderedW = baseSize.width * scale;
    final renderedH = baseSize.height * scale;

    final maxOffsetX = (renderedW - cropBox.width) / 2.0;
    final maxOffsetY = (renderedH - cropBox.height) / 2.0;

    final clampedX = offset.dx.clamp(-maxOffsetX, maxOffsetX);
    final clampedY = offset.dy.clamp(-maxOffsetY, maxOffsetY);

    return Offset(clampedX, clampedY);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _startZoomScale = _zoomScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_cropBoxSize == Size.zero) return;

    setState(() {
      // Perhitungan skala proporsional halus dari _startZoomScale tanpa lompatan eksponensial
      if (details.scale != 1.0) {
        _zoomScale = (_startZoomScale * details.scale).clamp(1.0, 3.0);
      }
      _panOffset = _clampOffset(_panOffset + details.focalPointDelta, _cropBoxSize, _zoomScale);
    });
  }

  void _resetCrop() {
    HapticFeedback.mediumImpact();
    setState(() {
      _zoomScale = 1.0;
      _panOffset = Offset.zero;
    });
  }

  Future<void> _applyAndSave() async {
    if (_decodedImage == null || _cropBoxSize == Size.zero) return;
    setState(() => _isProcessing = true);

    try {
      final image = _decodedImage!;
      final baseSize = _getBaseCoverSize(_cropBoxSize);
      final renderedW = baseSize.width * _zoomScale;
      final renderedH = baseSize.height * _zoomScale;

      // Rasio ukuran visual rendered terhadap piksel fisik gambar asli
      final ratio = image.width.toDouble() / renderedW;

      // Posisi tengah gambar terhadap kotak crop
      final imgCenterX = (renderedW / 2.0) - _panOffset.dx;
      final imgCenterY = (renderedH / 2.0) - _panOffset.dy;

      // Koordinat crop dalam skala visual
      final cropLeftVisual = imgCenterX - (_cropBoxSize.width / 2.0);
      final cropTopVisual = imgCenterY - (_cropBoxSize.height / 2.0);

      // Konversi ke koordinat piksel gambar asli
      final cropX = (cropLeftVisual * ratio).clamp(0.0, image.width.toDouble());
      final cropY = (cropTopVisual * ratio).clamp(0.0, image.height.toDouble());
      final cropW = (_cropBoxSize.width * ratio).clamp(1.0, image.width.toDouble() - cropX);
      final cropH = (_cropBoxSize.height * ratio).clamp(1.0, image.height.toDouble() - cropY);

      final int targetWidth = _isPortrait ? 1080 : 1920;
      final int targetHeight = _isPortrait ? 1920 : 1080;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()));

      final srcRect = Rect.fromLTWH(cropX, cropY, cropW, cropH);
      final dstRect = Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble());

      final paint = Paint()..filterQuality = FilterQuality.high;
      canvas.drawImageRect(image, srcRect, dstRect, paint);

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

      // Update state di AppSettingsProvider
      if (mounted) {
        final settings = Provider.of<AppSettingsProvider>(context, listen: false);
        await settings.setCroppedWallpaper(
          filePath: savedFile.path,
          isPortrait: _isPortrait,
        );

        Navigator.of(context).pop(savedFile.path);
      }
    } catch (e) {
      debugPrint('Crop error: $e');
      if (mounted) {
        final settings = Provider.of<AppSettingsProvider>(context, listen: false);
        await settings.setCroppedWallpaper(
          filePath: widget.imagePath,
          isPortrait: _isPortrait,
        );
        Navigator.of(context).pop(widget.imagePath);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _isPortrait ? 'Crop Portrait' : 'Crop Landscape';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14171C),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          titleText,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4A90E2),
                    ),
                  )
                : const Icon(Icons.check_rounded, color: Colors.white, size: 26),
            onPressed: _isProcessing ? null : _applyAndSave,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Area Crop Interaktif dengan Overlay Frame & Rule-of-Thirds Grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final maxH = constraints.maxHeight;

                // Hitung ukuran kotak crop maksimal yang muat di layar dengan rasio target
                double boxW = maxW - 32;
                double boxH = boxW / _targetAspectRatio;

                if (boxH > maxH - 32) {
                  boxH = maxH - 32;
                  boxW = boxH * _targetAspectRatio;
                }

                final cropSize = Size(boxW, boxH);
                _cropBoxSize = cropSize;
                _panOffset = _clampOffset(_panOffset, cropSize, _zoomScale);

                final baseSize = _getBaseCoverSize(cropSize);
                final renderedW = baseSize.width * _zoomScale;
                final renderedH = baseSize.height * _zoomScale;

                return Center(
                  child: Container(
                    width: boxW,
                    height: boxH,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Gambar yang bisa digeser dan dizoom
                        GestureDetector(
                          onScaleStart: _onScaleStart,
                          onScaleUpdate: _onScaleUpdate,
                          child: Container(
                            color: Colors.transparent,
                            width: boxW,
                            height: boxH,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: (boxW - renderedW) / 2.0 + _panOffset.dx,
                                  top: (boxH - renderedH) / 2.0 + _panOffset.dy,
                                  width: renderedW,
                                  height: renderedH,
                                  child: _decodedImage == null
                                      ? const Center(
                                          child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
                                        )
                                      : Image.file(
                                          File(widget.imagePath),
                                          fit: BoxFit.fill,
                                          errorBuilder: (_, __, ___) => const Center(
                                            child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Garis Bantu Grid 3x3 (Rule of Thirds Grid)
                        IgnorePointer(
                          child: CustomPaint(
                            size: Size(boxW, boxH),
                            painter: _GridPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Kontrol Bawah: Ruler Slider Skala & Tombol Aksi
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF14171C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indikator Persentase Zoom
                Text(
                  '${(_zoomScale * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(height: 8),

                // Slider Skala Modern dengan Indikator Penggaris (Ruler)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF4A90E2),
                    inactiveTrackColor: const Color(0xFF2C3440),
                    thumbColor: const Color(0xFF4A90E2),
                    overlayColor: const Color(0x334A90E2),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: _zoomScale,
                    min: 1.0,
                    max: 3.0,
                    onChanged: (val) {
                      setState(() {
                        _zoomScale = val;
                        if (_cropBoxSize != Size.zero) {
                          _panOffset = _clampOffset(_panOffset, _cropBoxSize, _zoomScale);
                        }
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Tombol Aksi: Reset & Scale Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: _resetCrop,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              'Reset',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.crop_free_rounded, color: Color(0xFF4A90E2), size: 22),
                          const SizedBox(height: 4),
                          Text(
                            'Scale',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF4A90E2)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Painter Garis Bantu 3x3 Pemotong Gambar
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Garis Vertikal 1 & 2
    final stepX = size.width / 3.0;
    canvas.drawLine(Offset(stepX, 0), Offset(stepX, size.height), paint);
    canvas.drawLine(Offset(stepX * 2, 0), Offset(stepX * 2, size.height), paint);

    // Garis Horizontal 1 & 2
    final stepY = size.height / 3.0;
    canvas.drawLine(Offset(0, stepY), Offset(size.width, stepY), paint);
    canvas.drawLine(Offset(0, stepY * 2), Offset(size.width, stepY * 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
