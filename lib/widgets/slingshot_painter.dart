import 'package:flutter/material.dart';

class SlingshotPainter extends CustomPainter {
  final Offset birdPosition;
  final Offset slingshotLeft = const Offset(120, 280);
  final Offset slingshotRight = const Offset(180, 280);
  final bool showLines;

  SlingshotPainter({required this.birdPosition, this.showLines = true});

  @override
  void paint(Canvas canvas, Size size) {
    if (!showLines) return;

    final paint = Paint()
      ..color = Colors.brown[800]!
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Línea izquierda
    canvas.drawLine(slingshotLeft, birdPosition, paint);

    // Línea derecha
    canvas.drawLine(slingshotRight, birdPosition, paint);

    // Postes de la honda (opcional)
    final postPaint = Paint()
      ..color = Colors.brown[900]!
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      slingshotLeft - const Offset(0, 40),
      slingshotLeft,
      postPaint,
    );

    canvas.drawLine(
      slingshotRight - const Offset(0, 40),
      slingshotRight,
      postPaint,
    );
  }

  @override
  bool shouldRepaint(SlingshotPainter oldDelegate) {
    return oldDelegate.birdPosition != birdPosition ||
        oldDelegate.showLines != showLines;
  }
}
