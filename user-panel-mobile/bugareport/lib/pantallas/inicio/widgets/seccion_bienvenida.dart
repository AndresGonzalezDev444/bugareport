import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';

/// Sección de saludo personalizado al ciudadano.
/// "Hola, ciudadano" + subtítulo sobre el patrimonio de Buga.
class SeccionBienvenida extends StatelessWidget {
  const SeccionBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Hola, ciudadano',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 32 / 24,
              letterSpacing: -0.025 * 24,
              color: ColoresApp.sobreSuperficie,
            ),
          ),
        ),
        Text(
          'Tu reporte oportuno preserva el patrimonio y bienestar de\nnuestra Ciudad Señora.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ColoresApp.sobreSuperficieVariante,
              ),
        ),
      ],
    );
  }
}
