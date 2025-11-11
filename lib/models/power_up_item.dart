class PowerUpItem {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String type; // 'triple_shot', 'explosive_bird', 'super_speed'
  final String iconPath;
  final DateTime createdAt;

  PowerUpItem({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.iconPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price': price,
      'type': type,
      'icon_path': iconPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Crear desde JSON de Supabase
  factory PowerUpItem.fromJson(Map<String, dynamic> json) {
    return PowerUpItem(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      iconPath: json['icon_path'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'PowerUpItem(name: $name, price: \$$price, type: $type)';
  }
}

class PurchasedItem {
  final String? id;
  final String playerName;
  final String itemId;
  final String itemType;
  final bool isUsed;
  final DateTime purchasedAt;

  PurchasedItem({
    this.id,
    required this.playerName,
    required this.itemId,
    required this.itemType,
    this.isUsed = false,
    DateTime? purchasedAt,
  }) : purchasedAt = purchasedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'player_name': playerName,
      'item_id': itemId,
      'item_type': itemType,
      'is_used': isUsed,
      'purchased_at': purchasedAt.toIso8601String(),
    };
  }

  factory PurchasedItem.fromJson(Map<String, dynamic> json) {
    return PurchasedItem(
      id: json['id']?.toString(),
      playerName: json['player_name'] ?? '',
      itemId: json['item_id'] ?? '',
      itemType: json['item_type'] ?? '',
      isUsed: json['is_used'] ?? false,
      purchasedAt: json['purchased_at'] != null
          ? DateTime.parse(json['purchased_at'])
          : DateTime.now(),
    );
  }
}
