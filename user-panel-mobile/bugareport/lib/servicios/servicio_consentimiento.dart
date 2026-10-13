import 'package:shared_preferences/shared_preferences.dart';

/// Servicio que persiste localmente el consentimiento del ciudadano
/// a los Términos y Condiciones de BugaReport.
///
/// Usa [SharedPreferences] (almacenamiento clave-valor del dispositivo).
/// El dato persiste entre sesiones y reinicios de la app.
class ServicioConsentimiento {
  ServicioConsentimiento._();
  static final ServicioConsentimiento instancia = ServicioConsentimiento._();

  static const String _claveConsentimiento = 'bugareport_acepto_terminos';
  static const String _claveVersionAceptada = 'bugareport_version_terminos';
  static const String _versionActual = '1.0';

  // ── Consultas ──

  /// Retorna `true` si el ciudadano ya aceptó los términos en esta versión.
  Future<bool> haAceptadoTerminos() async {
    final prefs = await SharedPreferences.getInstance();
    final acepto = prefs.getBool(_claveConsentimiento) ?? false;
    final versionAceptada = prefs.getString(_claveVersionAceptada) ?? '';
    // Si la versión cambió, debe aceptar de nuevo
    return acepto && versionAceptada == _versionActual;
  }

  // ── Acciones ──

  /// Guarda el consentimiento del ciudadano con la versión actual.
  Future<void> aceptarTerminos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveConsentimiento, true);
    await prefs.setString(_claveVersionAceptada, _versionActual);
  }

  /// Revoca el consentimiento (para uso en pantalla de perfil).
  /// Después de revocar, el usuario verá la pantalla de términos al abrir la app.
  Future<void> revocarConsentimiento() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveConsentimiento);
    await prefs.remove(_claveVersionAceptada);
  }
}
