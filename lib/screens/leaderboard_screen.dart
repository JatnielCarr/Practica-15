import 'package:flutter/material.dart';
import '../models/score.dart';
import '../services/supabase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Score> _scores = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final scores = await SupabaseService.getTopScores(limit: 20);
      setState(() {
        _scores = scores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar scores: $e';
        _isLoading = false;
      });
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '🏆 LEADERBOARD',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 32),
                      onPressed: _loadScores,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadScores,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_scores.isEmpty) {
      return const Center(
        child: Text(
          'No hay scores aún.\n¡Sé el primero en jugar!',
          style: TextStyle(fontSize: 24, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _scores.length,
      itemBuilder: (context, index) {
        final score = _scores[index];
        final position = index + 1;

        return _buildScoreCard(score, position);
      },
    );
  }

  Widget _buildScoreCard(Score score, int position) {
    Color positionColor;
    IconData positionIcon;

    if (position == 1) {
      positionColor = Colors.amber;
      positionIcon = Icons.emoji_events;
    } else if (position == 2) {
      positionColor = Colors.grey[400]!;
      positionIcon = Icons.emoji_events;
    } else if (position == 3) {
      positionColor = Colors.brown[400]!;
      positionIcon = Icons.emoji_events;
    } else {
      positionColor = Colors.white;
      positionIcon = Icons.person;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: positionColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: position <= 3
                  ? Icon(positionIcon, color: Colors.white, size: 28)
                  : Text(
                      '$position',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.playerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Nivel ${score.level}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Stars
          Row(
            children: List.generate(
              3,
              (index) => Icon(
                index < score.stars ? Icons.star : Icons.star_border,
                color: index < score.stars ? Colors.amber : Colors.grey,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${score.score}',
              style: const TextStyle(
                fontSize: 18,
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
