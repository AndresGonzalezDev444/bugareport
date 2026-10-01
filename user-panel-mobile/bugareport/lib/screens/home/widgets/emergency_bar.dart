import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/app_theme.dart';

/// Emergency bar showing "LÍNEA DE EMERGENCIA" with a call button.
/// Pink background, red border, matches Figma node #3826:8828.
class EmergencyBar extends StatelessWidget {
  const EmergencyBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.emergencyBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: icon + texts
          Row(
            children: [
              // Phone icon in red circle
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              // Text column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3.5),
                    child: Text(
                      'LÍNEA DE EMERGENCIA',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 16 / 12,
                        letterSpacing: -0.025 * 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    'Cuadrantes Emergencia Buga',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: action buttons (call + whatsapp)
          Row(
            children: [
              // Call 123 button
              _ActionButton(
                icon: Icons.call,
                color: AppColors.primary,
                onTap: () {
                  // TODO: launch url tel:123
                },
              ),
              const SizedBox(width: 6),
              // WhatsApp button
              _ActionButton(
                icon: Icons.chat,
                color: AppColors.tertiary,
                onTap: () {
                  // TODO: launch WhatsApp with pre-filled location message
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
