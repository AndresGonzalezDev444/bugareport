import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio singleton que monitorea la conectividad de red en tiempo real.
///
/// Emite [true] cuando hay WiFi o datos móviles activos.
/// Emite [false] cuando el dispositivo no tiene conexión.
///
/// Uso en UI:
/// ```dart
/// StreamBuilder<bool>(
///   stream: ServicioConectividad.instancia.estadoConexion,
///   builder: (context, snap) => PastillaConexion(enLinea: snap.data ?? true),
/// )
/// ```
class ServicioConectividad {
  ServicioConectividad._();
  static final ServicioConectividad instancia = ServicioConectividad._();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _controlador;

  /// Stream público de estado de conexión (true = en línea, false = sin red).
  Stream<bool> get estadoConexion {
    _controlador ??= StreamController<bool>.broadcast(
      onListen: _iniciarMonitoreo,
      onCancel: _detenerMonitoreo,
    );
    return _controlador!.stream;
  }

  StreamSubscription<List<ConnectivityResult>>? _suscripcion;

  void _iniciarMonitoreo() {
    // Verificar estado inicial inmediatamente
    _connectivity.checkConnectivity().then(_emitirEstado);

    // Escuchar cambios en tiempo real
    _suscripcion = _connectivity.onConnectivityChanged.listen(_emitirEstado);
  }

  void _detenerMonitoreo() {
    _suscripcion?.cancel();
    _suscripcion = null;
  }

  void _emitirEstado(List<ConnectivityResult> resultados) {
    final enLinea = resultados.any(
      (r) => r != ConnectivityResult.none,
    );
    if (_controlador != null && !(_controlador!.isClosed)) {
      _controlador!.add(enLinea);
    }
  }

  /// Consulta puntual del estado actual de conexión.
  Future<bool> tieneConexion() async {
    final resultados = await _connectivity.checkConnectivity();
    return resultados.any((r) => r != ConnectivityResult.none);
  }

  /// Libera recursos. Llamar desde el widget raíz en [dispose].
  void dispose() {
    _suscripcion?.cancel();
    _controlador?.close();
    _controlador = null;
  }
}
