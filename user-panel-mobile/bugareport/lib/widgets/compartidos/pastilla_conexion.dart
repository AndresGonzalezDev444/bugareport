import 'package:flutter/material.dart';
import 'package:bugareport/config/tema_app.dart';

/// Pequeña pastilla que muestra el estado de conectividad.
/// Punto verde + "En línea" o punto rojo + "Sin conexión".
class PastillaConexion extends StatelessWidget {
  final bool enLinea;

  const PastillaConexion({super.key, this.enLinea = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: enLinea
            ? ColoresApp.conexionPildoraFondo
            : ColoresApp.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: enLinea ? ColoresApp.terciarioOscuro : ColoresApp.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            enLinea ? 'En línea' : 'Sin conexión',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: enLinea ? ColoresApp.terciarioOscuro : ColoresApp.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
