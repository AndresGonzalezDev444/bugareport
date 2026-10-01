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
  /// Los nuevos reportes de otros ciudadanos aparecen en el mapa al instante.
  Stream<List<Incidente>> transmitirIncidentesActivos() {
    final controlador = StreamController<List<Incidente>>();

    // Carga inicial
    obtenerIncidentesActivos().then((incidentes) {
      if (!controlador.isClosed) {
        controlador.add(incidentes);
      }
    });

    // Suscripción a cambios en tiempo real
    _cliente
        .from('incidents')
        .stream(primaryKey: ['id'])
        .listen((datos) {
      final incidentesActivos = datos
          .map((json) => Incidente.desdeJson(json))
          .where((i) => i.estado != 'resuelto')
          .toList();

      if (!controlador.isClosed) {
        controlador.add(incidentesActivos);
      }
    });

    return controlador.stream;
  }
}
