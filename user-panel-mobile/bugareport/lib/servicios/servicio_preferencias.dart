import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bugareport/servicios/servicio_notificaciones.dart';
import 'package:bugareport/servicios/servicio_logger.dart';

/// Servicio de preferencias y configuración persistente del ciudadano.
///
/// Centraliza todos los toggles que el usuario puede cambiar en Ajustes.
/// Persiste en [SharedPreferences] (local, offline, gratuito).
class ServicioPreferencias {
  ServicioPreferencias._();
  static final ServicioPreferencias instancia = ServicioPreferencias._();

  // ── Claves SharedPreferences ──
  static const _claveNotifReportes = 'br_notif_reportes';
  static const _claveNotifMantenimiento = 'br_notif_mantenimiento';
  static const _claveNotifAlcaldia = 'br_notif_alcaldia';

  // ── URL de descarga directa (actualización) ──
  /// Cambia esta URL cuando publiques una nueva versión.
  static const String urlDescargaApk =
      'https://github.com/AndresGonzalezDev444/bugareport/releases/latest';

  // ═══════════════════════════════════════════════════════
  // NOTIFICACIONES
  // ═══════════════════════════════════════════════════════

  Future<bool> notificacionesReportesActivas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_claveNotifReportes) ?? true; // activo por defecto
  }

  Future<bool> notificacionesMantenimientoActivas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_claveNotifMantenimiento) ?? true;
  }

  Future<bool> notificacionesAlcaldiaActivas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_claveNotifAlcaldia) ?? false; // inactivo por defecto
  }

  /// Activa/desactiva notificaciones de estado de reportes.
  Future<void> setNotificacionesReportes(bool activo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveNotifReportes, activo);

    if (!activo) {
      // Cancelar notificaciones pendientes de este canal
      await ServicioNotificaciones.instancia.cancelarTodas();
      ServicioLogger.info('Notificaciones de reportes desactivadas', componente: 'Preferencias');
    } else {
      // Solicitar permiso si aún no se ha concedido
      await ServicioNotificaciones.instancia.solicitarPermiso();
      ServicioLogger.info('Notificaciones de reportes activadas', componente: 'Preferencias');
    }
  }

  Future<void> setNotificacionesMantenimiento(bool activo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveNotifMantenimiento, activo);
  }

  Future<void> setNotificacionesAlcaldia(bool activo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveNotifAlcaldia, activo);
  }

  // ═══════════════════════════════════════════════════════
  // INFORMACIÓN DE LA APP
  // ═══════════════════════════════════════════════════════

  /// Obtiene la versión instalada: "1.0.0 (build 1)".
  Future<String> obtenerVersionApp() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (build ${info.buildNumber})';
  }

  /// Compara versión instalada vs. versión remota.
  /// En v1 siempre retorna "al día" — sin servidor de versiones.
  Future<EstadoActualizacion> verificarActualizacion() async {
    // En el futuro: llamar a un endpoint que retorne la versión más reciente
    // Por ahora, retornamos estado desconocido para invitar a descargar
    return EstadoActualizacion.alDia;
  }
}

/// Estado de actualización de la app.
enum EstadoActualizacion {
  alDia,
  disponible,
  desconocido,
}
