import 'dart:ui';
import 'package:flutter/material.dart';

/// Componente Ground que representa el suelo del juego
/// Este es un cuerpo estático que no se mueve y sirve como superficie
/// donde los objetos del juego colisionan y se detienen.
class Ground {
  final double y; // Posición Y del suelo (parte superior del suelo)
  final double height; // Altura del suelo visible
  final double width; // Ancho total del suelo
  
  // Propiedades físicas
  final double friction; // Fricción de la superficie (0.0 a 1.0)
  final double restitution; // Rebote (0.0 = sin rebote, 1.0 = rebote perfecto)
  
  // Propiedades visuales
  final List<GroundSegment> segments;

  Ground({
    required this.y,
    this.height = 100.0,
    this.width = 2000.0,
    this.friction = 0.8,
    this.restitution = 0.3,
  }) : segments = _generateSegments(width, y, height);

  /// Genera segmentos visuales del suelo para darle textura
  static List<GroundSegment> _generateSegments(double width, double y, double height) {
    final segments = <GroundSegment>[];
    const segmentWidth = 80.0;
    
    for (double x = 0; x < width; x += segmentWidth) {
      segments.add(GroundSegment(
        x: x,
        y: y,
        width: segmentWidth,
        height: height,
      ));
    }
    
    return segments;
  }

  /// Verifica si un punto está dentro del suelo
  bool containsPoint(Offset point) {
    return point.dy >= y && point.dx >= 0 && point.dx <= width;
  }

  /// Obtiene la distancia desde un punto hasta la superficie del suelo
  double distanceFromSurface(Offset point) {
    if (point.dy < y) {
      return y - point.dy; // Distancia positiva si está arriba
    }
    return 0; // Ya está en el suelo o debajo
  }

  /// Renderiza el suelo en el canvas
  void render(Canvas canvas, double cameraOffsetX) {
    // Dibujar cada segmento del suelo
    for (final segment in segments) {
      segment.render(canvas, cameraOffsetX);
    }
  }
}

/// Segmento individual del suelo con su propia textura visual
class GroundSegment {
  final double x;
  final double y;
  final double width;
  final double height;
  
  GroundSegment({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  void render(Canvas canvas, double cameraOffsetX) {
    final adjustedX = x - cameraOffsetX;
    
    // No renderizar si está fuera de la pantalla
    if (adjustedX + width < -100 || adjustedX > 900) {
      return;
    }

    // 1. Capa de césped (parte superior)
    final grassHeight = height * 0.15;
    final grassRect = Rect.fromLTWH(
      adjustedX,
      y,
      width,
      grassHeight,
    );
    
    final grassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.green[600]!,
          Colors.green[700]!,
        ],
      ).createShader(grassRect);
    
    canvas.drawRect(grassRect, grassPaint);

    // 2. Dibujar briznas de césped
    final grassBladePaint = Paint()
      ..color = Colors.green[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (double gx = adjustedX; gx < adjustedX + width; gx += 10) {
      final grassPath = Path();
      grassPath.moveTo(gx, y + grassHeight);
      grassPath.quadraticBezierTo(
        gx + 2,
        y + grassHeight * 0.3,
        gx + 1,
        y,
      );
      canvas.drawPath(grassPath, grassBladePaint);
    }

    // 3. Capa de tierra (parte media)
    final dirtHeight = height * 0.50;
    final dirtRect = Rect.fromLTWH(
      adjustedX,
      y + grassHeight,
      width,
      dirtHeight,
    );
    
    final dirtPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.brown[600]!,
          Colors.brown[800]!,
        ],
      ).createShader(dirtRect);
    
    canvas.drawRect(dirtRect, dirtPaint);

    // 4. Dibujar pequeñas rocas en la tierra
    final rockPaint = Paint()
      ..color = Colors.grey[700]!;

    for (double rx = adjustedX + 15; rx < adjustedX + width - 15; rx += 40) {
      canvas.drawCircle(
        Offset(rx, y + grassHeight + dirtHeight * 0.3),
        3,
        rockPaint,
      );
      canvas.drawCircle(
        Offset(rx + 10, y + grassHeight + dirtHeight * 0.7),
        2,
        rockPaint,
      );
    }

    // 5. Capa de roca (parte inferior)
    final rockLayerHeight = height * 0.35;
    final rockRect = Rect.fromLTWH(
      adjustedX,
      y + grassHeight + dirtHeight,
      width,
      rockLayerHeight,
    );
    
    final rockLayerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey[800]!,
          Colors.grey[900]!,
        ],
      ).createShader(rockRect);
    
    canvas.drawRect(rockRect, rockLayerPaint);

    // 6. Línea de contorno superior (separación césped-aire)
    final outlinePaint = Paint()
      ..color = Colors.green[900]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(adjustedX, y),
      Offset(adjustedX + width, y),
      outlinePaint,
    );

    // 7. Línea de separación césped-tierra
    final separatorPaint = Paint()
      ..color = Colors.brown[900]!.withOpacity(0.5)
      ..strokeWidth = 1;
    
    canvas.drawLine(
      Offset(adjustedX, y + grassHeight),
      Offset(adjustedX + width, y + grassHeight),
      separatorPaint,
    );
  }
}
