import 'package:flutter/material.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/modelos/incidente.dart';

/// Widget de pin de mapa coloreado según la categoría del incidente.
/// Se renderiza como un círculo con ícono y un triángulo apuntador.
class PinMapaIncidente extends StatelessWidget {
  final Incidente incidente;
  final VoidCallback? alTocar;

  const PinMapaIncidente({
    super.key,
    required this.incidente,
    this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColoresApp.colorPorCategoria(incidente.categoria);

    return GestureDetector(
      onTap: alTocar,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Círculo del pin con ícono
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
              _iconoPorCategoria(incidente.categoria),
              color: Colors.white,
              size: 14,
            ),
          ),
          // Triángulo apuntador
          CustomPaint(
            size: const Size(10, 6),
            painter: _PintorTrianguloPin(color: color),
          ),
        ],
      ),
    );
  }

  IconData _iconoPorCategoria(String categoria) {
    switch (categoria) {
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

/// Pinta el pequeño triángulo inferior del pin.
class _PintorTrianguloPin extends CustomPainter {
  final Color color;

  _PintorTrianguloPin({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final trayecto = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(trayecto, pincel);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
