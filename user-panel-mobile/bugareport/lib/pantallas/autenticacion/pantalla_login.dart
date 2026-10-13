import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/config/rutas_app.dart';
import 'package:bugareport/servicios/servicio_autenticacion.dart';
import 'package:bugareport/modelos/usuario.dart';
import 'widgets/campo_texto_bugareport.dart';
import 'widgets/widgets_autenticacion.dart';

/// Pantalla de Inicio de Sesión — "BugaReport - Iniciar Sesión" (Figma #5913:2).
///
/// Incluye:
/// - Header institucional con logo, badge "Oficial" y tagline de la Alcaldía
/// - Segmented control tabs: Iniciar Sesión | Registrarme
/// - Formulario: Correo + Contraseña + toggle visibilidad
/// - "¿Olvidaste tu contraseña?" + toggle "Recordarme"
/// - Botón principal "Ingresar a BugaReport"
/// - Botón secundario "Explorar como invitado (modo consulta)"
/// - Footer con link a registro + badge de Habeas Data
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _EstadoPantallaLogin();
}

class _EstadoPantallaLogin extends State<PantallaLogin> {
  final _claveFormulario = GlobalKey<FormState>();
  final _ctrlEmail = TextEditingController();
  final _ctrlContrasena = TextEditingController();
  bool _recordarme = true;
  bool _cargando = false;

  @override
  void dispose() {
    _ctrlEmail.dispose();
    _ctrlContrasena.dispose();
    super.dispose();
  }

