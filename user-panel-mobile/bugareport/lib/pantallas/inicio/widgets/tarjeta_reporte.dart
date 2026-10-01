import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';

/// Tarjeta individual para la cuadrícula de acciones.
/// Configurable como "Mis Reportes" o "Borradores offline".
class TarjetaReporte extends StatelessWidget {
  final IconData icono;
  final Color iconoFondoColor;
  final Color iconoColor;
  final String badgeTexto;
  final Color badgeFondoColor;
  final Color badgeTextoColor;
  final String titulo;
  final List<EstadisticaTarjeta> estadisticas;
  final String? subtitulo;
  final VoidCallback? alTocar;

  const TarjetaReporte({
    super.key,
    required this.icono,
    required this.iconoFondoColor,
    required this.iconoColor,
    required this.badgeTexto,
    required this.badgeFondoColor,
    required this.badgeTextoColor,
    required this.titulo,
    this.estadisticas = const [],
    this.subtitulo,
    this.alTocar,
  });

  /// Tarjeta pre-configurada "Mis Reportes" con estadísticas en vivo.
  factory TarjetaReporte.misReportes({
    required Map<String, int> estadisticas,
    VoidCallback? alTocar,
  }) {
    return TarjetaReporte(
      icono: Icons.description_outlined,
      iconoFondoColor: const Color(0x80FFDAD8),
      iconoColor: const Color(0xFF410007),
      badgeTexto: '${estadisticas['total'] ?? 0} Total',
      badgeFondoColor: const Color(0xFFFFDCC0),
      badgeTextoColor: const Color(0xFF2D1600),
      titulo: 'Mis Reportes',
      estadisticas: [
        EstadisticaTarjeta(
          colorPunto: ColoresApp.secundario,
          texto: '${estadisticas['en_proceso'] ?? 0} en proceso',
        ),
        EstadisticaTarjeta(
          colorPunto: ColoresApp.terciarioOscuro,
          texto: '${estadisticas['resuelto'] ?? 0} resueltos',
        ),
      ],
      alTocar: alTocar,
    );
  }

  /// Tarjeta pre-configurada "Borradores offline".
  factory TarjetaReporte.borradoresOffline({
    int cantidadPendientes = 0,
    VoidCallback? alTocar,
  }) {
    return TarjetaReporte(
      icono: Icons.cloud_off_outlined,
      iconoFondoColor: const Color(0x66FEB877),
      iconoColor: const Color(0xFF78470F),
      badgeTexto: '$cantidadPendientes Pendientes',
      badgeFondoColor: ColoresApp.advertenciaFondo,
      badgeTextoColor: ColoresApp.advertencia,
      titulo: 'Borradores offline',
      subtitulo: 'Listos para sincronizar al\nreconectar',
      alTocar: alTocar,
    );
  }

  bool get _esPildora => badgeFondoColor == ColoresApp.advertenciaFondo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alTocar,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColoresApp.superficie,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColoresApp.bordeCard.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: ícono + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Círculo del ícono
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconoFondoColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: iconoColor, size: 17),
                ),
                // Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _esPildora ? 8 : 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeFondoColor,
                    borderRadius: BorderRadius.circular(_esPildora ? 9999 : 4),
                  ),
                  child: Text(
                    badgeTexto,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 14 / 11,
                      color: badgeTextoColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Título
            Text(
              titulo,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 16 / 12,
                color: ColoresApp.sobreSuperficie,
              ),
            ),

            // Lista de estadísticas (para Mis Reportes)
            if (estadisticas.isNotEmpty) ...[
              const SizedBox(height: 2),
              ...estadisticas.map((stat) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: stat.colorPunto,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          stat.texto,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                            color: ColoresApp.sobreSuperficieVariante,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            // Subtítulo (para Borradores)
            if (subtitulo != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitulo!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 15 / 12,
                  color: ColoresApp.sobreSuperficieVariante,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Una fila de estadística en la TarjetaReporte (ej: "3 en proceso").
class EstadisticaTarjeta {
  final Color colorPunto;
  final String texto;

  const EstadisticaTarjeta({required this.colorPunto, required this.texto});
}
