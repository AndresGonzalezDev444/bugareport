import 'package:flutter/material.dart';
import 'package:bugareport/config/rutas_app.dart';
import 'package:bugareport/servicios/servicio_incidentes.dart';
import 'package:bugareport/servicios/servicio_borrador.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tarjeta_reporte.dart';

/// Cuadrícula de 2 columnas: "Mis Reportes" + "Borradores offline".
/// Las estadísticas de Mis Reportes se cargan en vivo desde Supabase.
/// El conteo de borradores se lee de ServicioBorrador (SharedPreferences).
class CuadriculaAcciones extends StatefulWidget {
  final ServicioIncidentes servicioIncidentes;

  const CuadriculaAcciones({super.key, required this.servicioIncidentes});

  @override
  State<CuadriculaAcciones> createState() => _EstadoCuadriculaAcciones();
}

class _EstadoCuadriculaAcciones extends State<CuadriculaAcciones> {
  int _cantidadBorradores = 0;

  @override
  void initState() {
    super.initState();
    _cargarBorradores();
  }

  Future<void> _cargarBorradores() async {
    final hay = await ServicioBorrador.instancia.tieneBorrador();
    if (mounted) setState(() => _cantidadBorradores = hay ? 1 : 0);
  }

  void _abrirBorradores(BuildContext context) {
    if (_cantidadBorradores == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No tienes borradores guardados.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF78470F),
        ),
      );
      return;
    }
    // Navegar al formulario — el SnackBar de recuperación aparecerá automáticamente
    Navigator.of(context).pushNamed(RutasApp.nuevoReporte);
  }

  @override
  Widget build(BuildContext context) {
    final idUsuario = Supabase.instance.client.auth.currentUser?.id;

    return Row(
      children: [
        // ── Mis Reportes — estadísticas en vivo desde Supabase ──
        Expanded(
          child: idUsuario != null
              ? FutureBuilder<Map<String, int>>(
                  future: widget.servicioIncidentes
                      .obtenerEstadisticasUsuario(idUsuario),
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
                      alTocar: () => Navigator.of(context)
                          .pushNamed(RutasApp.misReportes),
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
                  alTocar: () =>
                      Navigator.of(context).pushNamed(RutasApp.login),
                ),
        ),

        const SizedBox(width: 12),

        // ── Borradores offline — conteo real de ServicioBorrador ──
        Expanded(
          child: TarjetaReporte.borradoresOffline(
            cantidadPendientes: _cantidadBorradores,
            alTocar: () => _abrirBorradores(context),
          ),
        ),
      ],
    );
  }
}
