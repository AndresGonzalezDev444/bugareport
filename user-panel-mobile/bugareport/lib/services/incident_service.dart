import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/incident.dart';

/// Service layer for incident CRUD operations against Supabase.
/// Works like Waze: fetches all active incidents so citizens can see
/// what others have reported on the map in real-time.
class IncidentService {
  final SupabaseClient _client;

  IncidentService() : _client = Supabase.instance.client;

  // ── READ: Fetch all active incidents (not resolved) ──

  /// Fetches all incidents that are still active (pendiente or en_proceso).
  /// These are the ones shown on the map, like Waze shows traffic reports.
  Future<List<Incident>> fetchActiveIncidents() async {
    final response = await _client
        .from('incidents')
        .select()
        .neq('status', 'resuelto')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Incident.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches all incidents (including resolved) for admin/stats purposes.
  Future<List<Incident>> fetchAllIncidents() async {
    final response = await _client
        .from('incidents')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Incident.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches incidents created by a specific user ("Mis Reportes").
  Future<List<Incident>> fetchUserIncidents(String userId) async {
    final response = await _client
        .from('incidents')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Incident.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Gets the count of active incidents (for the map badge).
  Future<int> getActiveIncidentCount() async {
    final response = await _client
        .from('incidents')
        .select()
        .neq('status', 'resuelto')
        .count(CountOption.exact);

    return response.count;
  }

  /// Gets the count of incidents by user, split by status.
  /// Returns a map like {'total': 8, 'en_proceso': 3, 'resuelto': 5, 'pendiente': 0}.
  Future<Map<String, int>> getUserIncidentStats(String userId) async {
    final response = await _client
        .from('incidents')
        .select()
        .eq('user_id', userId);

    final incidents = (response as List)
        .map((json) => Incident.fromJson(json as Map<String, dynamic>))
        .toList();

    return {
      'total': incidents.length,
      'pendiente': incidents.where((i) => i.status == 'pendiente').length,
      'en_proceso': incidents.where((i) => i.status == 'en_proceso').length,
      'resuelto': incidents.where((i) => i.status == 'resuelto').length,
    };
  }

  // ── CREATE: Submit a new incident ──

  /// Creates a new incident report. Called when citizen submits a report.
  Future<Incident> createIncident(Incident incident) async {
    final response = await _client
        .from('incidents')
        .insert(incident.toJson())
        .select()
        .single();

    return Incident.fromJson(response);
  }

  // ── REALTIME: Stream of incidents (like Waze live updates) ──

  /// Subscribes to real-time changes on the incidents table.
  /// New incidents reported by other citizens appear on the map instantly.
  Stream<List<Incident>> streamActiveIncidents() {
    final controller = StreamController<List<Incident>>();

    // Initial load
    fetchActiveIncidents().then((incidents) {
      if (!controller.isClosed) {
        controller.add(incidents);
      }
    });

    // Subscribe to realtime changes
    _client
        .from('incidents')
        .stream(primaryKey: ['id'])
        .listen((data) {
      final allIncidents = data
          .map((json) => Incident.fromJson(json))
          .where((i) => i.status != 'resuelto')
          .toList();

      if (!controller.isClosed) {
        controller.add(allIncidents);
      }
    });

    return controller.stream;
  }
}
