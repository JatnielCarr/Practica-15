import 'dart:ui';
import '../utils/asset_manager.dart';

class Bird {
  Offset position;
  Offset velocity;
  bool isLaunched;
  bool isActive;
  double radius;
  String imagePath;

  Bird({
    required this.position,
    this.velocity = const Offset(0, 0),
    this.isLaunched = false,
    this.isActive = true,
    this.radius = 20,
    this.imagePath = AssetManager.birdRed,
  });

  void update() {
    if (!isLaunched) return;

    // Aplicar gravedad
    velocity = Offset(velocity.dx, velocity.dy + 0.5);

    // Aplicar fricción del aire
    velocity = velocity * 0.99;

    // Actualizar posición
    position = position + velocity;

    // Verificar si está prácticamente detenido
    if (velocity.distance < 0.5) {
      isActive = false;
    }
  }

  void launch(Offset launchVelocity) {
    velocity = launchVelocity;
    isLaunched = true;
    isActive = true;
  }

  void handleGroundCollision(double groundY) {
    if (position.dy + radius >= groundY) {
      position = Offset(position.dx, groundY - radius);
      velocity = Offset(
        velocity.dx,
        -velocity.dy * 0.6,
      ); // Rebote con factor 0.6

      // Detener si velocidad es muy baja
      if (velocity.dy.abs() < 1) {
        velocity = Offset(velocity.dx * 0.8, 0);
      }
    }
  }

  void applyCollision(Offset normal) {
    // Reflejar velocidad según la normal de colisión
    velocity = velocity * 0.7; // Reducir velocidad en colisión
  }

  void reset(Offset initialPosition) {
    position = initialPosition;
    velocity = const Offset(0, 0);
    isLaunched = false;
    isActive = true;
  }
}
