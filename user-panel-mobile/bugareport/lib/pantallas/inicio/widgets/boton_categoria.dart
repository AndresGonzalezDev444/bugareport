import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';

/// Botón individual de categoría usado en la fila de desplazamiento horizontal.
/// Muestra un ícono en un círculo + nombre de categoría + subtítulo.
class BotonCategoria extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String etiqueta;
  final String subtitulo;
  final VoidCallback? alTocar;

  const BotonCategoria({
    super.key,
    required this.icono,
    required this.colorIcono,
    required this.etiqueta,
    required this.subtitulo,
    this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alTocar,
      child: Container(
        width: 112,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColoresApp.superficie,
          borderRadius: BorderRadius.circular(12),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono en contenedor circular
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ColoresApp.iconoCategoriaBg,
                shape: BoxShape.circle,
                border: Border.all(color: ColoresApp.iconoCategoriaBorde),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icono, color: colorIcono, size: 20),
            ),

            const SizedBox(height: 8),

            // Etiqueta de la categoría
            Text(
              etiqueta,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 14 / 11,
                color: ColoresApp.sobreSuperficie,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 2),

            // Subtítulo
            Text(
              subtitulo,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 15 / 10,
                color: ColoresApp.contorno,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
