-- =========================================================
-- BugaReport — Storage Bucket para fotos de reportes
-- Ejecutar en: Supabase Dashboard > SQL Editor
-- =========================================================
-- Este script SOLO crea el bucket y las políticas de acceso.
-- NO toca ninguna tabla. Es seguro ejecutarlo varias veces.
-- =========================================================

-- 1. Crear el bucket público 'reportes-fotos' (si no existe)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'reportes-fotos',
  'reportes-fotos',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 2. Limpiar políticas anteriores (por si se ejecutó antes)
DROP POLICY IF EXISTS "Ciudadanos autenticados suben fotos" ON storage.objects;
DROP POLICY IF EXISTS "Fotos públicas visibles"             ON storage.objects;
DROP POLICY IF EXISTS "Ciudadanos eliminan sus propias fotos" ON storage.objects;

-- 3. Política: usuarios autenticados pueden SUBIR fotos
CREATE POLICY "Ciudadanos autenticados suben fotos"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'reportes-fotos'
    AND auth.uid() IS NOT NULL
  );

-- 4. Política: cualquiera puede VER las fotos (mapa público)
CREATE POLICY "Fotos públicas visibles"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'reportes-fotos');

-- 5. Política: solo el dueño puede ELIMINAR su foto
CREATE POLICY "Ciudadanos eliminan sus propias fotos"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'reportes-fotos'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

-- Verificación (resultado esperado: 1 fila con id = 'reportes-fotos')
SELECT id, name, public, file_size_limit FROM storage.buckets WHERE id = 'reportes-fotos';
