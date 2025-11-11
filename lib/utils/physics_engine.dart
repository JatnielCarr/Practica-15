import 'dart:ui';
import '../models/bird.dart';
import '../models/block.dart';
import '../models/enemy.dart';
import '../models/ground.dart';

class PhysicsEngine {
  static const double gravity = 0.5;
  static const double airFriction = 0.99;
  static const double groundBounce = 0.6;

  static void applyGravity(Bird bird) {
    if (bird.isLaunched) {
      bird.update();
    }
  }

  static void applyGravityToBlock(Block block) {
    block.update();
  }

  static void applyGravityToEnemy(Enemy enemy) {
    enemy.update();
  }

  static Offset calculateLaunchVelocity(Offset startPos, Offset endPos) {
    // Vector desde posición final a inicial, multiplicado por factor
    return (startPos - endPos) * 0.3;
  }

  static bool checkCircleCollision(
    Offset pos1,
    double radius1,
    Offset pos2,
    double radius2,
  ) {
    double distance = (pos1 - pos2).distance;
    return distance < (radius1 + radius2);
  }

  static void handleBirdBlockCollision(Bird bird, Block block) {
    if (bird.velocity.distance > 5) {
      double damage = bird.velocity.distance * 2;
      block.takeDamage(damage);
      bird.applyCollision(const Offset(0, 0));
    }
  }

  static void handleBirdEnemyCollision(Bird bird, Enemy enemy) {
    enemy.destroy();
    bird.applyCollision(const Offset(0, 0));
  }

  static void handleGroundCollisions(
    Bird bird,
    List<Block> blocks,
    List<Enemy> enemies,
    Ground ground,
  ) {
    // Colisión del pájaro con el suelo
    bird.handleGroundCollision(ground.y);

    // Colisiones de bloques con el suelo
    for (var block in blocks) {
      block.handleGroundCollision(ground.y);
    }

    // Colisiones de enemigos con el suelo
    for (var enemy in enemies) {
      enemy.handleGroundCollision(ground.y);
    }
  }

  static List<Offset> calculateTrajectory(
    Offset startPos,
    Offset velocity, {
    int steps = 30,
  }) {
    List<Offset> points = [];
    Offset pos = startPos;
    Offset vel = velocity;

    for (int i = 0; i < steps; i++) {
      points.add(pos);
      vel = Offset(vel.dx * airFriction, vel.dy + gravity);
      pos = pos + vel;
    }

    return points;
  }
}
