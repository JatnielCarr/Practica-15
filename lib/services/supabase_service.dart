import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/score.dart';
import '../models/power_up_item.dart';

class SupabaseService {
  static SupabaseClient? _client;

  // Inicializar Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // Obtener el cliente de Supabase
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase no ha sido inicializado. Llama a initialize() primero.');
    }
    return _client!;
  }

  // ==================== SCORES ====================
  
  // Guardar un score en la base de datos
  static Future<bool> saveScore(Score score) async {
    try {
      await client.from('scores').insert(score.toJson());
      return true;
    } catch (e) {
      print('Error al guardar score: $e');
      return false;
    }
  }

  // Obtener los mejores scores (leaderboard)
  static Future<List<Score>> getTopScores({int limit = 10}) async {
    try {
      final response = await client
          .from('scores')
          .select()
          .order('score', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Score.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al obtener scores: $e');
      return [];
    }
  }

  // Obtener scores por nivel
  static Future<List<Score>> getScoresByLevel(int level, {int limit = 10}) async {
    try {
      final response = await client
          .from('scores')
          .select()
          .eq('level', level)
          .order('score', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Score.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al obtener scores por nivel: $e');
      return [];
    }
  }

  // Obtener el mejor score del jugador
  static Future<Score?> getPlayerBestScore(String playerName) async {
    try {
      final response = await client
          .from('scores')
          .select()
          .eq('player_name', playerName)
          .order('score', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return Score.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error al obtener el mejor score del jugador: $e');
      return null;
    }
  }

  // ==================== POWER-UP ITEMS ====================
  
  // Obtener todos los items disponibles
  static Future<List<PowerUpItem>> getAvailableItems() async {
    try {
      final response = await client
          .from('power_up_items')
          .select()
          .order('price', ascending: true);

      return (response as List)
          .map((json) => PowerUpItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al obtener items: $e');
      return [];
    }
  }

  // Comprar un item
  static Future<bool> purchaseItem({
    required String playerName,
    required String itemId,
    required String itemType,
  }) async {
    try {
      final purchase = PurchasedItem(
        playerName: playerName,
        itemId: itemId,
        itemType: itemType,
      );
      
      await client.from('purchased_items').insert(purchase.toJson());
      return true;
    } catch (e) {
      print('Error al comprar item: $e');
      return false;
    }
  }

  // Obtener items comprados por el jugador (no usados)
  static Future<List<PurchasedItem>> getPlayerItems(String playerName) async {
    try {
      final response = await client
          .from('purchased_items')
          .select()
          .eq('player_name', playerName)
          .eq('is_used', false)
          .order('purchased_at', ascending: false);

      return (response as List)
          .map((json) => PurchasedItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al obtener items del jugador: $e');
      return [];
    }
  }

  // Marcar un item como usado
  static Future<bool> markItemAsUsed(String purchaseId) async {
    try {
      await client
          .from('purchased_items')
          .update({'is_used': true})
          .eq('id', purchaseId);
      return true;
    } catch (e) {
      print('Error al marcar item como usado: $e');
      return false;
    }
  }

  // Verificar conexión
  static Future<bool> checkConnection() async {
    try {
      await client.from('scores').select().limit(1);
      return true;
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }
}
