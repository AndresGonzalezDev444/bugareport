import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para guardar y recuperar un borrador local de reporte.
///
/// Persiste los campos de texto del formulario en [SharedPreferences].
/// La foto NO se guarda en binario — solo la ruta del archivo local.
/// Si la ruta ya no existe al recuperar, el usuario debe seleccionar
/// una nueva foto.
///
/// Solo existe un borrador a la vez (el más reciente).
class ServicioBorrador {
  ServicioBorrador._();
  static final ServicioBorrador instancia = ServicioBorrador._();

  // ── Claves ──
  static const String _claveTitulo      = 'borrador_titulo';
  static const String _claveDescripcion = 'borrador_descripcion';
  static const String _claveCategoria   = 'borrador_categoria';
  static const String _claveSeveridad   = 'borrador_severidad';
  static const String _claveRutaFoto    = 'borrador_ruta_foto';
  static const String _claveLatitud     = 'borrador_latitud';
  static const String _claveLongitud    = 'borrador_longitud';
  static const String _claveFechaGuardo = 'borrador_fecha_guardado';

  // ── Consultas ──

  /// Retorna [true] si hay un borrador guardado.
  Future<bool> tieneBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    final titulo = prefs.getString(_claveTitulo);
    return titulo != null && titulo.isNotEmpty;
  }

  /// Carga el borrador guardado. Retorna [null] si no existe.
  Future<Map<String, String?>?> cargarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    final titulo = prefs.getString(_claveTitulo);
    if (titulo == null || titulo.isEmpty) return null;

    return {
      'titulo'      : titulo,
      'descripcion' : prefs.getString(_claveDescripcion),
      'categoria'   : prefs.getString(_claveCategoria),
      'severidad'   : prefs.getString(_claveSeveridad),
      'rutaFoto'    : prefs.getString(_claveRutaFoto),
      'latitud'     : prefs.getString(_claveLatitud),
      'longitud'    : prefs.getString(_claveLongitud),
      'fechaGuardado': prefs.getString(_claveFechaGuardo),
    };
  }

  // ── Acciones ──

  /// Guarda el estado actual del formulario como borrador.
  Future<void> guardarBorrador({
    required String titulo,
    required String descripcion,
    required String categoria,
    required String severidad,
    String? rutaFoto,
    double? latitud,
    double? longitud,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_claveTitulo,      titulo),
      prefs.setString(_claveDescripcion, descripcion),
      prefs.setString(_claveCategoria,   categoria),
      prefs.setString(_claveSeveridad,   severidad),
      prefs.setString(_claveFechaGuardo, DateTime.now().toIso8601String()),
      if (rutaFoto != null)
        prefs.setString(_claveRutaFoto, rutaFoto)
      else
        prefs.remove(_claveRutaFoto),
      if (latitud != null)
        prefs.setString(_claveLatitud, latitud.toString())
      else
        prefs.remove(_claveLatitud),
      if (longitud != null)
        prefs.setString(_claveLongitud, longitud.toString())
      else
        prefs.remove(_claveLongitud),
    ]);
  }

  /// Elimina el borrador guardado (al enviar exitosamente o al descartar).
  Future<void> descartarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_claveTitulo),
      prefs.remove(_claveDescripcion),
      prefs.remove(_claveCategoria),
      prefs.remove(_claveSeveridad),
      prefs.remove(_claveRutaFoto),
      prefs.remove(_claveLatitud),
      prefs.remove(_claveLongitud),
      prefs.remove(_claveFechaGuardo),
    ]);
  }
}
