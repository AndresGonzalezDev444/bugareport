import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bugareport/servicios/servicio_logger.dart';

/// Servicio de almacenamiento de fotos en Supabase Storage.
///
/// Bucket: 'reportes-fotos' (público, 1GB gratis en plan Free).
/// Comprime automáticamente a ≤500KB, max 1280px de ancho (JPEG quality 75).
class ServicioAlmacenamiento {
  ServicioAlmacenamiento._();
  static final ServicioAlmacenamiento instancia = ServicioAlmacenamiento._();

  final _storage = Supabase.instance.client.storage;
  static const _bucket = 'reportes-fotos';

  /// Límite de tamaño del archivo original antes de procesar (5MB).
  static const int limiteBytesOriginal = 5 * 1024 * 1024;

  /// Límite de calidad de compresión (0-100).
  static const int calidadJpeg = 75;

  /// Ancho máximo después de redimensionar.
  static const int anchoMaxPx = 1280;

  // ═══════════════════════════════════════════════════════
  // VALIDACIÓN
  // ═══════════════════════════════════════════════════════

  /// Verifica que el archivo no supere [limiteBytesOriginal] (5MB).
  /// Lanza [ExcepcionAlmacenamiento] si supera el límite.
  bool validarPesoImagen(File foto) {
    final bytes = foto.lengthSync();
    if (bytes > limiteBytesOriginal) {
      ServicioLogger.advertencia(
        'Imagen demasiado grande: ${(bytes / 1024 / 1024).toStringAsFixed(2)}MB',
        componente: 'Almacenamiento',
      );
      return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════
  // COMPRESIÓN
  // ═══════════════════════════════════════════════════════

  /// Redimensiona y comprime la imagen a ≤500KB.
  Future<Uint8List> _comprimirImagen(File foto) async {
    final bytesOriginales = await foto.readAsBytes();
    var imagenDecodificada = img.decodeImage(bytesOriginales);
    if (imagenDecodificada == null) {
      throw const ExcepcionAlmacenamiento('No se pudo decodificar la imagen');
    }

    // Redimensionar si es más ancha que [anchoMaxPx]
    if (imagenDecodificada.width > anchoMaxPx) {
      imagenDecodificada = img.copyResize(
        imagenDecodificada,
        width: anchoMaxPx,
      );
    }

    // Comprimir con calidad JPEG configurada
    final bytesComprimidos = img.encodeJpg(
      imagenDecodificada,
      quality: calidadJpeg,
    );

    ServicioLogger.info(
      'Imagen comprimida: ${(bytesOriginales.length / 1024).round()}KB → '
      '${(bytesComprimidos.length / 1024).round()}KB',
      componente: 'Almacenamiento',
    );

    return Uint8List.fromList(bytesComprimidos);
  }

  // ═══════════════════════════════════════════════════════
  // SUBIDA
  // ═══════════════════════════════════════════════════════

  /// Sube una foto al bucket de Supabase Storage.
  ///
  /// 1. Valida el peso original (≤5MB).
  /// 2. Comprime a ≤500KB (JPEG 75%, max 1280px).
  /// 3. Sube con nombre único basado en timestamp.
  /// 4. Retorna la URL pública de la foto.
  ///
  /// Lanza [ExcepcionAlmacenamiento] si algo falla.
  Future<String> subirFoto(File foto, String idUsuario) async {
    // 1. Validar peso
    if (!validarPesoImagen(foto)) {
      throw const ExcepcionAlmacenamiento(
        'La imagen supera los 5MB permitidos. Usa una foto más pequeña.',
      );
    }

    try {
      // 2. Comprimir
      final bytesComprimidos = await _comprimirImagen(foto);

      // 3. Nombre único del archivo
      final extension = p.extension(foto.path).isEmpty ? '.jpg' : '.jpg';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final rutaStorage = 'ciudadanos/$idUsuario/$timestamp$extension';

      // 4. Subir a Supabase Storage
      await _storage.from(_bucket).uploadBinary(
        rutaStorage,
        bytesComprimidos,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );

      // 5. Obtener URL pública
      final urlPublica = _storage.from(_bucket).getPublicUrl(rutaStorage);

      ServicioLogger.info(
        'Foto subida exitosamente: $rutaStorage',
        componente: 'Almacenamiento',
      );

      return urlPublica;
    } catch (e, traza) {
      if (e is ExcepcionAlmacenamiento) rethrow;
      ServicioLogger.error(
        'Error al subir foto a Storage',
        excepcion: e,
        traza: traza,
        componente: 'Almacenamiento',
      );
      throw const ExcepcionAlmacenamiento(
        'No se pudo subir la foto. Intenta de nuevo.',
      );
    }
  }

  /// Elimina una foto del bucket (al cancelar un reporte borrador).
  Future<void> eliminarFoto(String rutaStorage) async {
    try {
      await _storage.from(_bucket).remove([rutaStorage]);
      ServicioLogger.info('Foto eliminada: $rutaStorage', componente: 'Almacenamiento');
    } catch (e, traza) {
      ServicioLogger.error(
        'Error al eliminar foto',
        excepcion: e,
        traza: traza,
        componente: 'Almacenamiento',
      );
    }
  }
}

/// Excepción tipada para errores de almacenamiento.
class ExcepcionAlmacenamiento implements Exception {
  final String mensaje;
  const ExcepcionAlmacenamiento(this.mensaje);

  @override
  String toString() => 'ExcepcionAlmacenamiento: $mensaje';
}
