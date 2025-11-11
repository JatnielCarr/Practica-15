import 'package:flutter/material.dart';

/// Sistema de calificación por estrellas (1-3 estrellas)
class StarSystem {
  static const int maxStars = 3;

  /// Calcula el número de estrellas basado en el puntaje
  /// - 3 estrellas: puntaje >= objetivo alto
  /// - 2 estrellas: puntaje >= objetivo medio
  /// - 1 estrella: completar el nivel
  static int calculateStars(int score, int level) {
    final thresholds = _getThresholds(level);

    if (score >= thresholds['high']!) {
      return 3;
    } else if (score >= thresholds['medium']!) {
      return 2;
    } else {
      return 1;
    }
  }

  /// Define los umbrales de puntaje para cada nivel
  static Map<String, int> _getThresholds(int level) {
    switch (level) {
      case 1:
        return {
          'medium': 1500, // 2 estrellas
          'high': 2500, // 3 estrellas
        };
      case 2:
        return {
          'medium': 2500, // 2 estrellas
          'high': 4000, // 3 estrellas
        };
      case 3:
        return {
          'medium': 4000, // 2 estrellas
          'high': 6000, // 3 estrellas
        };
      default:
        return {'medium': 2000, 'high': 3500};
    }
  }

  /// Obtiene el texto descriptivo del rendimiento
  static String getPerformanceText(int stars) {
    switch (stars) {
      case 3:
        return '¡EXCELENTE!';
      case 2:
        return '¡BIEN HECHO!';
      case 1:
        return 'COMPLETADO';
      default:
        return '';
    }
  }

  /// Obtiene el color asociado a cada estrella
  static Color getStarColor(int stars) {
    switch (stars) {
      case 3:
        return const Color(0xFFFFD700); // Oro
      case 2:
        return const Color(0xFFC0C0C0); // Plata
      case 1:
        return const Color(0xFFCD7F32); // Bronce
      default:
        return const Color(0xFF808080); // Gris
    }
  }
}
