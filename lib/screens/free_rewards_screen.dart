import 'package:flutter/material.dart';
import '../services/admob_service.dart';

/// Pantalla que muestra opciones de power-ups gratuitos mediante anuncios
class FreeRewardsScreen extends StatefulWidget {
  final String playerName;
  
  const FreeRewardsScreen({super.key, required this.playerName});

  @override
  State<FreeRewardsScreen> createState() => _FreeRewardsScreenState();
}

class _FreeRewardsScreenState extends State<FreeRewardsScreen> {
  final AdMobService _adMobService = AdMobService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber[300]!, Colors.orange[100]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Contenido principal
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _buildRewardsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[700],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎁 Recompensas Gratis',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Mira anuncios y gana power-ups',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando anuncio...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Instrucciones
        Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ve un video corto y obtén power-ups GRATIS para usar en tu próximo nivel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Reward Cards
        _buildRewardCard(
          icon: Icons.speed,
          title: 'Super Speed GRATIS',
          description: 'Aumenta la velocidad del pájaro en 50%',
          color: Colors.purple,
          rewardType: 'super_speed',
        ),
        const SizedBox(height: 16),
        
        _buildRewardCard(
          icon: Icons.whatshot,
          title: 'Explosive Bird GRATIS',
          description: 'Pájaro con poder explosivo',
          color: Colors.orange,
          rewardType: 'explosive_bird',
        ),
        const SizedBox(height: 16),
        
        _buildRewardCard(
          icon: Icons.filter_3,
          title: 'Triple Shot GRATIS',
          description: 'Dispara tres pájaros a la vez',
          color: Colors.blue,
          rewardType: 'triple_shot',
        ),
      ],
    );
  }

  Widget _buildRewardCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String rewardType,
  }) {
    final bool isReady = _adMobService.isRewardedLoaded;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Icono
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 40, color: color),
                  ),
                  const SizedBox(width: 16),
                  
                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Botón de acción
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isReady ? () => _watchAdForReward(rewardType) : null,
                  icon: Icon(
                    isReady ? Icons.play_circle_filled : Icons.hourglass_empty,
                    size: 24,
                  ),
                  label: Text(
                    isReady ? 'VER ANUNCIO Y OBTENER' : 'Cargando...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isReady ? Colors.white : Colors.grey[400],
                    foregroundColor: isReady ? color : Colors.grey[600],
                    elevation: isReady ? 4 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _watchAdForReward(String rewardType) async {
    setState(() => _isLoading = true);

    try {
      final success = await _adMobService.showRewardedAd(
        onUserEarnedReward: (amount, type) {
          // Usuario completó el video
          _onRewardEarned(rewardType, amount);
        },
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El anuncio no está disponible. Intenta más tarde.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error al mostrar anuncio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar el anuncio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onRewardEarned(String rewardType, int amount) {
    // Mapear tipo de recompensa a nombre de item
    String itemName;
    switch (rewardType) {
      case 'super_speed':
        itemName = 'Super Speed';
        break;
      case 'explosive_bird':
        itemName = 'Explosive Bird';
        break;
      case 'triple_shot':
        itemName = 'Triple Shot';
        break;
      default:
        itemName = 'Power-Up';
    }

    // Mostrar mensaje de éxito y retornar al juego
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.celebration, color: Colors.amber, size: 32),
              SizedBox(width: 8),
              Text('¡Recompensa Obtenida!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.card_giftcard,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                '¡Has ganado $itemName!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'El power-up se activará automáticamente en tu próximo lanzamiento',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context, {
                  'itemName': itemName,
                  'itemType': rewardType,
                  'isFromAd': true,
                }); // Retornar al juego con recompensa
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'USAR AHORA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
