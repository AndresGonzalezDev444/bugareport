import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/app_theme.dart';

/// Citizen greeting section: "Hola, ciudadano" headline with
/// subtitle about Buga's heritage. Matches Figma node #3826:8688.
class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            'Hola, ciudadano',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 32 / 24,
              letterSpacing: -0.025 * 24,
              color: AppColors.onSurface,
            ),
          ),
        ),
        Text(
          'Tu reporte oportuno preserva el patrimonio y bienestar de\nnuestra Ciudad Señora.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
