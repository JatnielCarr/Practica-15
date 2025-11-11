# 🎮 Angry Birds Clone - Integración con Supabase

## ✅ Integración Completada

Se ha integrado exitosamente Supabase como base de datos en la nube para el juego Angry Birds Clone.

## 📦 Cambios Realizados

### 1. **Dependencias Agregadas**
- ✅ `supabase_flutter: ^2.8.0` agregado a `pubspec.yaml`
- ✅ Dependencias instaladas con `flutter pub get`

### 2. **Nuevos Archivos Creados**

#### Configuración
- **`lib/config/supabase_config.dart`**
  - URL del proyecto Supabase
  - API Key (anon/public)

#### Modelos
- **`lib/models/score.dart`**
  - Modelo de datos para scores
  - Métodos `toJson()` y `fromJson()`
  - Campos: id, playerName, score, level, stars, createdAt

#### Servicios
- **`lib/services/supabase_service.dart`**
  - Inicialización de Supabase
  - Método `saveScore()` - Guardar scores
  - Método `getTopScores()` - Obtener top scores
  - Método `getScoresByLevel()` - Scores por nivel
  - Método `getPlayerBestScore()` - Mejor score del jugador
  - Método `checkConnection()` - Verificar conexión

#### Pantallas
- **`lib/screens/leaderboard_screen.dart`**
  - Pantalla visual del leaderboard
  - Top 20 scores
  - Diseño con medallas (🥇🥈🥉)
  - Muestra: posición, nombre, nivel, estrellas, score
  - Botón de recarga

### 3. **Archivos Modificados**

#### `lib/main.dart`
- ✅ Inicialización de Supabase antes de iniciar la app
- ✅ Import del servicio de Supabase

#### `lib/screens/game_screen.dart`
- ✅ Imports de Score, SupabaseService y LeaderboardScreen
- ✅ Nuevo método `_showSaveScoreDialog()` - Diálogo para ingresar nombre
- ✅ Nuevo método `_saveScore()` - Guardar score en Supabase
- ✅ Nuevo método `_showLeaderboard()` - Navegar al leaderboard
- ✅ Botón "GUARDAR SCORE" en pantalla de victoria
- ✅ Botón "GUARDAR SCORE" en pantalla de game over (si score > 0)
- ✅ Botón "VER LEADERBOARD" en ambas pantallas
- ✅ Icono de leaderboard (🏆) en el HUD durante el juego
- ✅ Reemplazo de `withOpacity()` por `withValues(alpha:)` (API moderna)

### 4. **Documentación**
- **`SUPABASE_SETUP.md`**
  - Guía completa de configuración
  - Script SQL para crear la tabla
  - Configuración de Row Level Security (RLS)
  - Políticas de seguridad
  - Solución de problemas
  - Ejemplos de uso

### 5. **Correcciones Adicionales**
- ✅ Directorios `assets/` y `assets/images/` creados
- ✅ Actualización a API moderna de Flutter (`withValues()`)

## 🎯 Funcionalidades Implementadas

### Durante el Juego
- 🏆 Botón de leaderboard en el HUD (esquina superior derecha)

### Pantalla de Victoria
- 💾 Guardar score con nombre del jugador
- 🏆 Ver leaderboard global
- 🔄 Jugar de nuevo
- ⭐ Muestra estrellas obtenidas

### Pantalla de Game Over
- 💾 Guardar score (si es mayor a 0)
- 🏆 Ver leaderboard global
- 🔄 Reiniciar juego

### Leaderboard
- 📊 Top 20 mejores scores
- 🥇🥈🥉 Medallas para los 3 primeros lugares
- 📈 Muestra: posición, nombre, nivel, estrellas, puntuación
- 🔄 Botón de recarga
- 🎨 Diseño visual atractivo con tarjetas

## 🗄️ Configuración de Base de Datos Requerida

### ⚠️ IMPORTANTE: Debes crear la tabla en Supabase

1. Ve al dashboard de Supabase
2. Accede al SQL Editor
3. Ejecuta el script SQL que está en `SUPABASE_SETUP.md`

### Script SQL Básico:
```sql
CREATE TABLE scores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  player_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  level INTEGER NOT NULL,
  stars INTEGER NOT NULL CHECK (stars >= 0 AND stars <= 3),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

-- Permitir lectura a todos
CREATE POLICY "Scores are viewable by everyone"
  ON scores FOR SELECT USING (true);

-- Permitir inserción a todos
CREATE POLICY "Anyone can insert scores"
  ON scores FOR INSERT WITH CHECK (true);
```

## 🔐 Seguridad

- ✅ Row Level Security (RLS) habilitado
- ✅ Políticas configuradas para lectura e inserción pública
- ✅ Uso de anon key (segura para cliente)
- ✅ Validación de datos en la app
- ❌ No se permite modificar o eliminar scores

## 🚀 Cómo Usar

### 1. Configurar Supabase
```bash
# Lee el archivo SUPABASE_SETUP.md para instrucciones detalladas
```

### 2. Ejecutar la App
```bash
flutter run
```

### 3. Guardar un Score
- Juega hasta ganar o perder
- Presiona "GUARDAR SCORE"
- Ingresa tu nombre
- ¡Listo!

### 4. Ver Leaderboard
- Presiona el ícono 🏆 durante el juego, o
- Presiona "VER LEADERBOARD" después de ganar/perder

## 📊 Estructura de Datos

### Modelo Score
```dart
{
  id: UUID (auto-generado),
  playerName: String (máx. 20 caracteres),
  score: int,
  level: int (1-3),
  stars: int (0-3),
  createdAt: DateTime
}
```

## ⚡ Estado del Proyecto

### ✅ Completado
- Integración con Supabase
- Servicio de base de datos
- Pantalla de leaderboard
- Guardar y cargar scores
- Interfaz de usuario
- Documentación

### ⚠️ Advertencias Menores (no críticas)
- Algunos `print()` en lugar de logging framework
- Algunos campos podrían ser `final`
- APIs deprecadas en otros archivos

### 🔧 Pendiente (Opcional)
- Sistema de autenticación de usuarios
- Avatares de jugadores
- Filtros avanzados en leaderboard
- Estadísticas detalladas por jugador
- Compartir scores en redes sociales

## 🎉 ¡Todo Listo!

La integración con Supabase está completa. Solo necesitas:
1. Crear la tabla en Supabase (ver `SUPABASE_SETUP.md`)
2. Ejecutar la app
3. ¡Jugar y guardar tus scores!

## 📞 Soporte

Si encuentras problemas:
1. Verifica que la tabla `scores` existe en Supabase
2. Revisa que las credenciales en `lib/config/supabase_config.dart` sean correctas
3. Asegúrate de tener conexión a internet
4. Consulta `SUPABASE_SETUP.md` para solución de problemas

---
**Proyecto**: Angry Birds Clone  
**Base de Datos**: Supabase  
**Estado**: ✅ Integración Completada  
**Fecha**: 11 de noviembre de 2025
