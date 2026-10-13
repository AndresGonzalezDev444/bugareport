import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/config/rutas_app.dart';
import 'package:bugareport/servicios/servicio_consentimiento.dart';

/// Pantalla de Términos, Condiciones y Política de Privacidad.
///
/// - Carga el documento legal desde assets/legal/ (offline-first, sin red).
/// - El ScrollController detecta cuando el ciudadano llega al final.
/// - El botón "Aceptar" solo se habilita al completar la lectura del scroll.
/// - Al aceptar, persiste el consentimiento con [ServicioConsentimiento]
///   y navega a la pantalla de login.
class PantallaTerminos extends StatefulWidget {
  const PantallaTerminos({super.key});

  @override
  State<PantallaTerminos> createState() => _EstadoPantallaTerminos();
}

class _EstadoPantallaTerminos extends State<PantallaTerminos> {
  final ScrollController _controladorScroll = ScrollController();
  bool _terminoDeScroll = false;
  bool _guardandoConsentimiento = false;
  String _contenidoLegal = '';
  bool _cargandoDocumento = true;

  @override
  void initState() {
    super.initState();
    _cargarDocumentoLegal();
    _controladorScroll.addListener(_verificarScrollAlFinal);
  }

  @override
  void dispose() {
    _controladorScroll.removeListener(_verificarScrollAlFinal);
    _controladorScroll.dispose();
    super.dispose();
  }

  // ── Carga del documento ──

  Future<void> _cargarDocumentoLegal() async {
    final contenido = await rootBundle.loadString(
      'assets/legal/terminos_condiciones.md',
    );
    if (!mounted) return;
    setState(() {
      _contenidoLegal = contenido;
      _cargandoDocumento = false;
    });
  }

  // ── Detección de scroll al final ──

  void _verificarScrollAlFinal() {
    if (!_controladorScroll.hasClients) return;
    final posicion = _controladorScroll.position;
    // Considerar "al final" cuando falten menos de 48px para el extremo
    final alFinal = posicion.pixels >= posicion.maxScrollExtent - 48;
    if (alFinal && !_terminoDeScroll) {
      setState(() => _terminoDeScroll = true);
    }
  }

  // ── Acción de aceptar ──

  Future<void> _aceptarTerminos() async {
    if (!_terminoDeScroll || _guardandoConsentimiento) return;
    setState(() => _guardandoConsentimiento = true);
    await ServicioConsentimiento.instancia.aceptarTerminos();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RutasApp.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      body: Column(
        children: [
          _construirEncabezado(),
          Expanded(child: _construirCuerpo()),
          _construirPieConBoton(),
        ],
      ),
    );
  }

  // ── Encabezado con logo y título ──
  Widget _construirEncabezado() {
    return Container(
      color: ColoresApp.superficie,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ColoresApp.superficie,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo + badge
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo-buga-report.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: ColoresApp.terciarioClaro,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Oficial',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ColoresApp.terciarioOscuro,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Términos, Condiciones y Política de Privacidad',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.sobreSuperficie,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Alcaldía de Guadalajara de Buga • Versión 1.0 • Oct. 2026',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: ColoresApp.contorno,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cuerpo: documento Markdown desplazable ──
  Widget _construirCuerpo() {
    if (_cargandoDocumento) {
      return const Center(
        child: CircularProgressIndicator(color: ColoresApp.primario),
      );
    }

    return Stack(
      children: [
        Markdown(
          controller: _controladorScroll,
          data: _contenidoLegal,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          styleSheet: _estiloMarkdown(),
        ),

        // Degradado superior indicando que hay más contenido arriba
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColoresApp.fondo,
                    ColoresApp.fondo.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Indicador visual "Desplázate para continuar" mientras no termina el scroll
        if (!_terminoDeScroll)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      ColoresApp.fondo,
                      ColoresApp.fondo.withValues(alpha: 0),
                    ],
                  ),
                ),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: ColoresApp.primario,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Desplázate para leer todo el documento',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.primario,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Pie con botón de aceptar ──
  Widget _construirPieConBoton() {
    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de progreso de lectura
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 4,
                decoration: BoxDecoration(
                  color:
                      _terminoDeScroll
                          ? ColoresApp.terciario
                          : const Color(0xFFE4E7FF),
                  borderRadius: BorderRadius.circular(9999),
                ),
                margin: const EdgeInsets.only(bottom: 12),
              ),

              // Texto de estado
              Text(
                _terminoDeScroll
                    ? '✓ Has leído el documento completo'
                    : 'Lee el documento completo para continuar',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      _terminoDeScroll
                          ? ColoresApp.terciario
                          : ColoresApp.contorno,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Botón "Aceptar Términos y Condiciones"
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _terminoDeScroll ? 1.0 : 0.4,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _terminoDeScroll ? _aceptarTerminos : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.primarioOscuro,
                      disabledBackgroundColor: ColoresApp.contorno,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _terminoDeScroll ? 3 : 0,
                      shadowColor: ColoresApp.primarioSombra,
                    ),
                    child:
                        _guardandoConsentimiento
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Aceptar Términos y Condiciones',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Nota habeas data
              Text(
                'Al aceptar, confirmas que conoces tus derechos según\nla Ley 1581 de Protección de Datos (Habeas Data).',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: ColoresApp.contorno,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Estilos del Markdown ──
  MarkdownStyleSheet _estiloMarkdown() {
    return MarkdownStyleSheet(
      h1: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ColoresApp.primarioOscuro,
        height: 1.3,
      ),
      h2: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: ColoresApp.sobreSuperficie,
        height: 1.4,
      ),
      h3: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: ColoresApp.sobreSuperficie,
      ),
      p: GoogleFonts.inter(
        fontSize: 13,
        color: ColoresApp.sobreSuperficieVariante,
        height: 1.6,
      ),
      strong: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: ColoresApp.sobreSuperficie,
      ),
      listBullet: GoogleFonts.inter(
        fontSize: 13,
        color: ColoresApp.primario,
      ),
      blockquote: GoogleFonts.inter(
        fontSize: 12,
        color: ColoresApp.contorno,
        fontStyle: FontStyle.italic,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ColoresApp.bordeClaro,
            width: 1,
          ),
        ),
      ),
    );
  }
}
