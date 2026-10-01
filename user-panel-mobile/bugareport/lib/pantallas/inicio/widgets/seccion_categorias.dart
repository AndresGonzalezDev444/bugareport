import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';
import 'boton_categoria.dart';

/// Sección "Reportes Frecuentes" con fila horizontal de botones de categoría.
class SeccionCategorias extends StatelessWidget {
  const SeccionCategorias({super.key});

  static const _categorias = [
    _DatosCategoria(
      icono: Icons.warning_rounded,
      colorIcono: ColoresApp.primario,
      etiqueta: 'Hueco / Vía',
      subtitulo: 'Malla vial',
      clave: 'hueco_via',
    ),
    _DatosCategoria(
      icono: Icons.water_drop,
      colorIcono: ColoresApp.serviciosPublicos,
      etiqueta: 'Serv. Públicos',
      subtitulo: 'Agua / Luz',
      clave: 'servicios_publicos',
    ),
    _DatosCategoria(
      icono: Icons.groups,
      colorIcono: ColoresApp.comunitario,
      etiqueta: 'Comunitario',
      subtitulo: 'Convivencia',
      clave: 'comunitario',
    ),
    _DatosCategoria(
      icono: Icons.park,
      colorIcono: ColoresApp.aseoParques,
      etiqueta: 'Aseo y Parques',
      subtitulo: 'Espacio público',
      clave: 'aseo_parques',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Encabezado ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reportes Frecuentes',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 28 / 20,
                color: ColoresApp.sobreSuperficie,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Navegar a todas las categorías
              },
              child: Text(
                'Ver todos',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 14 / 11,
                  color: ColoresApp.secundario,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Fila horizontal desplazable ──
        SizedBox(
          height: 113,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: _categorias.length,
            separatorBuilder: (context, indice) => const SizedBox(width: 10),
            itemBuilder: (context, indice) {
              final categoria = _categorias[indice];
              return BotonCategoria(
                icono: categoria.icono,
                colorIcono: categoria.colorIcono,
                etiqueta: categoria.etiqueta,
                subtitulo: categoria.subtitulo,
                alTocar: () {
                  // TODO: Navegar a nuevo reporte con categoría pre-seleccionada
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DatosCategoria {
  final IconData icono;
  final Color colorIcono;
  final String etiqueta;
  final String subtitulo;
  final String clave;

  const _DatosCategoria({
    required this.icono,
    required this.colorIcono,
    required this.etiqueta,
    required this.subtitulo,
    required this.clave,
  });
}
