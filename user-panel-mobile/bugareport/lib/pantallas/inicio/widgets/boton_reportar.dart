import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';

/// Botón hero grande "Reportar Incidente" — CTA principal de la app.
class BotonReportar extends StatelessWidget {
  final VoidCallback? alTocar;

  const BotonReportar({super.key, this.alTocar});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresApp.primario,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: alTocar ?? () {
          // TODO: Navegar a pantalla de crear reporte
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: ColoresApp.primarioSombra,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Izquierda: ícono + texto
              Row(
                children: [
                  // Ícono de cámara en contenedor translúcido
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Columna de texto
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reportar Incidente',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fotografía, geolocaliza y envía a la Alcaldía',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 14 / 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Flecha derecha
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14.67,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
