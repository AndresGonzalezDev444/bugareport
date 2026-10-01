import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/app_theme.dart';

/// Individual category button used in the horizontal scroll row.
/// Shows an icon in a circle + category name + subtitle.
/// Matches Figma nodes #3826:8787–8817.
class CategoryButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const CategoryButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 112,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.4),
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
            // Icon in a circular container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.categoryIconBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.categoryIconBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),

            const SizedBox(height: 8),

            // Category label
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 14 / 11,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 2),

            // Subtitle
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 15 / 10,
                color: AppColors.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
