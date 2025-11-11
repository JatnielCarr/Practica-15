import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double life;
  double maxLife;
  double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    this.maxLife = 60,
    this.size = 4,
  }) : life = 60;

  void update() {
    // Aplicar gravedad
    velocity = Offset(velocity.dx, velocity.dy + 0.3);

    // Actualizar posición
    position = position + velocity;

    // Reducir vida
    life--;
  }

  bool get isAlive => life > 0;

  double get opacity {
    return (life / maxLife).clamp(0.0, 1.0);
  }

  static List<Particle> createExplosion({
    required Offset position,
    required Color color,
    int count = 15,
  }) {
    List<Particle> particles = [];
    Random random = Random();

    for (int i = 0; i < count; i++) {
      double angle = (i / count) * 2 * pi;
      double speed = 3 + random.nextDouble() * 3; // 3-6 px/frame

      Offset velocity = Offset(cos(angle) * speed, sin(angle) * speed);

      particles.add(
        Particle(
          position: position,
          velocity: velocity,
          color: color,
          size: 3 + random.nextDouble() * 3,
        ),
      );
    }

    return particles;
  }
}
