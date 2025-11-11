import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/bird.dart';
import '../models/block.dart';
import '../models/enemy.dart';
import '../models/particle.dart';

class GameObjectsPainter extends CustomPainter {
  final Bird bird;
  final List<Block> blocks;
  final List<Enemy> enemies;
  final List<Particle> particles;
  final Map<String, ui.Image> imageCache;

  GameObjectsPainter({
    required this.bird,
    required this.blocks,
    required this.enemies,
    required this.particles,
    required this.imageCache,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar partículas primero (fondo)
    for (var particle in particles) {
      if (particle.isAlive) {
        final paint = Paint()
          ..color = particle.color.withValues(alpha: particle.opacity);

        canvas.drawCircle(particle.position, particle.size, paint);
      }
    }

    // Dibujar bloques
    for (var block in blocks) {
      if (!block.isDestroyed) {
        _drawBlock(canvas, block);
      }
    }

    // Dibujar enemigos (aliens)
    for (var enemy in enemies) {
      if (!enemy.isDestroyed) {
        _drawEnemy(canvas, enemy);
      }
    }

    // Dibujar pájaro
    if (bird.isActive) {
      _drawBird(canvas, bird);
    }
  }

  void _drawBlock(Canvas canvas, Block block) {
    final image = imageCache[block.imagePath];
    
    if (image != null) {
      // Calcular opacidad según salud
      double healthPercent = block.health / block.maxHealth;
      
      final paint = Paint()
        ..filterQuality = FilterQuality.high
        ..color = Color.fromRGBO(255, 255, 255, 0.5 + healthPercent * 0.5);
      
      final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      final dstRect = Rect.fromCenter(
        center: block.position,
        width: block.width,
        height: block.height,
      );
      
      canvas.drawImageRect(image, srcRect, dstRect, paint);
    } else {
      // Fallback: dibujar rectángulo con color
      final rect = Rect.fromCenter(
        center: block.position,
        width: block.width,
        height: block.height,
      );

      double healthPercent = block.health / block.maxHealth;
      Color blockColor = block.color.withValues(alpha: 0.5 + healthPercent * 0.5);

      final paint = Paint()..color = blockColor;
      canvas.drawRect(rect, paint);

      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect, borderPaint);
    }
  }

  void _drawEnemy(Canvas canvas, Enemy enemy) {
    final image = imageCache[enemy.imagePath];
    
    if (image != null) {
      final paint = Paint()..filterQuality = FilterQuality.high;
      
      final size = enemy.radius * 2;
      final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      final dstRect = Rect.fromCenter(
        center: enemy.position,
        width: size,
        height: size,
      );
      
      canvas.drawImageRect(image, srcRect, dstRect, paint);
    } else {
      // Fallback: dibujar círculo verde
      final bodyPaint = Paint()..color = Colors.green[300]!;
      canvas.drawCircle(enemy.position, enemy.radius, bodyPaint);

      final borderPaint = Paint()
        ..color = Colors.green[800]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(enemy.position, enemy.radius, borderPaint);

      // Ojos
      final eyePaint = Paint()..color = Colors.black;
      canvas.drawCircle(enemy.position + const Offset(-8, -5), 5, eyePaint);
      canvas.drawCircle(enemy.position + const Offset(8, -5), 5, eyePaint);

      // Hocico
      final snoutPaint = Paint()..color = Colors.green[900]!;
      canvas.drawCircle(enemy.position + const Offset(0, 8), 6, snoutPaint);
    }
  }

  void _drawBird(Canvas canvas, Bird bird) {
    final image = imageCache[bird.imagePath];
    
    if (image != null) {
      final paint = Paint()..filterQuality = FilterQuality.high;
      
      final size = bird.radius * 2;
      final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      final dstRect = Rect.fromCenter(
        center: bird.position,
        width: size,
        height: size,
      );
      
      canvas.drawImageRect(image, srcRect, dstRect, paint);
    } else {
      // Fallback: dibujar pájaro rojo dibujado
      final bodyPaint = Paint()..color = Colors.red[600]!;
      canvas.drawCircle(bird.position, bird.radius, bodyPaint);

      // Pico amarillo
      final beakPath = Path();
      beakPath.moveTo(bird.position.dx + bird.radius, bird.position.dy);
      beakPath.lineTo(bird.position.dx + bird.radius + 10, bird.position.dy - 5);
      beakPath.lineTo(bird.position.dx + bird.radius + 10, bird.position.dy + 5);
      beakPath.close();

      final beakPaint = Paint()..color = Colors.yellow[700]!;
      canvas.drawPath(beakPath, beakPaint);

      // Ojos
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawCircle(bird.position + const Offset(-5, -5), 4, whitePaint);
      canvas.drawCircle(bird.position + const Offset(5, -5), 4, whitePaint);

      final pupilPaint = Paint()..color = Colors.black;
      canvas.drawCircle(bird.position + const Offset(-5, -5), 2, pupilPaint);
      canvas.drawCircle(bird.position + const Offset(5, -5), 2, pupilPaint);

      // Cejas
      final eyebrowPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        bird.position + const Offset(-10, -10),
        bird.position + const Offset(-2, -8),
        eyebrowPaint,
      );
      canvas.drawLine(
        bird.position + const Offset(10, -10),
        bird.position + const Offset(2, -8),
        eyebrowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(GameObjectsPainter oldDelegate) => true;
}
