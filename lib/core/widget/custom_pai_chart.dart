import 'dart:math';

import 'package:flutter/cupertino.dart';

class DonutChartPainter extends CustomPainter {
  List<Map> segments;

  DonutChartPainter({ required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 18.0;
    final radius = (size.width / 2) - strokeWidth / 2;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    const gap = 0.06; // radians
    double startAngle = -pi / 2;

    for (var segment in segments) {
      final sweepAngle =
          ((segment['value'] as double) / 100) * (2 * pi);

      final paint = Paint()
        ..color = segment['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle - gap,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}