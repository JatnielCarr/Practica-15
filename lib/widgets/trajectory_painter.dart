import 'package:flutter/material.dart';
import '../utils/physics_engine.dart';

/// Painter que dibuja la trayectoria predictiva del pájaro
class TrajectoryPainter extends CustomPainter {
  final Offset startPosition;
  final Offset currentDragPosition;
  final double dotRadius;
  final int dotCount;

  TrajectoryPainter({
    required this.startPosition,
    required this.currentDragPosition,
    this.dotRadius = 3.0,
    this.dotCount = 20,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calcular la velocidad de lanzamiento
    final velocity = PhysicsEngine.calculateLaunchVelocity(
      startPosition,
      currentDragPosition,
    );

    // Calcular los puntos de la trayectoria
    final trajectoryPoints = PhysicsEngine.calculateTrajectory(
      startPosition,
      velocity,
      steps: dotCount,
    );

    // Dibujar los puntos de la trayectoria
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < trajectoryPoints.length; i++) {
      final point = trajectoryPoints[i];

      // Hacer que los puntos se desvanezcan gradualmente
      final opacity = 0.7 - (i / trajectoryPoints.length) * 0.5;
      paint.color = Colors.white.withOpacity(opacity);

      // Dibujar punto
      canvas.drawCircle(point, dotRadius, paint);
    }

    // Dibujar una línea de impulso desde el punto de inicio
    final linePaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(startPosition, currentDragPosition, linePaint);
  }

  @override
  bool shouldRepaint(TrajectoryPainter oldDelegate) {
    return oldDelegate.currentDragPosition != currentDragPosition ||
        oldDelegate.startPosition != startPosition;
  }
}
