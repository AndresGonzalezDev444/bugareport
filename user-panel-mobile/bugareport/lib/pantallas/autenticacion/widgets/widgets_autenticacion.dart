import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';

/// Botón primario reutilizable con estilo BugaReport.
/// Color rojo `#5B0510`, Montserrat Bold, sombra, estado de carga.
class BotonPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback? alTocar;
  final bool cargando;
  final double altura;
  final IconData? iconoSufijo;

  const BotonPrimario({
    super.key,
    required this.texto,
    this.alTocar,
    this.cargando = false,
    this.altura = 52,
    this.iconoSufijo,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: altura,
      child: ElevatedButton(
        onPressed: (cargando || alTocar == null) ? null : alTocar,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primarioOscuro,
          disabledBackgroundColor: ColoresApp.contorno.withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: ColoresApp.primarioOscuro.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    texto,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (iconoSufijo != null) ...[
                    const SizedBox(width: 8),
                    Icon(iconoSufijo, size: 18, color: Colors.white),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Dropdown para seleccionar el tipo de documento (CC, TI, CE, PEP).
class SelectorTipoDocumento extends StatelessWidget {
  final String valorSeleccionado;
  final ValueChanged<String?> alCambiar;

  const SelectorTipoDocumento({
    super.key,
    required this.valorSeleccionado,
    required this.alCambiar,
  });

  static const _opciones = ['CC', 'TI', 'CE', 'PEP'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C2340).withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valorSeleccionado,
          onChanged: alCambiar,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: ColoresApp.contorno,
          ),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColoresApp.sobreSuperficie,
          ),
          items: _opciones.map((tipo) {
            return DropdownMenuItem(value: tipo, child: Text(tipo));
          }).toList(),
        ),
      ),
    );
  }
}

/// Indicador visual de fortaleza de contraseña (3 barras).
/// Verde completo cuando cumple: mayúscula + número + símbolo.
class IndicadorFortaleza extends StatelessWidget {
  final String contrasena;

  const IndicadorFortaleza({super.key, required this.contrasena});

  int _calcularNivel() {
    if (contrasena.isEmpty) return 0;
    int nivel = 0;
    if (contrasena.length >= 8) { nivel++; }
    if (contrasena.contains(RegExp(r'[A-Z]')) &&
        contrasena.contains(RegExp(r'[0-9]'))) { nivel++; }
    if (contrasena.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;`~]'))) {
      nivel++;
    }
    return nivel;
  }

  Color _colorNivel(int nivel) {
    switch (nivel) {
      case 1:
        return ColoresApp.error;
      case 2:
        return ColoresApp.advertencia;
      case 3:
        return ColoresApp.terciario;
      default:
        return const Color(0xFFE4E7FF);
    }
  }

  String _etiquetaNivel(int nivel) {
    switch (nivel) {
      case 1:
        return 'Débil';
      case 2:
        return 'Media';
      case 3:
        return 'Segura ✓';
      default:
        return 'Incluye mayúscula, número y símbolo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final nivel = _calcularNivel();
    final color = _colorNivel(nivel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barras de nivel
        Row(
          children: List.generate(3, (i) {
            final activa = i < nivel;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                decoration: BoxDecoration(
                  color: activa ? color : const Color(0xFFE4E7FF),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        // Texto descriptivo
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: nivel > 0 ? color : ColoresApp.sobreSuperficieVariante,
            height: 14 / 11,
          ),
          child: Text(_etiquetaNivel(nivel)),
        ),
      ],
    );
  }
}

/// Selector de comuna/cuadrante con opción de GPS automático.
class SelectorComuna extends StatelessWidget {
  final String? valorSeleccionado;
  final ValueChanged<String?> alSeleccionar;
  final VoidCallback alUsarUbicacion;

  const SelectorComuna({
    super.key,
    this.valorSeleccionado,
    required this.alSeleccionar,
    required this.alUsarUbicacion,
  });

  // Comunas y barrios reconocidos de Guadalajara de Buga
  static const _comunas = [
    'Comuna 1 — Centro',
    'Comuna 2 — Sur',
    'Comuna 3 — Occidente',
    'Comuna 4 — Norte',
    'Comuna 5 — Oriente',
    'Comuna 6 — Noroccidente',
    'Zona Rural — Corregimiento',
    'Otro (especificar)',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dropdown de comunas
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C2340).withValues(alpha: 0.06),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: valorSeleccionado,
                hint: Text(
                  'Selecciona tu zona o comuna',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ColoresApp.contorno,
                  ),
                ),
                onChanged: alSeleccionar,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: ColoresApp.contorno,
                ),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ColoresApp.sobreSuperficie,
                ),
                items: _comunas.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Botón GPS
        Tooltip(
          message: 'Usar mi ubicación actual',
          child: GestureDetector(
            onTap: alUsarUbicacion,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ColoresApp.terciarioClaro.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColoresApp.terciario.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.my_location,
                color: ColoresApp.terciario,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
