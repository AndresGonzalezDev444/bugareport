import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bugareport/modelos/incidente.dart';

/// Capa de servicio para operaciones CRUD de incidentes contra Supabase.
/// Funciona como Waze: obtiene incidentes activos para que los ciudadanos
/// vean en el mapa lo que otros han reportado, en tiempo real.
class ServicioIncidentes {
  final SupabaseClient _cliente;

  ServicioIncidentes() : _cliente = Supabase.instance.client;

  // ── LECTURA: Obtener incidentes ──

  /// Obtiene todos los incidentes activos (pendiente o en_proceso).
  /// Estos se muestran en el mapa, como Waze muestra reportes de tráfico.
  Future<List<Incidente>> obtenerIncidentesActivos() async {
    final respuesta = await _cliente
        .from('incidents')
        .select()
        .neq('status', 'resuelto')
        .order('created_at', ascending: false);

    return (respuesta as List)
        .map((json) => Incidente.desdeJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene todos los incidentes (incluyendo resueltos).
  Future<List<Incidente>> obtenerTodosIncidentes() async {
    final respuesta = await _cliente
        .from('incidents')
        .select()
        .order('created_at', ascending: false);

    return (respuesta as List)
        .map((json) => Incidente.desdeJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene los incidentes de un usuario específico ("Mis Reportes").
  Future<List<Incidente>> obtenerIncidentesUsuario(String idUsuario) async {
    final respuesta = await _cliente
        .from('incidents')
        .select()
        .eq('user_id', idUsuario)
        .order('created_at', ascending: false);

    return (respuesta as List)
        .map((json) => Incidente.desdeJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene el conteo de incidentes activos (para el badge del mapa).
  Future<int> contarIncidentesActivos() async {
    final respuesta = await _cliente
        .from('incidents')
        .select()
        .neq('status', 'resuelto')
        .count(CountOption.exact);

    return respuesta.count;
  }

  /// Obtiene estadísticas de incidentes por usuario.
  /// Retorna: {'total': 8, 'en_proceso': 3, 'resuelto': 5, 'pendiente': 0}.
  Future<Map<String, int>> obtenerEstadisticasUsuario(String idUsuario) async {
    final respuesta = await _cliente
        .from('incidents')
        .select()
        .eq('user_id', idUsuario);

    final incidentes = (respuesta as List)
        .map((json) => Incidente.desdeJson(json as Map<String, dynamic>))
        .toList();

    return {
      'total': incidentes.length,
      'pendiente': incidentes.where((i) => i.estado == 'pendiente').length,
      'en_proceso': incidentes.where((i) => i.estado == 'en_proceso').length,
      'resuelto': incidentes.where((i) => i.estado == 'resuelto').length,
    };
  }

  // ── CREACIÓN: Enviar nuevo incidente ──

  /// Crea un nuevo reporte de incidente en Supabase.
  Future<Incidente> crearIncidente(Incidente incidente) async {
    final respuesta = await _cliente
        .from('incidents')
        .insert(incidente.aJson())
        .select()
        .single();

    return Incidente.desdeJson(respuesta);
  }

  // ── TIEMPO REAL: Stream de incidentes (como Waze en vivo) ──

  /// Suscripción en tiempo real a los incidentes activos.
  ///
  /// - Si Realtime está habilitado en Supabase: actualiza al instante.
  /// - Si Realtime no está habilitado (o falla): hace polling cada 30s.
  ///   En ambos casos el mapa siempre muestra datos.
  Stream<List<Incidente>> transmitirIncidentesActivos() {
    final controlador = StreamController<List<Incidente>>.broadcast();

    // Carga inicial inmediata
    obtenerIncidentesActivos().then((incidentes) {
      if (!controlador.isClosed) controlador.add(incidentes);
    }).catchError((_) {
      if (!controlador.isClosed) controlador.add([]);
    });

    // Intentar suscripción Realtime
    try {
      _cliente
          .from('incidents')
          .stream(primaryKey: ['id'])
          .listen(
            (datos) {
              final activos = datos
                  .map((json) => Incidente.desdeJson(json))
                  .where((i) => i.estado != 'resuelto')
                  .toList();
              if (!controlador.isClosed) controlador.add(activos);
            },
            onError: (_) {
              // Realtime falló — el polling periódico compensará
            },
          );
    } catch (_) {
      // Realtime no disponible — activar polling de respaldo
      _iniciarPolling(controlador);
    }

    return controlador.stream;
  }

  /// Polling de respaldo cuando Realtime no está disponible.
  /// Consulta cada 30 segundos.
  void _iniciarPolling(StreamController<List<Incidente>> controlador) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (controlador.isClosed) return false;
      try {
        final incidentes = await obtenerIncidentesActivos();
        if (!controlador.isClosed) controlador.add(incidentes);
      } catch (_) {
        // Ignorar errores de red en el polling
      }
      return !controlador.isClosed;
    });
  }
}
