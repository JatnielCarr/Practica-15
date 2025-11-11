import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/asset_manager.dart';

enum BlockType { wood, stone }

class Block {
  Offset position;
  Offset velocity;
  final BlockType type;
  double health;
  final double maxHealth;
  final double width;
  final double height;
  bool isDestroyed;
  String imagePath;

  Block({
    required this.position,
    required this.type,
    this.velocity = const Offset(0, 0),
    this.width = 40,
    this.height = 40,
    this.isDestroyed = false,
  })  : maxHealth = type == BlockType.wood ? 20 : 40,
        health = type == BlockType.wood ? 20 : 40,
        imagePath = _getRandomBlockImage(type);

  static String _getRandomBlockImage(BlockType type) {
    final random = Random();
    if (type == BlockType.wood) {
      return AssetManager.woodBlocks[random.nextInt(AssetManager.woodBlocks.length)];
    } else {
      return AssetManager.stoneBlocks[random.nextInt(AssetManager.stoneBlocks.length)];
    }
  }

  Color get color {
    if (type == BlockType.wood) {
      return Colors.brown[400]!;
    } else {
      return Colors.grey[600]!;
    }
  }

  int get points {
    return type == BlockType.wood ? 100 : 200;
  }

  void update() {
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

  void takeDamage(double damage) {
    health -= damage;
    if (health <= 0) {
      isDestroyed = true;
    }
  }

  void handleGroundCollision(double groundY) {
    if (position.dy + height / 2 >= groundY) {
      position = Offset(position.dx, groundY - height / 2);
      velocity = Offset(velocity.dx * 0.9, -velocity.dy * 0.4);

      if (velocity.dy.abs() < 0.5) {
        velocity = Offset(velocity.dx, 0);
      }
    }
  }

  bool collidesWith(Offset point, double radius) {
    // AABB collision detection
    double closestX = point.dx.clamp(
      position.dx - width / 2,
      position.dx + width / 2,
    );
    double closestY = point.dy.clamp(
      position.dy - height / 2,
      position.dy + height / 2,
    );

    double distanceX = point.dx - closestX;
    double distanceY = point.dy - closestY;

    return (distanceX * distanceX + distanceY * distanceY) < (radius * radius);
  }
}
