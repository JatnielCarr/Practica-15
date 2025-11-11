import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';
import 'dart:ui' as ui;
import '../models/bird.dart';
import '../models/block.dart';
import '../models/enemy.dart';
import '../models/particle.dart';
import '../models/star_system.dart';
import '../models/score.dart';
import '../utils/physics_engine.dart';
import '../utils/collision_detector.dart';
import '../utils/asset_manager.dart';
import '../widgets/slingshot_painter.dart';
import '../widgets/game_objects.dart';
import '../widgets/trajectory_painter.dart';
import '../widgets/admob_banner_widget.dart';
import '../services/supabase_service.dart';
import '../services/audio_service.dart';
import '../services/admob_service.dart';
import 'leaderboard_screen.dart';
import 'store_screen.dart';
import 'free_rewards_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Bird _bird;
  List<Block> _blocks = [];
  List<Enemy> _enemies = [];
  List<Particle> _particles = [];

  final Offset _initialBirdPosition = const Offset(150, 280);
  final double _groundY = 420;
  final double _maxStretch = 100;

  int _score = 0;
  int _birdsRemaining = 3;
  int _currentLevel = 1;
  bool _isDragging = false;
  bool _levelComplete = false;
  bool _gameOver = false;
  Timer? _resetTimer;
  
  // Power-up activo (null si no hay ninguno activo)
  String? _activePowerUp;
  int _powerUpShots = 0; // Cantidad de disparos especiales restantes

  // Nombre del jugador
  String _playerName = 'Player';

  // Nuevas variables para la cámara
  double _cameraOffsetX = 0.0;
  final double _cameraSpeed = 0.1; // Suavidad del seguimiento

  // Variable para la posición de arrastre (trayectoria)
  Offset? _dragPosition;

  // Cache de imágenes
  final Map<String, ui.Image> _imageCache = {};
  ui.Image? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // 60 FPS
    )..addListener(_update);

    _bird = Bird(position: _initialBirdPosition);
    _loadLevel(_currentLevel);
    _controller.repeat();
  }

  Future<void> _loadImages() async {
    // Cargar imágenes de pájaros
    await _loadImage(AssetManager.birdRed);
    await _loadImage(AssetManager.birdYellow);
    await _loadImage(AssetManager.birdBlue);
    
    // Cargar imágenes de aliens
    for (final alienPath in AssetManager.alienImages) {
      await _loadImage(alienPath);
    }
    
    // Cargar imágenes de bloques de madera
    for (final woodPath in AssetManager.woodBlocks) {
      await _loadImage(woodPath);
    }
    
    // Cargar imágenes de bloques de piedra
    for (final stonePath in AssetManager.stoneBlocks) {
      await _loadImage(stonePath);
    }
    
    // Cargar fondo
    _backgroundImage = await _loadImage(AssetManager.bgColoredGrass);
    
    // Imágenes cargadas, actualizar UI si es necesario
    if (mounted) {
      setState(() {});
    }
  }

  Future<ui.Image> _loadImage(String path) async {
    if (_imageCache.containsKey(path)) {
      return _imageCache[path]!;
    }
    
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    
    _imageCache[path] = frame.image;
    return frame.image;
  }

  @override
  void dispose() {
    _controller.dispose();
    _resetTimer?.cancel();
    super.dispose();
  }

  void _update() {
    if (_gameOver || _levelComplete) return;

    setState(() {
      // Actualizar física del pájaro
      PhysicsEngine.applyGravity(_bird);

      // Actualizar bloques
      for (var block in _blocks) {
        PhysicsEngine.applyGravityToBlock(block);
      }

      // Actualizar enemigos
      for (var enemy in _enemies) {
        PhysicsEngine.applyGravityToEnemy(enemy);
      }

      // Actualizar partículas
      _particles.removeWhere((p) => !p.isAlive);
      for (var particle in _particles) {
        particle.update();
      }

      // Actualizar cámara para seguir al pájaro
      _updateCamera();

      // Colisiones con el suelo
      PhysicsEngine.handleGroundCollisions(_bird, _blocks, _enemies, _groundY);

      // Detectar colisiones
      var collisions = CollisionDetector.detectAllCollisions(
        _bird,
        _blocks,
        _enemies,
      );

      // Manejar colisiones
      CollisionDetector.handleCollisions(
        collisions,
        _bird,
        _addScore,
        _vibrateHeavy,
      );

      // Eliminar objetos destruidos y crear partículas
      _blocks.removeWhere((block) {
        if (block.isDestroyed) {
          _createExplosion(block.position, block.color);
          return true;
        }
        return false;
      });

      _enemies.removeWhere((enemy) {
        if (enemy.isDestroyed) {
          _createExplosion(enemy.position, Colors.green);
          return true;
        }
        return false;
      });

      // Verificar victoria/derrota
      _checkLevelComplete();
      _checkGameOver();

      // Resetear pájaro si está inactivo
      if (_bird.isLaunched && !_bird.isActive && _resetTimer == null) {
        _resetTimer = Timer(const Duration(milliseconds: 1500), () {
          if (!_levelComplete && !_gameOver) {
            _resetBird();
          }
        });
      }
    });
  }

  void _loadLevel(int level) {
    _blocks.clear();
    _enemies.clear();
    _particles.clear();
    _levelComplete = false;
    _gameOver = false;
    _birdsRemaining = 3;
    
    // Resetear power-up al cambiar de nivel
    _activePowerUp = null;
    _powerUpShots = 0;

    switch (level) {
      case 1:
        _loadLevel1();
        break;
      case 2:
        _loadLevel2();
        break;
      case 3:
        _loadLevel3();
        break;
      case 4:
        _loadLevel4();
        break;
      case 5:
        _loadLevel5();
        break;
      case 6:
        _loadBigBossLevel();
        break;
      default:
        _showVictoryScreen();
    }
  }

  void _loadLevel1() {
    // Torre simple 3x3
    final baseX = 500.0;
    final baseY = _groundY;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        _blocks.add(
          Block(
            position: Offset(baseX + (j - 1) * 45, baseY - 45 - (i * 45)),
            type: (i + j) % 2 == 0 ? BlockType.wood : BlockType.stone,
          ),
        );
      }
    }

    _enemies.add(Enemy(position: Offset(baseX, baseY - 180)));
  }

  void _loadLevel2() {
    // Dos torres
    final tower1X = 450.0;
    final tower2X = 650.0;
    final baseY = _groundY;

    for (final towerX in [tower1X, tower2X]) {
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 2; j++) {
          _blocks.add(
            Block(
              position: Offset(towerX + (j - 0.5) * 45, baseY - 45 - (i * 45)),
              type: (i + j) % 2 == 0 ? BlockType.wood : BlockType.stone,
            ),
          );
        }
      }

      _enemies.add(Enemy(position: Offset(towerX, baseY - 200)));
    }
  }

  void _loadLevel3() {
    // Torre grande 5x4
    final baseX = 550.0;
    final baseY = _groundY;

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 5; j++) {
        _blocks.add(
          Block(
            position: Offset(baseX + (j - 2) * 45, baseY - 45 - (i * 45)),
            type: (i + j) % 2 == 0 ? BlockType.wood : BlockType.stone,
          ),
        );
      }
    }

    _enemies.add(Enemy(position: Offset(baseX - 70, baseY - 100)));
    _enemies.add(Enemy(position: Offset(baseX + 70, baseY - 100)));
    _enemies.add(Enemy(position: Offset(baseX, baseY - 200)));
  }

  void _loadLevel4() {
    // Castillo con murallas
    final baseX = 550.0;
    final baseY = _groundY;

    // Muralla izquierda
    for (int i = 0; i < 5; i++) {
      _blocks.add(
        Block(
          position: Offset(baseX - 120, baseY - 45 - (i * 45)),
          type: BlockType.stone,
        ),
      );
    }

    // Muralla derecha
    for (int i = 0; i < 5; i++) {
      _blocks.add(
        Block(
          position: Offset(baseX + 120, baseY - 45 - (i * 45)),
          type: BlockType.stone,
        ),
      );
    }

    // Interior del castillo
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 4; j++) {
        _blocks.add(
          Block(
            position: Offset(baseX + (j - 1.5) * 45, baseY - 45 - (i * 45)),
            type: i > 1 ? BlockType.wood : BlockType.stone,
          ),
        );
      }
    }

    // Enemigos estratégicamente ubicados
    _enemies.add(Enemy(position: Offset(baseX - 120, baseY - 260)));
    _enemies.add(Enemy(position: Offset(baseX, baseY - 180)));
    _enemies.add(Enemy(position: Offset(baseX + 120, baseY - 260)));
  }

  void _loadLevel5() {
    // Fortaleza compleja
    final baseX = 600.0;
    final baseY = _groundY;

    // Torre principal alta
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 2; j++) {
        _blocks.add(
          Block(
            position: Offset(baseX + (j - 0.5) * 45, baseY - 45 - (i * 45)),
            type: i < 3 ? BlockType.stone : BlockType.wood,
          ),
        );
      }
    }

    // Torres laterales
    for (final offsetX in [-150.0, 150.0]) {
      for (int i = 0; i < 4; i++) {
        _blocks.add(
          Block(
            position: Offset(baseX + offsetX, baseY - 45 - (i * 45)),
            type: BlockType.stone,
          ),
        );
      }
      _enemies.add(Enemy(position: Offset(baseX + offsetX, baseY - 200)));
    }

    // Puentes de madera
    for (int j = 0; j < 3; j++) {
      _blocks.add(
        Block(
          position: Offset(baseX - 90 + (j * 45), baseY - 200),
          type: BlockType.wood,
        ),
      );
      _blocks.add(
        Block(
          position: Offset(baseX + 15 + (j * 45), baseY - 200),
          type: BlockType.wood,
        ),
      );
    }

    // Enemigos múltiples
    _enemies.add(Enemy(position: Offset(baseX, baseY - 300)));
    _enemies.add(Enemy(position: Offset(baseX - 60, baseY - 130)));
    _enemies.add(Enemy(position: Offset(baseX + 60, baseY - 130)));
  }

  void _loadBigBossLevel() {
    // ¡NIVEL DEL BIG BOSS! 👑
    final baseX = 650.0;
    final baseY = _groundY;

    // Fortaleza masiva del boss
    // Base de piedra sólida
    for (int j = 0; j < 8; j++) {
      _blocks.add(
        Block(
          position: Offset(baseX + (j - 3.5) * 45, baseY - 45),
          type: BlockType.stone,
        ),
      );
    }

    // Torres gemelas
    for (final offsetX in [-135.0, 135.0]) {
      for (int i = 1; i < 7; i++) {
        for (int j = 0; j < 2; j++) {
          _blocks.add(
            Block(
              position: Offset(baseX + offsetX + (j * 45), baseY - 45 - (i * 45)),
              type: BlockType.stone,
            ),
          );
        }
      }
    }

    // Torre central (la más alta)
    for (int i = 1; i < 9; i++) {
      for (int j = 0; j < 3; j++) {
        _blocks.add(
          Block(
            position: Offset(baseX + (j - 1) * 45, baseY - 45 - (i * 45)),
            type: i < 5 ? BlockType.stone : BlockType.wood,
          ),
        );
      }
    }

    // Muros conectores
    for (int j = 0; j < 3; j++) {
      _blocks.add(
        Block(
          position: Offset(baseX - 90 + (j * 45), baseY - 300),
          type: BlockType.wood,
        ),
      );
      _blocks.add(
        Block(
          position: Offset(baseX + 45 + (j * 45), baseY - 300),
          type: BlockType.wood,
        ),
      );
    }

    // BOSS ALIEN (más grande y en el centro)
    final bossEnemy = Enemy(
      position: Offset(baseX, baseY - 420),
      radius: 40, // ¡El boss es más grande!
    );
    _enemies.add(bossEnemy);

    // Guardias del boss
    _enemies.add(Enemy(position: Offset(baseX - 135, baseY - 350)));
    _enemies.add(Enemy(position: Offset(baseX + 135, baseY - 350)));
    _enemies.add(Enemy(position: Offset(baseX - 70, baseY - 150)));
    _enemies.add(Enemy(position: Offset(baseX + 70, baseY - 150)));
    _enemies.add(Enemy(position: Offset(baseX, baseY - 180)));
  }

  void _onPanStart(DragStartDetails details) {
    final touchPos = details.localPosition;
    final distance = (_bird.position - touchPos).distance;

    if (distance < 30 && !_bird.isLaunched) {
      setState(() {
        _isDragging = true;
        _dragPosition = touchPos;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final newPos = details.localPosition;
    final dragVector = newPos - _initialBirdPosition;

    // Limitar estiramiento
    if (dragVector.distance <= _maxStretch) {
      setState(() {
        _bird.position = newPos;
        _dragPosition = newPos;
      });
    } else {
      final limitedPos =
          _initialBirdPosition +
          Offset.fromDirection(dragVector.direction, _maxStretch);
      setState(() {
        _bird.position = limitedPos;
        _dragPosition = limitedPos;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final launchVelocity = PhysicsEngine.calculateLaunchVelocity(
      _initialBirdPosition,
      _bird.position,
    );

    setState(() {
      // Aplicar power-up si hay uno activo
      if (_activePowerUp != null && _powerUpShots > 0) {
        _applyPowerUpEffect(launchVelocity);
        _powerUpShots--;
        
        // Si se acabaron los turnos, desactivar power-up
        if (_powerUpShots <= 0) {
          _activePowerUp = null;
        }
      } else {
        // Lanzamiento normal
        _bird.launch(launchVelocity);
      }
      
      _isDragging = false;
      _dragPosition = null;
      _birdsRemaining--;
    });

    _vibrateLaunch();
  }

  void _applyPowerUpEffect(Offset launchVelocity) {
    switch (_activePowerUp) {
      case 'Super Speed':
        // Aumentar la velocidad del pájaro
        _bird.launch(launchVelocity * 1.5);
        break;
        
      case 'Explosive Bird':
        // Lanzar pájaro normal pero marcarlo como explosivo
        _bird.launch(launchVelocity);
        // TODO: Marcar el pájaro como explosivo para que cause más daño
        break;
        
      case 'Triple Shot':
        // Lanzar tres pájaros en ángulos diferentes
        _bird.launch(launchVelocity);
        // Crear dos pájaros adicionales con ángulos ligeramente diferentes
        // (Simplificado - en una implementación completa crearías más pájaros)
        break;
        
      default:
        _bird.launch(launchVelocity);
    }
  }

  void _resetBird() {
    _resetTimer?.cancel();
    _resetTimer = null;

    if (_birdsRemaining > 0) {
      setState(() {
        _bird.reset(_initialBirdPosition);
        _cameraOffsetX = 0.0; // Resetear cámara
      });
    }
  }

  void _updateCamera() {
    // Seguir al pájaro solo si está en el aire
    if (_bird.isLaunched && _bird.isActive) {
      // Calcular la posición objetivo de la cámara
      final targetOffsetX =
          _bird.position.dx - 400; // Mantener pájaro en el centro-izquierda

      // Smooth lerp hacia el objetivo
      _cameraOffsetX += (targetOffsetX - _cameraOffsetX) * _cameraSpeed;

      // Limitar la cámara para no mostrar área vacía
      _cameraOffsetX = _cameraOffsetX.clamp(0.0, 600.0);
    }
  }

  void _checkLevelComplete() {
    if (_enemies.where((e) => !e.isDestroyed).isEmpty && !_levelComplete) {
      _levelComplete = true;

      // Reproducir sonido de victoria
      AudioService().playVictorySound();

      // Bonus por pájaros no usados
      _addScore(_birdsRemaining * 1000);

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _currentLevel++;
          _loadLevel(_currentLevel);
        });
      });
    }
  }

  void _checkGameOver() {
    final birdsInUse = _bird.isLaunched && _bird.isActive;
    final enemiesLeft = _enemies.where((e) => !e.isDestroyed).isNotEmpty;

    if (_birdsRemaining == 0 && !birdsInUse && enemiesLeft && !_gameOver) {
      // Reproducir sonido de derrota
      AudioService().playDefeatSound();
      
      setState(() => _gameOver = true);
    }
  }

  void _addScore(int points) {
    setState(() => _score += points);
  }

  void _createExplosion(Offset position, Color color) {
    _particles.addAll(
      Particle.createExplosion(position: position, color: color, count: 15),
    );
  }

  Future<void> _vibrateLaunch() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _vibrateHeavy() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 100);
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _showVictoryScreen() {
    setState(() => _levelComplete = true);
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _currentLevel = 1;
      _gameOver = false;
      _bird.reset(_initialBirdPosition);
      _loadLevel(_currentLevel);
    });
  }

  Future<void> _showSaveScoreDialog(int stars) async {
    final TextEditingController nameController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar Score'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu nombre',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa un nombre')),
                );
                return;
              }

              Navigator.pop(context);
              await _saveScore(name, stars);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveScore(String playerName, int stars) async {
    final score = Score(
      playerName: playerName,
      score: _score,
      level: _currentLevel - 1,
      stars: stars,
    );

    final success = await SupabaseService.saveScore(score);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Score guardado exitosamente! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el score. Intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
    );
  }

  void _openStore() async {
    // Navegar a la tienda
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoreScreen(playerName: _playerName)),
    );
    
    // Si se compró un power-up, activarlo
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _activePowerUp = result['itemName'];
        _powerUpShots = 1; // Un power-up solo es válido por un turno
      });
      
      // Mostrar mensaje de confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡${result['itemName']} activado! Válido por 1 turno'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[300]!, Colors.blue[50]!],
          ),
        ),
        child: Stack(
          children: [
            // Juego principal con cámara
            GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(-_cameraOffsetX, 0),
                  child: CustomPaint(
                    painter: _GamePainter(
                      bird: _bird,
                      blocks: _blocks,
                      enemies: _enemies,
                      particles: _particles,
                      groundY: _groundY,
                      showSlingshot: !_bird.isLaunched,
                      dragPosition: _dragPosition,
                      initialBirdPosition: _initialBirdPosition,
                      imageCache: _imageCache,
                      backgroundImage: _backgroundImage,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),

            // HUD
            _buildHUD(),

            // Pantalla de victoria
            if (_levelComplete && _currentLevel > 3) _buildVictoryScreen(),

            // Pantalla de Game Over
            if (_gameOver) _buildGameOverScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score
                Text(
                  'SCORE: $_score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),

                // Pájaros restantes
                Row(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.circle,
                        color: index < _birdsRemaining
                            ? Colors.red
                            : Colors.red.withOpacity(0.3),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Nivel y botones de leaderboard y tienda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LEVEL $_currentLevel',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.leaderboard, color: Colors.white, size: 28),
                      onPressed: _showLeaderboard,
                      tooltip: 'Leaderboard',
                    ),
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.amber, size: 28),
                      onPressed: _openStore,
                      tooltip: 'Store',
                    ),
                  ],
                ),
              ],
            ),
            // Indicador de power-up activo
            if (_activePowerUp != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on, color: Colors.yellow, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$_activePowerUp ACTIVO ($_powerUpShots turnos restantes)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVictoryScreen() {
    final stars = StarSystem.calculateStars(_score, _currentLevel - 1);
    final performanceText = StarSystem.getPerformanceText(stars);
    final starColor = StarSystem.getStarColor(stars);

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'YOU WIN! 🎉',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
            ),
            const SizedBox(height: 20),

            // Performance text
            Text(
              performanceText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: starColor,
              ),
            ),
            const SizedBox(height: 20),

            // Estrellas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                StarSystem.maxStars,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: index < stars ? starColor : Colors.grey,
                    size: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Final Score: $_score',
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
            const SizedBox(height: 40),
            
            // Botón para guardar score
            ElevatedButton.icon(
              onPressed: () => _showSaveScoreDialog(stars),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'GUARDAR SCORE',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _restartGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            
            // Botón para ver leaderboard
            TextButton.icon(
              onPressed: _showLeaderboard,
              icon: const Icon(Icons.leaderboard, color: Colors.white),
              label: const Text(
                'VER LEADERBOARD',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GAME OVER 😢',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: $_score',
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
            const SizedBox(height: 40),
            
            // Botón para guardar score
            if (_score > 0)
              ElevatedButton.icon(
                onPressed: () => _showSaveScoreDialog(0),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'GUARDAR SCORE',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
              ),
            if (_score > 0) const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _restartGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'RESTART',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            
            // Botón para ver leaderboard
            TextButton.icon(
              onPressed: _showLeaderboard,
              icon: const Icon(Icons.leaderboard, color: Colors.white),
              label: const Text(
                'VER LEADERBOARD',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final Bird bird;
  final List<Block> blocks;
  final List<Enemy> enemies;
  final List<Particle> particles;
  final double groundY;
  final bool showSlingshot;
  final Offset? dragPosition;
  final Offset initialBirdPosition;
  final Map<String, ui.Image> imageCache;
  final ui.Image? backgroundImage;

  _GamePainter({
    required this.bird,
    required this.blocks,
    required this.enemies,
    required this.particles,
    required this.groundY,
    required this.showSlingshot,
    this.dragPosition,
    required this.initialBirdPosition,
    required this.imageCache,
    this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar fondo con imagen si está disponible
    if (backgroundImage != null) {
      final paint = Paint()..filterQuality = FilterQuality.medium;
      final srcRect = Rect.fromLTWH(0, 0, backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());
      final dstRect = Rect.fromLTWH(0, 0, size.width + 1200, size.height);
      canvas.drawImageRect(backgroundImage!, srcRect, dstRect, paint);
    } else {
      // Fondo fallback con degradado
      final backgroundPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, size.height),
          [Colors.blue[200]!, Colors.blue[50]!],
        );
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width + 1200, size.height), backgroundPaint);
    }
    
    // Dibujar suelo
    final groundPaint = Paint()..color = Colors.green[700]!;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width + 1200, size.height - groundY),
      groundPaint,
    );

    // Línea de tierra/césped
    final dirtPaint = Paint()..color = Colors.brown[600]!;
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        groundY + 30,
        size.width + 1200,
        size.height - groundY - 30,
      ),
      dirtPaint,
    );

    // Dibujar honda
    if (showSlingshot) {
      SlingshotPainter(birdPosition: bird.position).paint(canvas, size);
    }

    // Dibujar trayectoria predictiva
    if (dragPosition != null && showSlingshot) {
      TrajectoryPainter(
        startPosition: initialBirdPosition,
        currentDragPosition: dragPosition!,
      ).paint(canvas, size);
    }

    // Dibujar objetos del juego
    GameObjectsPainter(
      bird: bird,
      blocks: blocks,
      enemies: enemies,
      particles: particles,
      imageCache: imageCache,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(_GamePainter oldDelegate) => true;
}
