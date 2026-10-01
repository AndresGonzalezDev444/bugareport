import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';

/// Barra de emergencia con "LÍNEA DE EMERGENCIA" y botones de acción.
/// Fondo rosa, borde rojo. Corresponde al nodo Figma #3826:8828.
class BarraEmergencia extends StatelessWidget {
  const BarraEmergencia({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresApp.emergenciaFondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColoresApp.primario.withValues(alpha: 0.3),
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
          // Izquierda: ícono + textos
          Row(
            children: [
              // Ícono de teléfono en círculo rojo
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: ColoresApp.primario,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              // Columna de textos
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
                        color: ColoresApp.primario,
                      ),
                    ),
                  ),
                  Text(
                    'Cuadrantes Emergencia Buga',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: ColoresApp.sobreSuperficieVariante,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Derecha: botones de acción (llamar + WhatsApp)
          Row(
            children: [
              // Botón llamar 123
              _BotonAccion(
                icono: Icons.call,
                color: ColoresApp.primario,
                alTocar: () {
                  // TODO: lanzar url tel:123
                },
              ),
              const SizedBox(width: 6),
              // Botón WhatsApp
              _BotonAccion(
                icono: Icons.chat,
                color: ColoresApp.terciario,
                alTocar: () {
                  // TODO: lanzar WhatsApp con mensaje pre-llenado
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final Color color;
  final VoidCallback? alTocar;

  const _BotonAccion({
    required this.icono,
    required this.color,
    this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alTocar,
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
        child: Icon(icono, color: Colors.white, size: 18),
      ),
    );
  }
}
