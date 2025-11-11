class Score {
  final String? id;
  final String playerName;
  final int score;
  final int level;
  final int stars;
  final DateTime createdAt;

  Score({
    this.id,
    required this.playerName,
    required this.score,
    required this.level,
    required this.stars,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'player_name': playerName,
      'score': score,
      'level': level,
      'stars': stars,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Crear desde JSON de Supabase
  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id']?.toString(),
      playerName: json['player_name'] ?? 'Anonymous',
      score: json['score'] ?? 0,
      level: json['level'] ?? 1,
      stars: json['stars'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Score(playerName: $playerName, score: $score, level: $level, stars: $stars)';
  }
}
