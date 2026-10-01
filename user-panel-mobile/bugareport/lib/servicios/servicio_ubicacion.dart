import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:bugareport/config/constantes_app.dart';

/// Servicio para obtener la ubicación GPS del dispositivo.
/// Solicita permisos en tiempo de ejecución y retorna la posición actual.
class ServicioUbicacion {
  ServicioUbicacion._();
  static final ServicioUbicacion instancia = ServicioUbicacion._();

  // ── Verificar y solicitar permisos ──

  /// Verifica si el servicio de ubicación está habilitado
  /// y si se tienen los permisos necesarios. Solicita permisos si no se tienen aún.
  /// Retorna `true` si se puede obtener la ubicación.
  Future<bool> verificarYSolicitarPermisos() async {
    // Verificar si el GPS está activado en el dispositivo
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      return false;
    }

    // Verificar permisos actuales
    LocationPermission permiso = await Geolocator.checkPermission();

    // Si está denegado, solicitarlo
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return false;
      }
    }

    // Si está permanentemente denegado, abrir configuración del sistema
    if (permiso == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  // ── Obtener posición actual ──

  /// Obtiene la posición GPS actual del dispositivo.
  /// Si no se tienen permisos o el GPS está apagado, retorna el centro de Buga.
  Future<LatLng> obtenerPosicionActual() async {
    final tienePermiso = await verificarYSolicitarPermisos();
    if (!tienePermiso) {
      return ConstantesApp.bugaCentro; // Fallback al centro de Buga
    }

    try {
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LatLng(posicion.latitude, posicion.longitude);
    } catch (_) {
      return ConstantesApp.bugaCentro;
    }
  }

  // ── Stream de posición en tiempo real ──

  /// Stream que emite la posición GPS actualizada continuamente.
  /// Útil para seguir al usuario mientras navega el mapa.
  Stream<LatLng> transmitirPosicion() {
    const configuracion = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Solo actualiza si se mueve más de 10 metros
    );

    return Geolocator.getPositionStream(locationSettings: configuracion)
        .map((posicion) => LatLng(posicion.latitude, posicion.longitude));
  }

  /// Verifica si el usuario tiene permisos ya concedidos (sin solicitarlos).
  Future<bool> tienePermisos() async {
    final permiso = await Geolocator.checkPermission();
    return permiso == LocationPermission.always ||
        permiso == LocationPermission.whileInUse;
  }
}
