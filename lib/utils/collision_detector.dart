import '../models/bird.dart';
import '../models/block.dart';
import '../models/enemy.dart';
import 'physics_engine.dart';

class CollisionDetector {
  static List<CollisionResult> detectAllCollisions(
    Bird bird,
    List<Block> blocks,
    List<Enemy> enemies,
  ) {
    List<CollisionResult> collisions = [];

    if (!bird.isLaunched) return collisions;

    // Colisiones con bloques
    for (var block in blocks) {
      if (block.isDestroyed) continue;

      if (block.collidesWith(bird.position, bird.radius)) {
        collisions.add(
          CollisionResult(type: CollisionType.birdBlock, block: block),
        );
      }
    }

    // Colisiones con enemigos
    for (var enemy in enemies) {
      if (enemy.isDestroyed) continue;

      if (enemy.collidesWith(bird.position, bird.radius)) {
        collisions.add(
          CollisionResult(type: CollisionType.birdEnemy, enemy: enemy),
        );
      }
    }

    return collisions;
  }

  static void handleCollisions(
    List<CollisionResult> collisions,
    Bird bird,
    Function(int) onScoreUpdate,
    Function() onVibrate,
  ) {
    for (var collision in collisions) {
      switch (collision.type) {
        case CollisionType.birdBlock:
          if (collision.block != null) {
            PhysicsEngine.handleBirdBlockCollision(bird, collision.block!);
            if (collision.block!.isDestroyed) {
              onScoreUpdate(collision.block!.points);
              onVibrate();
            }
          }
          break;

        case CollisionType.birdEnemy:
          if (collision.enemy != null) {
            PhysicsEngine.handleBirdEnemyCollision(bird, collision.enemy!);
            onScoreUpdate(collision.enemy!.points);
            onVibrate();
          }
          break;
      }
    }
  }
}

enum CollisionType { birdBlock, birdEnemy }

class CollisionResult {
  final CollisionType type;
  final Block? block;
  final Enemy? enemy;

  CollisionResult({required this.type, this.block, this.enemy});
}
