/// Logger interno de BugaReport.
///
/// Escribe mensajes de depuración y errores en la consola con formato
/// consistente: timestamp + nivel + componente + mensaje.
///
/// En v1 usa [debugPrint] (visible en Android Studio / flutter run).
/// En el futuro se puede agregar Sentry o Firebase Crashlytics
/// sin cambiar la API pública.
class ServicioLogger {
  ServicioLogger._();

  static bool _habilitado = true;

  /// Habilita o deshabilita el logger (para tests).
  static void configurar({bool habilitado = true}) {
    _habilitado = habilitado;
  }

  /// Mensaje informativo — flujo normal de la app.
  static void info(
    String mensaje, {
    String? componente,
  }) {
    if (!_habilitado) return;
    // ignore: avoid_print
    print('[INFO][${_ahora()}]${_comp(componente)} $mensaje');
  }

  /// Advertencia — algo no ideal pero la app puede continuar.
  static void advertencia(
    String mensaje, {
    String? componente,
  }) {
    if (!_habilitado) return;
    // ignore: avoid_print
    print('[WARN][${_ahora()}]${_comp(componente)} $mensaje');
  }

  /// Error técnico — se registra con traza completa para el desarrollador.
  /// Al ciudadano NUNCA se le muestra este mensaje.
  static void error(
    String mensaje, {
    Object? excepcion,
    StackTrace? traza,
    String? componente,
  }) {
    if (!_habilitado) return;
    final buffer = StringBuffer()
      ..write('[ERROR][${_ahora()}]${_comp(componente)} $mensaje');

    if (excepcion != null) {
      buffer.write('\n  → Excepción: $excepcion');
    }
    if (traza != null) {
      // Solo las primeras 5 líneas de la traza para no saturar los logs
      final lineas = traza.toString().split('\n').take(5).join('\n  ');
      buffer.write('\n  → Traza:\n  $lineas');
    }
    // ignore: avoid_print
    print(buffer.toString());
  }

  // ── Helpers privados ──

  static String _ahora() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  static String _comp(String? componente) {
    return componente != null ? '[$componente]' : '';
  }
}
