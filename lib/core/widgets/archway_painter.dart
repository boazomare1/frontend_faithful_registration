import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'dart:math' as math;

class ArchwayPainter extends CustomPainter {
  final double animationValue;
  final double crescentScale;

  ArchwayPainter({required this.animationValue, this.crescentScale = 1.5});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Crescent paint with gold color
    final crescentPaint = Paint()
      ..color = Colors.amber.withOpacity(0.7) // Gold color, adjust if AppColors.accent is gold
      ..style = PaintingStyle.fill;

    // Draw rotating crescent moons
    final patternCenterY = height * 0.5;
    final crescentRadius = 20.0 * animationValue * crescentScale;

    for (int i = 0; i < 3; i++) {
      final offsetX = width / 2 - width * 0.25 + 30 + i * 60 * crescentScale;

      // Left crescent moon
      canvas.save();
      canvas.translate(offsetX, patternCenterY);
      canvas.rotate(animationValue * math.pi / 2);
      final outerCrescent = Path()
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: crescentRadius));
      final innerCrescent = Path()
        ..addOval(
            Rect.fromCircle(center: Offset(crescentRadius * 0.6, 0), radius: crescentRadius * 0.9));
      final crescentPath = Path.combine(PathOperation.difference, outerCrescent, innerCrescent);
      canvas.drawPath(crescentPath, crescentPaint);
      canvas.restore();

      // Right crescent moon (mirrored)
      canvas.save();
      canvas.translate(width / 2 + width * 0.25 - 30 - i * 60 * crescentScale, patternCenterY);
      canvas.rotate(-animationValue * math.pi / 2);
      final mirrorOuterCrescent = Path()
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: crescentRadius));
      final mirrorInnerCrescent = Path()
        ..addOval(
            Rect.fromCircle(center: Offset(-crescentRadius * 0.6, 0), radius: crescentRadius * 0.9));
      final mirrorCrescentPath = Path.combine(PathOperation.difference, mirrorOuterCrescent, mirrorInnerCrescent);
      canvas.drawPath(mirrorCrescentPath, crescentPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ArchwayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.crescentScale != crescentScale;
  }
}