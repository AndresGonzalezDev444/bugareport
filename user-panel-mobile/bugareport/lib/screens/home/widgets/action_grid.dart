import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/incident_service.dart';
import 'report_card.dart';

/// 2-column action grid: "Mis Reportes" + "Borradores offline".
/// "Mis Reportes" stats are fetched live from Supabase.
class ActionGrid extends StatelessWidget {
  final IncidentService incidentService;

  const ActionGrid({super.key, required this.incidentService});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Row(
      children: [
        // ── Mis Reportes — live stats from Supabase ──
        Expanded(
          child: userId != null
              ? FutureBuilder<Map<String, int>>(
                  future: incidentService.getUserIncidentStats(userId),
                  builder: (context, snapshot) {
                    final stats = snapshot.data ??
                        {
                          'total': 0,
                          'en_proceso': 0,
                          'resuelto': 0,
                          'pendiente': 0,
                        };
                    return ReportCard.misReportes(
                      stats: stats,
                      onTap: () {
                        // TODO: Navigate to Mis Reportes screen
                      },
                    );
                  },
                )
              : ReportCard.misReportes(
                  stats: const {
                    'total': 0,
                    'en_proceso': 0,
                    'resuelto': 0,
                    'pendiente': 0,
                  },
                  onTap: () {
                    // TODO: Navigate to login or mis reportes
                  },
                ),
        ),

        const SizedBox(width: 12),

        // ── Borradores offline — local draft count ──
        Expanded(
          child: ReportCard.borradoresOffline(
            pendingCount: 0, // TODO: read from SharedPreferences / local DB
            onTap: () {
              // TODO: Navigate to Borradores screen
            },
          ),
        ),
      ],
    );
  }
}
