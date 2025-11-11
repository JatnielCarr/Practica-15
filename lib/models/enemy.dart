import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/asset_manager.dart';

class Enemy {
  Offset position;
  Offset velocity;
  double radius;
  bool isDestroyed;
  final int points = 500;
  String imagePath;
  bool isPlaced; // Indica si el enemigo está colocado (no debe aplicarse gravedad)

  Enemy({
    required this.position,
    this.velocity = const Offset(0, 0),
    this.radius = 25,
    this.isDestroyed = false,
    this.isPlaced = true, // Por defecto, los enemigos están colocados
  }) : imagePath = _getRandomAlienImage();

  static String _getRandomAlienImage() {
    final random = Random();
    return AssetManager.alienImages[random.nextInt(AssetManager.alienImages.length)];
  }

  void update() {
    // Solo aplicar física si el enemigo no está colocado (ya fue golpeado)
    if (!isPlaced) {
      // Aplicar gravedad
      velocity = Offset(velocity.dx, velocity.dy + 0.5);

      // Aplicar fricción
      velocity = velocity * 0.98;

      // Actualizar posición
      position = position + velocity;

      // Detener si velocidad es muy baja
      if (velocity.distance < 0.5) {
        velocity = const Offset(0, 0);
      }
    }
  }

  void handleGroundCollision(double groundY) {
    if (position.dy + radius >= groundY) {
      position = Offset(position.dx, groundY - radius);
      velocity = Offset(velocity.dx * 0.9, -velocity.dy * 0.4);

      if (velocity.dy.abs() < 0.5) {
        velocity = Offset(velocity.dx, 0);
      }
    }
  }

  void destroy() {
    isDestroyed = true;
    // Cuando el enemigo es destruido, ya no está "colocado"
    isPlaced = false;
  }

  bool collidesWith(Offset point, double otherRadius) {
    double distance = (position - point).distance;
    return distance < (radius + otherRadius);
  }
}
