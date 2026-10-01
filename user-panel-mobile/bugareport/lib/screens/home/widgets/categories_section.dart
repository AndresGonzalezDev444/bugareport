import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/app_theme.dart';
import 'category_button.dart';

/// "Reportes Frecuentes" section with a horizontal scrollable row of
/// category shortcut buttons. Matches Figma node #3826:8779.
class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  static const _categories = [
    _CategoryData(
      icon: Icons.warning_rounded,
      iconColor: AppColors.primary,
      label: 'Hueco / Vía',
      subtitle: 'Malla vial',
      key: 'hueco_via',
    ),
    _CategoryData(
      icon: Icons.water_drop,
      iconColor: AppColors.serviciosPublicos,
      label: 'Serv. Públicos',
      subtitle: 'Agua / Luz',
      key: 'servicios_publicos',
    ),
    _CategoryData(
      icon: Icons.groups,
      iconColor: AppColors.comunitario,
      label: 'Comunitario',
      subtitle: 'Convivencia',
      key: 'comunitario',
    ),
    _CategoryData(
      icon: Icons.park,
      iconColor: AppColors.aseoParques,
      label: 'Aseo y Parques',
      subtitle: 'Espacio público',
      key: 'aseo_parques',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reportes Frecuentes',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 28 / 20,
                color: AppColors.onSurface,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to all categories
              },
              child: Text(
                'Ver todos',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 14 / 11,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Horizontal scroll row ──
        SizedBox(
          height: 113,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: _categories.length,
            separatorBuilder: (context, idx) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return CategoryButton(
                icon: cat.icon,
                iconColor: cat.iconColor,
                label: cat.label,
                subtitle: cat.subtitle,
                onTap: () {
                  // TODO: Navigate to new report with pre-selected category
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryData {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final String key;

  const _CategoryData({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.key,
  });
}