  // ── Iniciar sesión ──
  Future<void> _iniciarSesion() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _cargando = true);

    try {
      await ServicioAutenticacion.instancia.iniciarSesion(
        email: _ctrlEmail.text.trim(),
        contrasena: _ctrlContrasena.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(RutasApp.inicio);
    } on ExcepcionAutenticacion catch (e) {
      if (!mounted) return;
      _mostrarError(e.mensajeAmigable);
    } catch (_) {
      if (!mounted) return;
      _mostrarError('Error inesperado. Intenta de nuevo más tarde.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: ColoresApp.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      body: Stack(
        children: [
          // ── Contenido desplazable ──
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 64, bottom: 32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // 1. Card header institucional
                  _construirHeaderInstitucional(),
                  const SizedBox(height: 16),

                  // 2. Tabs Iniciar Sesión | Registrarme
                  _construirTabs(indiceActivo: 0),
                  const SizedBox(height: 16),

                  // 3. Formulario
                  _construirFormulario(),
                  const SizedBox(height: 16),

                  // 4. Sección "O ingresa con"
                  _construirAccesoAlternativo(),
                  const SizedBox(height: 16),

                  // 5. Footer legal + link a registro
                  _construirPieLegal(),
                ],
              ),
            ),
          ),

          // ── AppBar flotante ──
          _construirAppBar(),
        ],
      ),
    );
  }

  // ── AppBar flotante con glassmorphism ──
  Widget _construirAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: ColoresApp.fondo.withValues(alpha: 0.85),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Botón regresar a términos
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: ColoresApp.sobreSuperficie,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Iniciar Sesión',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.primarioOscuro,
                    ),
                  ),
                  const Spacer(),
                  // Círculo rojo derecho (decorativo — Figma)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: ColoresApp.primarioOscuro,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Card header institucional ──
  Widget _construirHeaderInstitucional() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo + "Oficial"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo-buga-report.png',
                height: 36,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
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
          const SizedBox(height: 4),
          // Alcaldía
          Text(
            'ALCALDÍA DE GUADALAJARA DE BUGA',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05 * 11,
              color: ColoresApp.secundario,
            ),
          ),
          const SizedBox(height: 12),
          // Título bienvenida
          Text(
            'Bienvenido de nuevo',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.025 * 24,
              color: ColoresApp.sobreSuperficie,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ingresa con tu correo para gestionar\ntus reportes ciudadanos y aportar a tu comunidad.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ColoresApp.sobreSuperficieVariante,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Segmented control tabs ──
  Widget _construirTabs({required int indiceActivo}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECEDFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Tab: Iniciar Sesión
          Expanded(
            child: _TabSegmentado(
              texto: 'Iniciar Sesión',
              icono: Icons.lock_outline,
              activo: indiceActivo == 0,
              alTocar: () {},
            ),
          ),
          const SizedBox(width: 4),
          // Tab: Registrarme
          Expanded(
            child: _TabSegmentado(
              texto: 'Registrarme',
              icono: Icons.person_add_outlined,
              activo: indiceActivo == 1,
              alTocar: () => Navigator.of(
                context,
              ).pushReplacementNamed(RutasApp.registro),
            ),
          ),
        ],
      ),
    );
  }

  // ── Formulario de login ──
  Widget _construirFormulario() {
    return Form(
      key: _claveFormulario,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColoresApp.superficie,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo email
            CampoTextoBugaReport(
              etiqueta: 'Correo electrónico',
              pista: 'correo@ejemplo.com',
              iconoIzquierdo: Icons.email_outlined,
              controlador: _ctrlEmail,
              tipoPunteroTeclado: TextInputType.emailAddress,
              accionTeclado: TextInputAction.next,
              validador: _validarEmail,
            ),

            const SizedBox(height: 16),

            // Campo contraseña
            CampoTextoBugaReport(
              etiqueta: 'Contraseña',
              pista: 'Ingresa tu contraseña',
              iconoIzquierdo: Icons.lock_outline,
              controlador: _ctrlContrasena,
              esClave: true,
              accionTeclado: TextInputAction.done,
              validador: (v) =>
                  (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
              alEnviar: (_) => _iniciarSesion(),
            ),

            const SizedBox(height: 8),

            // ¿Olvidaste tu contraseña?
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(RutasApp.recuperacion),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 13,
                      color: ColoresApp.primarioOscuro,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '¿Olvidaste tu contraseña?',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.primarioOscuro,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Toggle "Recordarme" + Chip biométrico (decorativo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _recordarme = !_recordarme),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _recordarme
                              ? ColoresApp.primario
                              : const Color(0xFFECEDFF),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        padding: EdgeInsets.only(
                          left: _recordarme ? 18 : 2,
                          top: 2,
                          bottom: 2,
                          right: _recordarme ? 2 : 18,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recordarme',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ColoresApp.sobreSuperficieVariante,
                      ),
                    ),
                  ],
                ),
                // Chip biométrico
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEDFF),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fingerprint,
                        size: 14,
                        color: ColoresApp.primarioOscuro,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Huella / Face ID',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ColoresApp.primarioOscuro,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botón principal
            BotonPrimario(
              texto: 'Ingresar a BugaReport',
              iconoSufijo: Icons.arrow_forward,
              cargando: _cargando,
              alTocar: _iniciarSesion,
            ),
          ],
        ),
      ),
    );
  }

  // ── Acceso alternativo (modo invitado) ──
  Widget _construirAccesoAlternativo() {
    return Column(
      children: [
        // Separador "O INGRESA CON"
        Row(
          children: [
            const Expanded(
              child: Divider(color: Color(0xFFDDE1FF), thickness: 1),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: ColoresApp.fondo,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'O INGRESA CON',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.05 * 11,
                  color: ColoresApp.contorno,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: Color(0xFFDDE1FF), thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Botón modo invitado
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(RutasApp.inicio),
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFFFDCC0).withValues(alpha: 0.5),
              side: const BorderSide(
                color: Color(0xFFFFDCC0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.person_outline,
              color: ColoresApp.secundario,
              size: 18,
            ),
            label: Text(
              'Explorar como invitado (modo consulta)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D1600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Footer: link a registro + habeas data ──
  Widget _construirPieLegal() {
    return Column(
      children: [
        // Link a registro
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '¿Aún no tienes una cuenta municipal? ',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ColoresApp.sobreSuperficieVariante,
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed(RutasApp.registro),
              child: Text(
                'Regístrate aquí',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColoresApp.primarioOscuro,
                  decoration: TextDecoration.underline,
                  decorationColor: ColoresApp.primarioOscuro,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Badge Habeas Data
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColoresApp.terciarioClaro.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 16,
                color: Color(0xFF184938),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protección de Datos Institucional',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.terciarioOscuro,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF1F4F3E),
                          height: 1.5,
                        ),
                        children: const [
                          TextSpan(
                            text:
                                'Tus datos personales están protegidos conforme a la ',
                          ),
                          TextSpan(
                            text: 'Ley 1581',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                ' de Protección de Datos de Colombia (Habeas Data Municipal).',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Validaciones ──
  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Ingresa tu correo';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(valor.trim())) return 'Formato de correo inválido';
    return null;
  }
}

/// Tab individual del segmented control.
class _TabSegmentado extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool activo;
  final VoidCallback alTocar;

  const _TabSegmentado({
    required this.texto,
    required this.icono,
    required this.activo,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: activo ? null : alTocar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: activo ? ColoresApp.primario : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: activo
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 14,
              color: activo
                  ? Colors.white
                  : ColoresApp.sobreSuperficieVariante,
            ),
            const SizedBox(width: 6),
            Text(
              texto,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
                color: activo
                    ? Colors.white
                    : ColoresApp.sobreSuperficieVariante,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
