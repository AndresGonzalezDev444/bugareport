import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bugareport/servicios/servicio_incidentes.dart';
import 'package:bugareport/modelos/incidente.dart';
import 'package:bugareport/pantallas/mapa/pantalla_mapa.dart';
import 'widgets/barra_superior.dart';
import 'widgets/seccion_bienvenida.dart';
import 'widgets/tarjeta_mapa.dart';
import 'widgets/boton_reportar.dart';
import 'widgets/cuadricula_acciones.dart';
import 'widgets/seccion_categorias.dart';
import 'widgets/barra_emergencia.dart';
import 'widgets/barra_navegacion.dart';

/// Pantalla principal de la app ciudadana BugaReport.
/// Muestra un mapa OSM en vivo con incidentes de Supabase (estilo Waze),
/// cuadrícula de acciones rápidas, categorías y barra de emergencia.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _EstadoPantallaInicio();
}

class _EstadoPantallaInicio extends State<PantallaInicio> {
  final _servicioIncidentes = ServicioIncidentes();
  int _indiceNavActual = 0;

  @override
  void initState() {
    super.initState();
    // Barra de estado transparente para sensación inmersiva
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Contenido principal desplazable ──
          _construirCuerpoDesplazable(),

          // ── Barra superior fija (flota sobre el scroll) ──
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BarraSuperior(),
          ),

          // ── Barra de navegación fija inferior ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BarraNavegacion(
              indiceSelecionado: _indiceNavActual,
              alCambiarPestana: (indice) {
                if (indice == 1) {
                  // Pestaña Mapa → navegar a pantalla de mapa completo
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PantallaMapa(),
                    ),
                  );
                } else if (indice == 2) {
                  // Pestaña Reportar → navegar a crear reporte (próximamente)
                  // TODO: Navigator.push a pantalla de nuevo reporte
                } else {
                  setState(() => _indiceNavActual = indice);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCuerpoDesplazable() {
    return StreamBuilder<List<Incidente>>(
      // Stream en tiempo real de Supabase — los incidentes nuevos aparecen al instante
      stream: _servicioIncidentes.transmitirIncidentesActivos(),
      builder: (context, instantanea) {
        final incidentes = instantanea.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Espaciador para la BarraSuperior fija (~64px)
              const SizedBox(height: 64),

              // ── Todas las secciones con padding uniforme ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Bienvenida
                    const SeccionBienvenida(),

                    const SizedBox(height: 20),

                    // 2. Mapa OSM con incidentes en vivo desde Supabase
                    TarjetaMapa(incidentes: incidentes),

                    const SizedBox(height: 20),

                    // 3. Botón hero "Reportar Incidente"
                    const BotonReportar(),

                    const SizedBox(height: 12),

                    // 4. Cuadrícula de acciones (Mis Reportes + Borradores)
                    CuadriculaAcciones(
                      servicioIncidentes: _servicioIncidentes,
                    ),

                    const SizedBox(height: 20),

                    // 5. Categorías con desplazamiento horizontal
                    const SeccionCategorias(),

                    const SizedBox(height: 24),

                    // 6. Barra de emergencia
                    const BarraEmergencia(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
