import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'dart:math' as math;

class ArchwayPainter extends CustomPainter {
  final double animationValue;

  ArchwayPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Masjid dome paint
    final domePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    // Door paint
    final doorPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    // Crescent paint
    final crescentPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Text paint for Arabic text in crescents
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'الرحمن', // Ar-Rahman
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 12,
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();

    // Draw dome (static, centered at top)
    final domeRadius = width * 0.2;
    canvas.drawCircle(
      Offset(width / 2, height * 0.15),
      domeRadius,
      domePaint,
    );

    // Draw dome base (rectangular structure below dome)
    canvas.drawRect(
      Rect.fromLTWH(
        width / 2 - domeRadius * 1.5,
        height * 0.15 + domeRadius * 0.8,
        domeRadius * 3,
        height * 0.4,
      ),
      domePaint,
    );

    // Animate doors sliding open
    final doorWidth = width * 0.25 * (1 - animationValue); // Doors shrink as they slide
    final doorHeight = height * 0.3;

    // Left door
    canvas.save();
    canvas.translate(-animationValue * width * 0.2, 0); // Slide left
    canvas.drawRect(
      Rect.fromLTWH(
        width / 2 - doorWidth,
        height * 0.25 + domeRadius,
        doorWidth,
        doorHeight,
      ),
      doorPaint,
    );
    canvas.restore();

    // Right door
    canvas.save();
    canvas.translate(animationValue * width * 0.2, 0); // Slide right
    canvas.drawRect(
      Rect.fromLTWH(
        width / 2,
        height * 0.25 + domeRadius,
        doorWidth,
        doorHeight,
      ),
      doorPaint,
    );
    canvas.restore();

    // Draw rotating crescents below doors
    final patternCenterY = height * 0.25 + domeRadius + doorHeight + 30;
    final crescentRadius = 20.0 * animationValue;

    for (int i = 0; i < 3; i++) {
      final offsetX = width / 2 - width * 0.25 + 30 + i * 60;

      // Left crescent
      canvas.save();
      canvas.translate(offsetX, patternCenterY);
      canvas.rotate(animationValue * math.pi / 2);
      final outerCrescent = Path()
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: crescentRadius))
        ..addOval(
            Rect.fromCircle(center: Offset(crescentRadius * 0.3, 0), radius: crescentRadius * 0.8));
      canvas.drawPath(outerCrescent, crescentPaint);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();

      // Right crescent
      canvas.save();
      canvas.translate(width / 2 + width * 0.25 - 30 - i * 60, patternCenterY);
      canvas.rotate(-animationValue * math.pi / 2);
      final mirrorCrescent = Path()
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: crescentRadius))
        ..addOval(
            Rect.fromCircle(center: Offset(-crescentRadius * 0.3, 0), radius: crescentRadius * 0.8));
      canvas.drawPath(mirrorCrescent, crescentPaint);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ArchwayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}