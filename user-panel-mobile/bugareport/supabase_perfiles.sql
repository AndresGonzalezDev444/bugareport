-- =========================================================
-- BugaReport — SOLO ejecutar si ya tienes la tabla incidents
-- Agrega únicamente la tabla perfiles_ciudadanos
-- =========================================================

-- La función puede no existir si la primera ejecución falló a medias.
-- La creamos aquí con OR REPLACE para que no falle si ya existe:
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.actualizado_en = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Solo necesitamos crear perfiles_ciudadanos:

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

-- Índices
CREATE INDEX IF NOT EXISTS idx_perfiles_numero_doc
  ON perfiles_ciudadanos (numero_documento);

CREATE INDEX IF NOT EXISTS idx_perfiles_rol
  ON perfiles_ciudadanos (rol);

CREATE INDEX IF NOT EXISTS idx_perfiles_email
  ON perfiles_ciudadanos (email);

-- Trigger (reutiliza la función que ya existe)
CREATE TRIGGER update_perfiles_updated_at
  BEFORE UPDATE ON perfiles_ciudadanos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE perfiles_ciudadanos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Ciudadanos ven su propio perfil"
  ON perfiles_ciudadanos FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Ciudadanos crean su perfil"
  ON perfiles_ciudadanos FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Ciudadanos actualizan su perfil"
  ON perfiles_ciudadanos FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Admins ven todos los perfiles"
  ON perfiles_ciudadanos FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM perfiles_ciudadanos p
      WHERE p.id = auth.uid() AND p.rol = 'admin'
    )
  );
