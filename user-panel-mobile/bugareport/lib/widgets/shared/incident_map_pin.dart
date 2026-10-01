import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/incident.dart';

/// Custom map pin widget colored by incident category.
/// Renders as a circular pin with an icon, matching the Figma design.
class IncidentMapPin extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onTap;

  const IncidentMapPin({
    super.key,
    required this.incident,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.pinForCategory(incident.category);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pin circle with icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  spreadRadius: -3,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  spreadRadius: -4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _iconForCategory(incident.category),
              color: Colors.white,
              size: 14,
            ),
          ),
          // Pin triangle pointer
          CustomPaint(
            size: const Size(10, 6),
            painter: _PinPointerPainter(color: color),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'hueco_via':
        return Icons.warning_rounded;
      case 'servicios_publicos':
        return Icons.water_drop;
      case 'comunitario':
        return Icons.groups;
      case 'aseo_parques':
        return Icons.park;
      default:
        return Icons.place;
    }
  }
}

/// Paints the small triangle pointer below the pin circle.
class _PinPointerPainter extends CustomPainter {
  final Color color;

  _PinPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
