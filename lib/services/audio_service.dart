import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();
  
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;

  // Inicializar el servicio de audio
  Future<void> initialize() async {
    await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    await _backgroundPlayer.setVolume(0.5);
    await _effectPlayer.setVolume(0.7);
  }

  // Reproducir música de fondo
  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    
    try {
      await _backgroundPlayer.stop();
      await _backgroundPlayer.play(AssetSource('audio/background_music.mp3'));
    } catch (e) {
      print('Error al reproducir música de fondo: $e');
    }
  }

  // Detener música de fondo
  Future<void> stopBackgroundMusic() async {
    await _backgroundPlayer.stop();
  }

  // Pausar música de fondo
  Future<void> pauseBackgroundMusic() async {
    await _backgroundPlayer.pause();
  }

  // Reanudar música de fondo
  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    await _backgroundPlayer.resume();
  }

  // Reproducir efecto de victoria
  Future<void> playVictorySound() async {
    if (!_isSoundEnabled) return;
    
    try {
      // Crear sonido de victoria con tonos ascendentes
      await _effectPlayer.stop();
      // Aquí usarías un archivo de audio específico si lo tienes
      // Por ahora usamos la misma música pero a mayor velocidad
      await _effectPlayer.setPlaybackRate(1.5);
      await _effectPlayer.play(AssetSource('audio/background_music.mp3'));
      
      // Detener después de 2 segundos
      await Future.delayed(const Duration(seconds: 2));
      await _effectPlayer.stop();
      await _effectPlayer.setPlaybackRate(1.0);
    } catch (e) {
      print('Error al reproducir sonido de victoria: $e');
    }
  }

  // Reproducir efecto de derrota
  Future<void> playDefeatSound() async {
    if (!_isSoundEnabled) return;
    
    try {
      await _effectPlayer.stop();
      // Sonido más lento para derrota
      await _effectPlayer.setPlaybackRate(0.5);
      await _effectPlayer.play(AssetSource('audio/background_music.mp3'));
      
      // Detener después de 2 segundos
      await Future.delayed(const Duration(seconds: 2));
      await _effectPlayer.stop();
      await _effectPlayer.setPlaybackRate(1.0);
    } catch (e) {
      print('Error al reproducir sonido de derrota: $e');
    }
  }

  // Reproducir sonido de lanzamiento
  Future<void> playLaunchSound() async {
    if (!_isSoundEnabled) return;
    // Implementar sonido de lanzamiento
  }

  // Reproducir sonido de colisión
  Future<void> playCollisionSound() async {
    if (!_isSoundEnabled) return;
    // Implementar sonido de colisión
  }

  // Habilitar/deshabilitar música
  void toggleMusic(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    } else {
      playBackgroundMusic();
    }
  }

  // Habilitar/deshabilitar sonidos
  void toggleSounds(bool enabled) {
    _isSoundEnabled = enabled;
  }

  // Setters para volumen
  Future<void> setMusicVolume(double volume) async {
    await _backgroundPlayer.setVolume(volume);
  }

  Future<void> setSoundVolume(double volume) async {
    await _effectPlayer.setVolume(volume);
  }

  // Limpiar recursos
  Future<void> dispose() async {
    await _backgroundPlayer.dispose();
    await _effectPlayer.dispose();
  }

  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
}
