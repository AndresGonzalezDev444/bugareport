-- =========================================================
-- BugaReport — Habilitar Realtime en tabla incidents
-- Ejecutar en: Supabase Dashboard > SQL Editor
-- =========================================================
-- Esto permite que la app reciba actualizaciones en tiempo
-- real cuando se crean o cambian incidentes (como Waze).
-- =========================================================

-- Opción A: Habilitar Realtime por SQL
ALTER PUBLICATION supabase_realtime ADD TABLE incidents;

-- Verificación (debe aparecer 'incidents' en la lista):
SELECT tablename FROM pg_publication_tables WHERE pubname = 'supabase_realtime';
