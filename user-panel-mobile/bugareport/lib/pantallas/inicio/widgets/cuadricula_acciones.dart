import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bugareport/servicios/servicio_incidentes.dart';
import 'tarjeta_reporte.dart';

/// Cuadrícula de 2 columnas: "Mis Reportes" + "Borradores offline".
/// Las estadísticas de Mis Reportes se cargan en vivo desde Supabase.
class CuadriculaAcciones extends StatelessWidget {
  final ServicioIncidentes servicioIncidentes;

  const CuadriculaAcciones({super.key, required this.servicioIncidentes});

  @override
  Widget build(BuildContext context) {
    final idUsuario = Supabase.instance.client.auth.currentUser?.id;

    return Row(
      children: [
        // ── Mis Reportes — estadísticas en vivo desde Supabase ──
        Expanded(
          child: idUsuario != null
              ? FutureBuilder<Map<String, int>>(
                  future: servicioIncidentes.obtenerEstadisticasUsuario(idUsuario),
                  builder: (context, snapshot) {
                    final estadisticas = snapshot.data ??
                        {
                          'total': 0,
                          'en_proceso': 0,
                          'resuelto': 0,
                          'pendiente': 0,
                        };
                    return TarjetaReporte.misReportes(
                      estadisticas: estadisticas,
                      alTocar: () {
                        // TODO: Navegar a pantalla Mis Reportes
                      },
                    );
                  },
                )
              : TarjetaReporte.misReportes(
                  estadisticas: const {
                    'total': 0,
                    'en_proceso': 0,
                    'resuelto': 0,
                    'pendiente': 0,
                  },
                  alTocar: () {
                    // TODO: Navegar a login o mis reportes
                  },
                ),
        ),

        const SizedBox(width: 12),

        // ── Borradores offline — conteo local ──
        Expanded(
          child: TarjetaReporte.borradoresOffline(
            cantidadPendientes: 0, // TODO: leer de SharedPreferences / BD local
            alTocar: () {
              // TODO: Navegar a pantalla de borradores
            },
          ),
        ),
      ],
    );
  }
}
