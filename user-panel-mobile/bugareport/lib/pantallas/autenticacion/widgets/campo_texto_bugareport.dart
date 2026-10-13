import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';

/// Campo de texto con el estilo exacto del Figma BugaReport.
/// Fondo #F3F2FF, borde radius 12px, ícono izquierdo, sombra tenue.
class CampoTextoBugaReport extends StatefulWidget {
  final String etiqueta;
  final String? pista;
  final String? textoAyuda;
  final IconData? iconoIzquierdo;
  final Widget? sufijo;
  final bool esClave;
  final bool soloLectura;
  final TextEditingController? controlador;
  final TextInputType? tipoPunteroTeclado;
  final TextInputAction accionTeclado;
  final List<TextInputFormatter>? formateadores;
  final String? Function(String?)? validador;
  final void Function(String)? alCambiar;
  final void Function(String)? alEnviar;
  final void Function()? alTocar;
  final int? maxLineas;
  final int? maxCaracteres;

  const CampoTextoBugaReport({
    super.key,
    required this.etiqueta,
    this.pista,
    this.textoAyuda,
    this.iconoIzquierdo,
    this.sufijo,
    this.esClave = false,
    this.soloLectura = false,
    this.controlador,
    this.tipoPunteroTeclado,
    this.accionTeclado = TextInputAction.next,
    this.formateadores,
    this.validador,
    this.alCambiar,
    this.alEnviar,
    this.alTocar,
    this.maxLineas = 1,
    this.maxCaracteres,
  });

  @override
  State<CampoTextoBugaReport> createState() => _EstadoCampoTextoBugaReport();
}

class _EstadoCampoTextoBugaReport extends State<CampoTextoBugaReport> {
  bool _mostrarClave = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Etiqueta ──
        Row(
          children: [
            Text(
              widget.etiqueta,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColoresApp.sobreSuperficie,
                height: 16 / 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ── Input ──
        TextFormField(
          controller: widget.controlador,
          obscureText: widget.esClave && !_mostrarClave,
          readOnly: widget.soloLectura,
          keyboardType: widget.tipoPunteroTeclado,
          textInputAction: widget.accionTeclado,
          inputFormatters: widget.formateadores,
          maxLines: widget.esClave ? 1 : widget.maxLineas,
          maxLength: widget.maxCaracteres,
          onChanged: widget.alCambiar,
          onFieldSubmitted: widget.alEnviar,
          onTap: widget.alTocar,
          validator: widget.validador,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ColoresApp.sobreSuperficie,
            height: 20 / 14,
          ),
          decoration: InputDecoration(
            hintText: widget.pista,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: ColoresApp.contorno.withValues(alpha: 0.7),
            ),
            helperText: widget.textoAyuda,
            helperStyle: GoogleFonts.inter(
              fontSize: 11,
              color: ColoresApp.sobreSuperficieVariante,
              height: 14 / 11,
            ),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF3F2FF), // fondo campo Figma
            contentPadding: EdgeInsets.fromLTRB(
              widget.iconoIzquierdo != null ? 40 : 16,
              13,
              widget.esClave ? 48 : 16,
              14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ColoresApp.primario,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ColoresApp.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ColoresApp.error,
                width: 1.5,
              ),
            ),
            prefixIcon: widget.iconoIzquierdo != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      widget.iconoIzquierdo,
                      size: 18,
                      color: ColoresApp.sobreSuperficieVariante,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 48,
            ),
            suffixIcon: widget.esClave
                ? _botonMostrarClave()
                : widget.sufijo != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: widget.sufijo,
                      )
                    : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ),
      ],
    );
  }

  Widget _botonMostrarClave() {
    return IconButton(
      icon: Icon(
        _mostrarClave
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        size: 20,
        color: ColoresApp.sobreSuperficieVariante,
      ),
      onPressed: () => setState(() => _mostrarClave = !_mostrarClave),
      splashRadius: 18,
    );
  }
}
