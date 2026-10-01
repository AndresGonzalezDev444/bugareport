import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/config/constantes_app.dart';
import 'package:bugareport/modelos/incidente.dart';
import 'package:bugareport/widgets/compartidos/pin_mapa_incidente.dart';

/// Tarjeta de mapa interactivo OpenStreetMap con incidentes ciudadanos en vivo.
/// Centrado en Guadalajara de Buga. Los incidentes vienen de Supabase.
class TarjetaMapa extends StatelessWidget {
  final List<Incidente> incidentes;

  const TarjetaMapa({super.key, required this.incidentes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColoresApp.bordeCard.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 176,
        child: Stack(
          children: [
            // ── Mapa OpenStreetMap ──
            FlutterMap(
              options: MapOptions(
                initialCenter: ConstantesApp.bugaCentro,
                initialZoom: ConstantesApp.zoomMapaInicial,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none, // Solo previsualización
                ),
              ),
              children: [
                // Capa de teselas OSM
                TileLayer(
                  urlTemplate: ConstantesApp.urlTeselaOsm,
                  userAgentPackageName: 'com.bugareport.app',
                ),

                // Marcadores de incidentes desde la base de datos
                MarkerLayer(
                  markers: incidentes.map((incidente) {
                    return Marker(
                      point: LatLng(incidente.latitud, incidente.longitud),
                      width: 28,
                      height: 34,
                      child: PinMapaIncidente(
                        incidente: incidente,
                        alTocar: () => _mostrarDetalleIncidente(context, incidente),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // ── Gradiente oscuro en la parte inferior ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 88,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),

            // ── Badge: "X reportes activos cerca" ──
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColoresApp.fondo.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: ColoresApp.bordeClaro.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ColoresApp.primario,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${incidentes.length} reportes activos cerca',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 14 / 11,
                        color: ColoresApp.sobreSuperficie,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Barra CTA inferior ──
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Etiqueta de ubicación
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: ColoresApp.primarioOscuro,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Comuna 1, Centro Histórico',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 14 / 11,
                            color: ColoresApp.sobreSuperficie,
                          ),
                        ),
                      ],
                    ),
                    // Botón explorar mapa
                    GestureDetector(
                      onTap: () {
                        // tod0: Navegar a pantalla de mapa completo
                      },
                      child: Row(
                        children: [
                          Text(
                            'Explorar mapa',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 14 / 11,
                              color: ColoresApp.primarioOscuro,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: ColoresApp.primarioOscuro,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra un bottom sheet con el detalle del incidente tocado.
  void _mostrarDetalleIncidente(BuildContext context, Incidente incidente) {
    final color = ColoresApp.colorPorCategoria(incidente.categoria);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColoresApp.superficie,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  incidente.etiquetaCategoria,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  incidente.tiempoTranscurrido,
                  style: GoogleFonts.inter(fontSize: 11, color: ColoresApp.contorno),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              incidente.titulo,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColoresApp.sobreSuperficie,
              ),
            ),
            if (incidente.descripcion != null) ...[
              const SizedBox(height: 4),
              Text(
                incidente.descripcion!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ColoresApp.sobreSuperficieVariante,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (incidente.direccion != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place, size: 14, color: ColoresApp.contorno),
                  const SizedBox(width: 4),
                  Text(
                    incidente.direccion!,
                    style: GoogleFonts.inter(fontSize: 12, color: ColoresApp.contorno),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
