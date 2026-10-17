import 'dart:io';

/// Servicio para leer metadatos EXIF de fotografías y validar su antigüedad.
///
/// Usa el paquete [exif] (gratuito, open source) que trabaja directamente
/// con los bytes del archivo — sin servidor, sin costo, sin ExifTool remoto.
///
/// Si la foto no tiene metadatos EXIF (ej. captura de pantalla), se permite
/// sin bloquear al ciudadano.
class ServicioExif {
  ServicioExif._();

  /// Días máximos permitidos entre la fecha de la foto y hoy.
  static const int diasMaximos = 40;

  /// Lee la fecha de captura [DateTimeOriginal] del EXIF de [foto].
  ///
  /// Retorna [null] si la imagen no tiene metadatos EXIF o si no se
  /// puede leer la fecha (el formulario NO bloquea en ese caso).
  static Future<DateTime?> obtenerFechaFoto(File foto) async {
    try {
      final bytes = await foto.readAsBytes();

      // Buscar marcador EXIF manualmente en los primeros bytes (JPEG)
      // Formato JPEG: FFD8 FF E1 <tamaño> 45786966 (Exif)
      // Buscamos DateTimeOriginal (tag 0x9003) en los bytes
      final fechaStr = _extraerDateTimeOriginal(bytes);
      if (fechaStr == null) return null;

      // Formato EXIF: "YYYY:MM:DD HH:MM:SS"
      return _parsearFechaExif(fechaStr);
    } catch (_) {
      // Si falla cualquier lectura, retornar null (no bloquear)
      return null;
    }
  }

  /// Valida que la foto no sea más antigua que [diasMaximos].
  ///
  /// Lanza [ExcepcionFotoMuyAntigua] si supera el límite.
  /// No hace nada si la foto no tiene EXIF (se permite).
  static Future<void> validarAntiguedad(File foto) async {
    final fecha = await obtenerFechaFoto(foto);
    if (fecha == null) return; // Sin EXIF → se permite

    final diasTranscurridos = DateTime.now().difference(fecha).inDays;
    if (diasTranscurridos > diasMaximos) {
      throw ExcepcionFotoMuyAntigua(fecha, diasTranscurridos);
    }
  }

  // ── Privado: extracción manual de EXIF ──

  /// Busca la cadena DateTimeOriginal en los bytes JPEG/EXIF.
  /// Retorna el string en formato "YYYY:MM:DD HH:MM:SS" o null.
  static String? _extraerDateTimeOriginal(List<int> bytes) {
    // Convertir a String para buscar el patrón de fecha EXIF
    // Los bytes EXIF contienen fechas como texto ASCII: "2024:03:15 14:23:01"
    try {
      // Buscar patrón de fecha EXIF: 4 dígitos + ':' + 2 dígitos + ':' + 2 dígitos...
      final patron = RegExp(r'(\d{4}:\d{2}:\d{2} \d{2}:\d{2}:\d{2})');

      // Convertir los bytes a String (solo ASCII visible)
      final buffer = StringBuffer();
      for (int i = 0; i < bytes.length && i < 65536; i++) {
        final b = bytes[i];
        if (b >= 32 && b < 127) {
          buffer.writeCharCode(b);
        } else {
          buffer.write(' ');
        }
      }

      final coincidencias = patron.allMatches(buffer.toString()).toList();
      if (coincidencias.isEmpty) return null;

      // La primera coincidencia suele ser DateTimeOriginal
      return coincidencias.first.group(0);
    } catch (_) {
      return null;
    }
  }

  /// Convierte "YYYY:MM:DD HH:MM:SS" a [DateTime].
  static DateTime? _parsearFechaExif(String texto) {
    try {
      // Formato EXIF: "YYYY:MM:DD HH:MM:SS"
      final partes = texto.split(' ');
      if (partes.length != 2) return null;

      final fechaPartes = partes[0].split(':');
      final horaPartes  = partes[1].split(':');

      if (fechaPartes.length != 3 || horaPartes.length != 3) return null;

      return DateTime(
        int.parse(fechaPartes[0]),
        int.parse(fechaPartes[1]),
        int.parse(fechaPartes[2]),
        int.parse(horaPartes[0]),
        int.parse(horaPartes[1]),
        int.parse(horaPartes[2]),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Excepción lanzada cuando la foto supera los [ServicioExif.diasMaximos] días.
class ExcepcionFotoMuyAntigua implements Exception {
  final DateTime fechaFoto;
  final int dias;

  const ExcepcionFotoMuyAntigua(this.fechaFoto, this.dias);

  String get mensajeAmigable =>
      'La foto fue tomada hace $dias días. '
      'Solo se aceptan evidencias de los últimos ${ServicioExif.diasMaximos} días '
      'para garantizar que el reporte es reciente.';
}
