import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate adaptive foreground icon', () async {
    final file = File('assets/icons/app_logo.png');
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final ui.Image srcImage = frame.image;

    final int canvasSize = 1024;
    // Safe zone rasio ~68%
    final int contentSize = 700;
    final double offset = (canvasSize - contentSize) / 2.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize.toDouble(), canvasSize.toDouble()));

    final srcRect = Rect.fromLTWH(0, 0, srcImage.width.toDouble(), srcImage.height.toDouble());
    final dstRect = Rect.fromLTWH(offset, offset, contentSize.toDouble(), contentSize.toDouble());
    final paint = Paint()..filterQuality = FilterQuality.high;

    canvas.drawImageRect(srcImage, srcRect, dstRect, paint);

    final picture = recorder.endRecording();
    final paddedImage = await picture.toImage(canvasSize, canvasSize);
    final byteData = await paddedImage.toByteData(format: ui.ImageByteFormat.png);

    expect(byteData, isNotNull);
    final outFile = File('assets/icons/app_logo_adaptive_fg.png');
    await outFile.writeAsBytes(byteData!.buffer.asUint8List());
    print('SUCCESS: Padded adaptive foreground icon written to assets/icons/app_logo_adaptive_fg.png');
  });
}

