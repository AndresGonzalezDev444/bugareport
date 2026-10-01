import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';

/// Barra de navegación inferior con 5 pestañas.
/// La pestaña 3 "Reportar" es el botón circular central elevado.
/// Pestaña activa por defecto: "Inicio" (índice 0).
/// Corresponde al nodo Figma #3826:8867.
class BarraNavegacion extends StatelessWidget {
  final int indiceSelecionado;
  final ValueChanged<int>? alCambiarPestana;

  const BarraNavegacion({
    super.key,
    this.indiceSelecionado = 0,
    this.alCambiarPestana,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: ColoresApp.superficie,
        boxShadow: [
          BoxShadow(
            color: Color(0x141C2340),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 1. Inicio
            _PestanaNav(
              icono: Icons.home_outlined,
              iconoActivo: Icons.home,
              etiqueta: 'Inicio',
              estaActiva: indiceSelecionado == 0,
              alTocar: () => alCambiarPestana?.call(0),
            ),

            // 2. Mapa
            _PestanaNav(
              icono: Icons.map_outlined,
              iconoActivo: Icons.map,
              etiqueta: 'Mapa',
              estaActiva: indiceSelecionado == 1,
              alTocar: () => alCambiarPestana?.call(1),
            ),

            // 3. Reportar — botón circular central elevado
            _BotonReportarCentral(
              estaActivo: indiceSelecionado == 2,
              alTocar: () => alCambiarPestana?.call(2),
            ),

            // 4. Borradores
            _PestanaNav(
              icono: Icons.cloud_off_outlined,
              etiqueta: 'Borradores',
              estaActiva: indiceSelecionado == 3,
              alTocar: () => alCambiarPestana?.call(3),
              mostrarBadge: true,
            ),

            // 5. Perfil
            _PestanaNav(
              icono: Icons.person_outline,
              iconoActivo: Icons.person,
              etiqueta: 'Perfil',
              estaActiva: indiceSelecionado == 4,
              alTocar: () => alCambiarPestana?.call(4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pestaña de navegación normal.
class _PestanaNav extends StatelessWidget {
  final IconData icono;
  final IconData? iconoActivo;
  final String etiqueta;
  final bool estaActiva;
  final bool mostrarBadge;
  final VoidCallback? alTocar;

  const _PestanaNav({
    required this.icono,
    this.iconoActivo,
    required this.etiqueta,
    required this.estaActiva,
    this.mostrarBadge = false,
    this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final color = estaActiva
        ? ColoresApp.primarioOscuro
        : ColoresApp.sobreSuperficieVariante;

    return GestureDetector(
      onTap: alTocar,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono con badge opcional
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  estaActiva ? (iconoActivo ?? icono) : icono,
                  color: color,
                  size: icono == Icons.cloud_off_outlined ? 20 : 18,
                ),
                if (mostrarBadge)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ColoresApp.advertencia,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 2),

            // Etiqueta
            Text(
              etiqueta,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: estaActiva ? FontWeight.w700 : FontWeight.w500,
                height: 14 / 11,
                color: color,
              ),
            ),

            // Punto indicador cuando está activa
            if (estaActiva) ...[
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: ColoresApp.primario,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// El botón circular central "Reportar +" elevado sobre la barra.
class _BotonReportarCentral extends StatelessWidget {
  final bool estaActivo;
  final VoidCallback? alTocar;

  const _BotonReportarCentral({required this.estaActivo, this.alTocar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 44,
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, -20),
            child: Column(
              children: [
                // Círculo elevado con sombra
                GestureDetector(
                  onTap: alTocar,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: ColoresApp.primario,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x59781E23),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Etiqueta debajo
                Text(
                  'Reportar',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 14 / 11,
                    color: ColoresApp.primarioOscuro,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
