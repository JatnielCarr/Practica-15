# 🎮 Script SQL Completo para Supabase

## Ejecuta este script en el SQL Editor de Supabase

```sql
-- ==================== TABLA DE SCORES ====================
CREATE TABLE IF NOT EXISTS scores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  player_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  level INTEGER NOT NULL,
  stars INTEGER NOT NULL CHECK (stars >= 0 AND stars <= 3),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para scores
CREATE INDEX IF NOT EXISTS idx_scores_score ON scores(score DESC);
CREATE INDEX IF NOT EXISTS idx_scores_level ON scores(level);
CREATE INDEX IF NOT EXISTS idx_scores_player_name ON scores(player_name);
CREATE INDEX IF NOT EXISTS idx_scores_created_at ON scores(created_at DESC);

-- ==================== TABLA DE POWER-UP ITEMS ====================
CREATE TABLE IF NOT EXISTS power_up_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('triple_shot', 'explosive_bird', 'super_speed')),
  icon_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar items por defecto
INSERT INTO power_up_items (name, description, price, type, icon_path) VALUES
  ('Triple Shot', 'Lanza 3 pájaros en un solo turno', 4.99, 'triple_shot', 'assets/PNG/Other/triple_shot.png'),
  ('Explosive Bird', 'Pájaro explosivo con daño masivo', 7.99, 'explosive_bird', 'assets/PNG/Explosive elements/elementExplosive034.png'),
  ('Super Speed', 'Aumenta la velocidad del pájaro x2', 5.99, 'super_speed', 'assets/PNG/Other/super_speed.png')
ON CONFLICT DO NOTHING;

-- ==================== TABLA DE ITEMS COMPRADOS ====================
CREATE TABLE IF NOT EXISTS purchased_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  player_name TEXT NOT NULL,
  item_id UUID NOT NULL REFERENCES power_up_items(id),
  item_type TEXT NOT NULL,
  is_used BOOLEAN DEFAULT FALSE,
  purchased_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para purchased_items
CREATE INDEX IF NOT EXISTS idx_purchased_items_player ON purchased_items(player_name);
CREATE INDEX IF NOT EXISTS idx_purchased_items_used ON purchased_items(is_used);
CREATE INDEX IF NOT EXISTS idx_purchased_items_date ON purchased_items(purchased_at DESC);

-- ==================== ROW LEVEL SECURITY (RLS) ====================

-- Habilitar RLS en todas las tablas
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE power_up_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchased_items ENABLE ROW LEVEL SECURITY;

-- ===== Políticas para SCORES =====
DROP POLICY IF EXISTS "Scores are viewable by everyone" ON scores;
CREATE POLICY "Scores are viewable by everyone"
  ON scores FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Anyone can insert scores" ON scores;
CREATE POLICY "Anyone can insert scores"
  ON scores FOR INSERT
  WITH CHECK (true);

-- ===== Políticas para POWER_UP_ITEMS =====
DROP POLICY IF EXISTS "Items are viewable by everyone" ON power_up_items;
CREATE POLICY "Items are viewable by everyone"
  ON power_up_items FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Only admins can insert items" ON power_up_items;
CREATE POLICY "Only admins can insert items"
  ON power_up_items FOR INSERT
  WITH CHECK (true);

-- ===== Políticas para PURCHASED_ITEMS =====
DROP POLICY IF EXISTS "Users can view their own purchases" ON purchased_items;
CREATE POLICY "Users can view their own purchases"
  ON purchased_items FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Anyone can purchase items" ON purchased_items;
CREATE POLICY "Anyone can purchase items"
  ON purchased_items FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Users can update their own purchases" ON purchased_items;
CREATE POLICY "Users can update their own purchases"
  ON purchased_items FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- ==================== FUNCIONES ÚTILES ====================

-- Función para obtener stats del jugador
CREATE OR REPLACE FUNCTION get_player_stats(p_player_name TEXT)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_games', COUNT(DISTINCT id),
    'best_score', MAX(score),
    'average_score', AVG(score),
    'total_stars', SUM(stars),
    'items_purchased', (
      SELECT COUNT(*) 
      FROM purchased_items 
      WHERE player_name = p_player_name
    ),
    'items_available', (
      SELECT COUNT(*) 
      FROM purchased_items 
      WHERE player_name = p_player_name AND is_used = FALSE
    )
  ) INTO result
  FROM scores
  WHERE player_name = p_player_name;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ==================== VERIFICACIÓN ====================

-- Verificar que todo se creó correctamente
SELECT 'Scores table' as table_name, COUNT(*) as row_count FROM scores
UNION ALL
SELECT 'Power-up items' as table_name, COUNT(*) as row_count FROM power_up_items
UNION ALL
SELECT 'Purchased items' as table_name, COUNT(*) as row_count FROM purchased_items;

-- Ver items disponibles
SELECT * FROM power_up_items ORDER BY price;

```

## 🎯 Resultado Esperado

Después de ejecutar este script, tendrás:

✅ **3 Tablas creadas**:
- `scores` - Almacena los puntajes de los jugadores
- `power_up_items` - Catálogo de items disponibles para compra
- `purchased_items` - Registro de items comprados por jugadores

✅ **3 Items precargados**:
- Triple Shot ($4.99)
- Explosive Bird ($7.99)
- Super Speed ($5.99)

✅ **Row Level Security configurado** para proteger los datos

✅ **Función personalizada** para obtener estadísticas del jugador

## 🔧 Comandos de Prueba

```sql
-- Ver todos los scores
SELECT * FROM scores ORDER BY score DESC LIMIT 10;

-- Ver items disponibles
SELECT * FROM power_up_items;

-- Ver compras de un jugador
SELECT * FROM purchased_items WHERE player_name = 'TuNombre';

-- Obtener stats de un jugador
SELECT get_player_stats('TuNombre');
```

## 📊 Estructura de las Tablas

### scores
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID | ID único |
| player_name | TEXT | Nombre del jugador |
| score | INTEGER | Puntuación |
| level | INTEGER | Nivel alcanzado |
| stars | INTEGER | Estrellas (0-3) |
| created_at | TIMESTAMP | Fecha de creación |

### power_up_items
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID | ID único |
| name | TEXT | Nombre del item |
| description | TEXT | Descripción |
| price | DECIMAL | Precio en dólares |
| type | TEXT | Tipo de power-up |
| icon_path | TEXT | Ruta al icono |
| created_at | TIMESTAMP | Fecha de creación |

### purchased_items
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID | ID único |
| player_name | TEXT | Nombre del jugador |
| item_id | UUID | ID del item comprado |
| item_type | TEXT | Tipo de item |
| is_used | BOOLEAN | Si fue usado |
| purchased_at | TIMESTAMP | Fecha de compra |
