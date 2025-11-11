# Configuración de Supabase para Angry Birds Clone

## 📋 Requisitos Previos

- Cuenta en Supabase (https://supabase.com)
- Proyecto creado en Supabase
- Credenciales del proyecto (ya configuradas en el código)

## 🗄️ Crear la Tabla en Supabase

### Paso 1: Acceder al SQL Editor

1. Ve a tu proyecto en Supabase: https://qbhbsjfheatoekjluuxe.supabase.co
2. En el menú lateral, selecciona **SQL Editor**
3. Crea una nueva query

### Paso 2: Ejecutar el Script SQL

Copia y pega el siguiente script SQL y ejecútalo:

```sql
-- Crear tabla de scores
CREATE TABLE IF NOT EXISTS scores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  player_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  level INTEGER NOT NULL,
  stars INTEGER NOT NULL CHECK (stars >= 0 AND stars <= 3),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para mejorar el rendimiento
CREATE INDEX idx_scores_score ON scores(score DESC);
CREATE INDEX idx_scores_level ON scores(level);
CREATE INDEX idx_scores_player_name ON scores(player_name);
CREATE INDEX idx_scores_created_at ON scores(created_at DESC);

-- Habilitar Row Level Security (RLS)
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

-- Política: Permitir a todos leer los scores
CREATE POLICY "Scores are viewable by everyone"
  ON scores FOR SELECT
  USING (true);

-- Política: Permitir a todos insertar scores
CREATE POLICY "Anyone can insert scores"
  ON scores FOR INSERT
  WITH CHECK (true);
```

### Paso 3: Verificar la Tabla

Para verificar que la tabla se creó correctamente:

```sql
SELECT * FROM scores LIMIT 10;
```

## 🔐 Configuración de Seguridad

### Row Level Security (RLS)

Las políticas configuradas permiten:
- ✅ **Lectura**: Todos pueden ver los scores (leaderboard público)
- ✅ **Inserción**: Todos pueden guardar nuevos scores
- ❌ **Actualización**: No se permite modificar scores existentes
- ❌ **Eliminación**: No se permite borrar scores

### API Key

El proyecto usa la **anon key** (pública) que está configurada en:
```
lib/config/supabase_config.dart
```

Esta key es segura para usar en el cliente porque RLS protege la tabla.

## 🧪 Probar la Integración

### Insertar un Score de Prueba

```sql
INSERT INTO scores (player_name, score, level, stars)
VALUES ('Test Player', 5000, 1, 3);
```

### Ver el Leaderboard

```sql
SELECT 
  player_name,
  score,
  level,
  stars,
  created_at
FROM scores
ORDER BY score DESC
LIMIT 10;
```

## 📱 Uso en la App

### Guardar un Score

Después de ganar o perder:
1. Presiona el botón **"GUARDAR SCORE"**
2. Ingresa tu nombre
3. El score se guardará automáticamente en Supabase

### Ver el Leaderboard

- Durante el juego: Presiona el ícono 🏆 en la esquina superior derecha
- Después de ganar/perder: Presiona **"VER LEADERBOARD"**

## 🔧 Solución de Problemas

### Error de Conexión

Si la app no puede conectarse a Supabase:

1. Verifica que las credenciales en `lib/config/supabase_config.dart` sean correctas
2. Verifica tu conexión a internet
3. Asegúrate de que la tabla `scores` existe
4. Revisa que RLS esté habilitado y las políticas creadas

### Verificar Conexión

La app verifica automáticamente la conexión al iniciar. Si hay problemas, verás un mensaje de error.

## 📊 Estructura de la Tabla

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | UUID | Identificador único (generado automáticamente) |
| `player_name` | TEXT | Nombre del jugador (máx. 20 caracteres) |
| `score` | INTEGER | Puntuación obtenida |
| `level` | INTEGER | Nivel alcanzado (1, 2, 3) |
| `stars` | INTEGER | Estrellas obtenidas (0-3) |
| `created_at` | TIMESTAMP | Fecha y hora del registro |

## 🚀 Características Implementadas

- ✅ Guardar scores en la nube
- ✅ Leaderboard global (top 20)
- ✅ Filtrar scores por nivel
- ✅ Ver mejor score personal
- ✅ Interfaz visual del leaderboard
- ✅ Validación de datos
- ✅ Manejo de errores

## 📝 Notas Adicionales

- Los scores se ordenan automáticamente de mayor a menor
- El leaderboard muestra los top 20 scores
- Los scores duplicados están permitidos
- La tabla usa timestamps con zona horaria
- Los índices mejoran la velocidad de consulta

## 🔗 Enlaces Útiles

- **Dashboard de Supabase**: https://app.supabase.com/project/qbhbsjfheatoekjluuxe
- **Documentación de Supabase**: https://supabase.com/docs
- **Flutter + Supabase**: https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
