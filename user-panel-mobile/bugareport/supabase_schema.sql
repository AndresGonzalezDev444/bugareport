-- =========================================================
-- BugaReport — Supabase Schema
-- Ejecutar en: Supabase Dashboard > SQL Editor
-- =========================================================

-- Tabla principal de incidentes ciudadanos
CREATE TABLE IF NOT EXISTS incidents (
  id           UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id      UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  category     TEXT        NOT NULL CHECK (category IN (
                             'hueco_via',
                             'servicios_publicos',
                             'comunitario',
                             'aseo_parques'
                           )),
  severity     TEXT        NOT NULL DEFAULT 'media' CHECK (severity IN (
                             'critico', 'alta', 'media', 'baja'
                           )),
  title        TEXT        NOT NULL,
  description  TEXT,
  latitude     DOUBLE PRECISION NOT NULL,
  longitude    DOUBLE PRECISION NOT NULL,
  photo_url    TEXT,
  status       TEXT        NOT NULL DEFAULT 'pendiente' CHECK (status IN (
                             'pendiente', 'en_proceso', 'resuelto'
                           )),
  quadrant     TEXT,
  address      TEXT,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- ── Índices para consultas rápidas ──
CREATE INDEX IF NOT EXISTS idx_incidents_status
  ON incidents (status);

CREATE INDEX IF NOT EXISTS idx_incidents_location
  ON incidents (latitude, longitude);

CREATE INDEX IF NOT EXISTS idx_incidents_user
  ON incidents (user_id);

CREATE INDEX IF NOT EXISTS idx_incidents_category
  ON incidents (category);

CREATE INDEX IF NOT EXISTS idx_incidents_created_at
  ON incidents (created_at DESC);

-- ── Función para auto-actualizar updated_at ──
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_incidents_updated_at
  BEFORE UPDATE ON incidents
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ── Row Level Security (RLS) ──
ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;

-- Cualquier persona puede VER los incidentes activos (como Waze)
CREATE POLICY "Incidents are publicly viewable"
  ON incidents
  FOR SELECT
  USING (true);

-- Solo usuarios autenticados pueden CREAR reportes
CREATE POLICY "Authenticated users can create incidents"
  ON incidents
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Los usuarios solo pueden ACTUALIZAR sus propios reportes
CREATE POLICY "Users can update their own incidents"
  ON incidents
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Los usuarios pueden ELIMINAR solo sus propios reportes
CREATE POLICY "Users can delete their own incidents"
  ON incidents
  FOR DELETE
  USING (auth.uid() = user_id);

-- ── Habilitar Realtime para actualizaciones en vivo ──
-- (Ejecutar en Supabase: Database > Replication > Activar tabla incidents)
-- O correr esto:
ALTER PUBLICATION supabase_realtime ADD TABLE incidents;


-- =========================================================
-- TABLA: perfiles_ciudadanos
-- Perfil extendido del ciudadano, vinculado a auth.users
-- =========================================================

CREATE TABLE IF NOT EXISTS perfiles_ciudadanos (
  id                   UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre_completo      TEXT        NOT NULL,
  tipo_documento       TEXT        NOT NULL DEFAULT 'CC'
                                   CHECK (tipo_documento IN ('CC','TI','CE','PEP')),
  numero_documento     TEXT        NOT NULL UNIQUE,
  celular              TEXT,
  email                TEXT,
  comuna               TEXT,
  latitud_residencia   DOUBLE PRECISION,
  longitud_residencia  DOUBLE PRECISION,
  rol                  TEXT        NOT NULL DEFAULT 'ciudadano'
                                   CHECK (rol IN ('ciudadano','admin')),
  creado_en            TIMESTAMPTZ DEFAULT now(),
  actualizado_en       TIMESTAMPTZ DEFAULT now()
);

-- ── Índices ──
CREATE INDEX IF NOT EXISTS idx_perfiles_numero_doc
  ON perfiles_ciudadanos (numero_documento);

CREATE INDEX IF NOT EXISTS idx_perfiles_rol
  ON perfiles_ciudadanos (rol);

CREATE INDEX IF NOT EXISTS idx_perfiles_email
  ON perfiles_ciudadanos (email);

-- ── Auto-actualizar updated_at ──
CREATE TRIGGER update_perfiles_updated_at
  BEFORE UPDATE ON perfiles_ciudadanos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ── Row Level Security ──
ALTER TABLE perfiles_ciudadanos ENABLE ROW LEVEL SECURITY;

-- Cada ciudadano puede ver y editar solo su propio perfil
CREATE POLICY "Ciudadanos ven su propio perfil"
  ON perfiles_ciudadanos
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Ciudadanos crean su perfil"
  ON perfiles_ciudadanos
  FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Ciudadanos actualizan su perfil"
  ON perfiles_ciudadanos
  FOR UPDATE
  USING (auth.uid() = id);

-- Los admins pueden ver todos los perfiles (para el panel web)
CREATE POLICY "Admins ven todos los perfiles"
  ON perfiles_ciudadanos
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM perfiles_ciudadanos p
      WHERE p.id = auth.uid() AND p.rol = 'admin'
    )
  );

