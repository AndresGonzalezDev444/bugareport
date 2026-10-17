import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/modelos/incidente.dart';

/// Tarjeta de incidente individual para la pantalla "Mis Reportes".
/// Diseño fiel al Figma: thumbnail + título + location + status pill +
/// barra de progreso de 4 fases + acción "Ver en mapa".
class TarjetaIncidente extends StatelessWidget {
  final Incidente incidente;
  final VoidCallback? alVerMapa;

  const TarjetaIncidente({
    super.key,
    required this.incidente,
    this.alVerMapa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: radicado + estado ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge de categoría
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E7FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tag, size: 11, color: ColoresApp.primarioOscuro),
                    const SizedBox(width: 4),
                    Text(
                      _etiquetaCategoria(incidente.categoria),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.primarioOscuro,
                      ),
                    ),
                  ],
                ),
              ),
              // Chip de estado
              _ChipEstado(estado: incidente.estado),
            ],
          ),

          const SizedBox(height: 12),

          // ── Thumbnail + título + ubicación ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail (foto o placeholder)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEDFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: incidente.urlFoto != null && incidente.urlFoto!.isNotEmpty
                    ? Image.network(
                        incidente.urlFoto!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, widget2, err) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: ColoresApp.contorno,
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color: ColoresApp.contorno,
                        size: 28,
                      ),
              ),

              const SizedBox(width: 12),

              // Título + metadatos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incidente.titulo,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ColoresApp.sobreSuperficie,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: ColoresApp.contorno,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${incidente.latitud.toStringAsFixed(4)}, '
                            '${incidente.longitud.toStringAsFixed(4)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: ColoresApp.contorno,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 11,
                          color: ColoresApp.contorno,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatearFecha(incidente.creadoEn),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: ColoresApp.contorno,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: _colorSeveridad(incidente.severidad)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _etiquetaSeveridad(incidente.severidad),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _colorSeveridad(incidente.severidad),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Barra de progreso 4 fases ──
          _BarraProgreso(estado: incidente.estado),

          const SizedBox(height: 12),

          // ── Botón acción ──
          GestureDetector(
            onTap: alVerMapa,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFECEDFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 16,
                        color: ColoresApp.primarioOscuro,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ver seguimiento detallado en mapa',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: ColoresApp.primarioOscuro,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: ColoresApp.primarioOscuro,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
  static String _etiquetaCategoria(String cat) {
    const mapa = {
      'hueco_via'         : 'Hueco / Vía',
      'servicios_publicos': 'Servicios Públicos',
      'comunitario'       : 'Comunitario',
      'aseo_parques'      : 'Aseo y Parques',
    };
    return mapa[cat] ?? cat;
  }

  static String _etiquetaSeveridad(String sev) {
    const mapa = {
      'baja'   : 'Baja',
      'media'  : 'Media',
      'alta'   : 'Alta',
      'critico': 'Crítico',
    };
    return mapa[sev] ?? sev;
  }

  static Color _colorSeveridad(String sev) {
    switch (sev) {
      case 'baja':    return const Color(0xFF003223);
      case 'media':   return const Color(0xFF6A3B03);
      case 'alta':    return const Color(0xFF86521B);
      case 'critico': return ColoresApp.primario;
      default:        return ColoresApp.contorno;
    }
  }

  static String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}

// ── Chip de estado ──
class _ChipEstado extends StatelessWidget {
  final String estado;
  const _ChipEstado({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (label, fondo, texto, puntoCal) = _config(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: puntoCal,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: texto,
            ),
          ),
        ],
      ),
    );
  }

  static (String, Color, Color, Color) _config(String estado) {
    switch (estado) {
      case 'en_proceso':
        return ('En Proceso', const Color(0xFFFDDCC0), const Color(0xFF6A3B03), const Color(0xFF86521B));
      case 'resuelto':
        return ('Resuelto', const Color(0xFFBBEED6), const Color(0xFF003223), const Color(0xFF003223));
      case 'pendiente':
        return ('Pendiente', const Color(0xFFECEDFF), const Color(0xFF131A36), ColoresApp.primario);
      default:
        return (estado, const Color(0xFFECEDFF), ColoresApp.sobreSuperficie, ColoresApp.contorno);
    }
  }
}

// ── Barra de progreso 4 fases ──
class _BarraProgreso extends StatelessWidget {
  final String estado;
  const _BarraProgreso({required this.estado});

  static const _fases = ['Radicado', 'Asignado', 'En Cuadrilla', 'Resuelto'];

  int get _faseActual {
    switch (estado) {
      case 'pendiente':   return 0;
      case 'en_proceso':  return 2;
      case 'resuelto':    return 3;
      default:            return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fase = _faseActual;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timeline, size: 13, color: ColoresApp.primarioOscuro),
                  const SizedBox(width: 4),
                  Text(
                    'Seguimiento',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.primarioOscuro,
                    ),
                  ),
                ],
              ),
              Text(
                'Fase ${fase + 1}/4',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: ColoresApp.sobreSuperficieVariante,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barra
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: (fase + 1) / 4,
              minHeight: 8,
              backgroundColor: const Color(0xFFE4E7FF),
              valueColor: AlwaysStoppedAnimation<Color>(
                estado == 'resuelto' ? const Color(0xFF003223) : ColoresApp.primario,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _fases.asMap().entries.map((entry) {
              final activo = entry.key <= fase;
              return Text(
                entry.value,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
                  color: activo
                      ? ColoresApp.primarioOscuro
                      : ColoresApp.contorno,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
