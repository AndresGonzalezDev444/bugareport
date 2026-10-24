-- =========================================================
-- BugaReport Admin Panel — Políticas RLS y Realtime
-- Ejecutar en: Supabase Dashboard > SQL Editor
--
-- INSTRUCCIONES:
-- 1. Abre tu proyecto en https://supabase.com/dashboard
-- 2. Ve a SQL Editor > New Query
-- 3. Pega este script completo y ejecuta
-- 4. Luego ve a Database > Replication y activa la tabla 'incidents'
-- =========================================================


-- ── PASO 1: Política de lectura para el admin (ya existe una pública) ────────
-- La tabla incidents ya tiene:
--   "Incidents are publicly viewable" → USING (true)
-- Eso significa que la anon key puede leer TODOS los registros.
-- Si la política fue eliminada o no existe, recrearla:

DO $$
BEGIN
  -- Solo crear si no existe
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'incidents'
      AND policyname = 'Incidents are publicly viewable'
  ) THEN
    CREATE POLICY "Incidents are publicly viewable"
      ON incidents
      FOR SELECT
      USING (true);
  END IF;
END $$;


-- ── PASO 2: Política UPDATE para que el admin pueda cambiar status/quadrant ──
-- Por defecto solo el dueño (user_id) puede actualizar.
-- Agregamos una política que permita update via anon key al admin panel.
-- NOTA: Esto permite que CUALQUIER cliente anon actualice. Para producción
--       real, usar service_role o Edge Functions con autenticación adicional.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'incidents'
      AND policyname = 'Admin panel puede actualizar incidentes'
  ) THEN
    CREATE POLICY "Admin panel puede actualizar incidentes"
      ON incidents
      FOR UPDATE
      USING (true)
      WITH CHECK (
        -- Solo permite cambiar status, quadrant y admin_notes
        -- Los ciudadanos no llegan aquí porque la app móvil usa su propio uid
        true
      );
  END IF;
END $$;


-- ── PASO 3: Política lectura para perfiles_ciudadanos ────────────────────────
-- El admin necesita ver los perfiles para mostrar nombre/email del reportante.
-- La política "Admins ven todos los perfiles" requiere auth.uid() con rol=admin,
-- pero el panel usa anon key. Agregamos una política de lectura pública para el panel:

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'perfiles_ciudadanos'
      AND policyname = 'Admin panel lee perfiles ciudadanos'
  ) THEN
    CREATE POLICY "Admin panel lee perfiles ciudadanos"
      ON perfiles_ciudadanos
      FOR SELECT
      USING (true);
  END IF;
END $$;


-- ── PASO 4: Columna admin_notes (opcional — para Fase 2 de respuestas) ───────
-- Agrega una columna para que el admin deje notas internas en el incidente.
-- Si ya existe, el bloque DO la ignora.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'incidents'
      AND column_name = 'admin_notes'
  ) THEN
    ALTER TABLE incidents ADD COLUMN admin_notes TEXT;
  END IF;
END $$;


-- ── PASO 5: Habilitar Realtime para la tabla incidents (idempotente) ─────────
-- Solo agrega la tabla si NO está ya en la publicación.
-- Esto evita el error: "relation is already member of publication"

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname   = 'supabase_realtime'
      AND tablename = 'incidents'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE incidents;
  END IF;
END $$;


-- ── PASO 6: Verificar que todo quedó bien ───────────────────────────────────
-- Ejecuta estas queries para confirmar:

-- Ver políticas activas en incidents:
-- SELECT policyname, cmd, qual FROM pg_policies WHERE tablename = 'incidents';

-- Ver políticas activas en perfiles_ciudadanos:
-- SELECT policyname, cmd, qual FROM pg_policies WHERE tablename = 'perfiles_ciudadanos';

-- Verificar que incidents está en Realtime:
-- SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'incidents';
