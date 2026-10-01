import 'package:flutter/material.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/widgets/compartidos/pastilla_conexion.dart';

/// Barra superior de la app con logo BugaReport, pastilla de conexión y campana.
class BarraSuperior extends StatelessWidget {
  const BarraSuperior({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo BugaReport desde assets
            Image.asset(
              'assets/images/logo-buga-report.png',
              height: 40,
              fit: BoxFit.contain,
            ),

            // Derecha: pastilla de conexión + notificaciones
            Row(
              children: [
                const PastillaConexion(enLinea: true),
                const SizedBox(width: 4),
                // Campana de notificaciones con badge
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Navegar a notificaciones
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: ColoresApp.sobreSuperficieVariante,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    // Punto rojo de notificación
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ColoresApp.primario,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColoresApp.fondo,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
