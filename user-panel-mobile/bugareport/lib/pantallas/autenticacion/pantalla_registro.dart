import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/config/rutas_app.dart';
import 'package:bugareport/servicios/servicio_autenticacion.dart';
import 'package:bugareport/servicios/servicio_ubicacion.dart';
import 'package:bugareport/modelos/usuario.dart';
import 'widgets/campo_texto_bugareport.dart';
import 'widgets/widgets_autenticacion.dart';

/// Pantalla de Registro Ciudadano — "BugaReport - Registro Ciudadano" (Figma #5913:154).
///
/// Campos según el Figma:
///   1. Nombre y apellidos completos*
///   2. Tipo de documento (CC/TI/CE/PEP) + Número*
///   3. Celular de contacto / WhatsApp (+57)*
///   4. Correo electrónico*
///   5. Comuna o cuadrante habitual* (dropdown + GPS)
///   6. Contraseña* (con indicador de fortaleza)
///   7. Repetir contraseña*
///   8. Checkbox: Acepto política de tratamiento de datos (Ley 1581)
///   9. Botón "Crear Cuenta Ciudadana"
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _EstadoPantallaRegistro();
}

class _EstadoPantallaRegistro extends State<PantallaRegistro> {
  final _claveFormulario = GlobalKey<FormState>();

  // Controladores
  final _ctrlNombre = TextEditingController();
  final _ctrlNumeroDoc = TextEditingController();
  final _ctrlCelular = TextEditingController();
  final _ctrlEmail = TextEditingController();
  final _ctrlContrasena = TextEditingController();
  final _ctrlRepetirContrasena = TextEditingController();

  // Estado local
  String _tipoDocumento = 'CC';
  String? _comunaSeleccionada;
  double? _latitudGps;
  double? _longitudGps;
  bool _aceptoPolitica = false;
  bool _cargando = false;
  bool _cargandoGps = false;

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlNumeroDoc.dispose();
    _ctrlCelular.dispose();
    _ctrlEmail.dispose();
    _ctrlContrasena.dispose();
    _ctrlRepetirContrasena.dispose();
    super.dispose();
  }

  // ── Obtener ubicación GPS ──
  Future<void> _usarMiUbicacion() async {
    setState(() => _cargandoGps = true);
    try {
      final posicion = await ServicioUbicacion.instancia.obtenerPosicionActual();
      setState(() {
        _latitudGps = posicion.latitude;
        _longitudGps = posicion.longitude;
        _comunaSeleccionada = 'Ubicación GPS detectada';
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo obtener tu ubicación. Selecciona manualmente.',
              style: GoogleFonts.inter(fontSize: 13),
            ),
            backgroundColor: ColoresApp.advertencia,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargandoGps = false);
    }
  }

  // ── Crear cuenta ──
  Future<void> _crearCuenta() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    if (!_aceptoPolitica) {
      _mostrarError(
        'Debes aceptar la Política de Tratamiento de Datos para continuar.',
      );
      return;
    }

    setState(() => _cargando = true);
    try {
      await ServicioAutenticacion.instancia.registrar(
        email: _ctrlEmail.text.trim(),
        contrasena: _ctrlContrasena.text,
        nombreCompleto: _ctrlNombre.text.trim(),
        tipoDocumento: _tipoDocumento,
        numeroDocumento: _ctrlNumeroDoc.text.trim(),
        celular: _ctrlCelular.text.trim().isEmpty
            ? null
            : '+57${_ctrlCelular.text.trim()}',
        comuna: _comunaSeleccionada,
        latitud: _latitudGps,
        longitud: _longitudGps,
      );
      if (!mounted) return;
      _mostrarDialogoExito();
    } on ExcepcionAutenticacion catch (e) {
      if (!mounted) return;
      _mostrarDialogoError(e.mensajeAmigable);
    } catch (_) {
      if (!mounted) return;
      _mostrarDialogoError(
        'No se pudo completar el registro. Intenta de nuevo más tarde.',
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: ColoresApp.advertencia,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _mostrarDialogoExito() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: ColoresApp.terciarioClaro.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: ColoresApp.terciario,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Cuenta creada!',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColoresApp.sobreSuperficie,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu cuenta ciudadana en BugaReport ha sido creada exitosamente. '
              'Ya puedes iniciar sesión y empezar a reportar incidentes.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ColoresApp.sobreSuperficieVariante,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            BotonPrimario(
              texto: 'Ir a Iniciar Sesión',
              alTocar: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(RutasApp.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoError(String mensaje) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: ColoresApp.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: ColoresApp.error,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error en el registro',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColoresApp.sobreSuperficie,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ColoresApp.sobreSuperficieVariante,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            BotonPrimario(
              texto: 'Intentar de nuevo',
              alTocar: () => Navigator.of(context).pop(),
            ),
          ],
        ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero header
                _construirHeroHeader(),

                // 2. Tabs
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _construirTabs(),
                ),

                // 3. Formulario
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _construirFormulario(),
                ),

                const SizedBox(height: 24),

                // 4. Footer institucional
                _construirFooter(),
              ],
            ),
          ),

          // ── AppBar flotante ──
          _construirAppBar(),
        ],
      ),
    );
  }

  // ── AppBar ──
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
                    'Registro Ciudadano',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.primarioOscuro,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: ColoresApp.primarioOscuro,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_outlined,
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

  // ── Hero header ──
  Widget _construirHeroHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColoresApp.superficie,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C2340).withValues(alpha: 0.06),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E7FF),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_outlined,
                        size: 11,
                        color: ColoresApp.primarioOscuro,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Registro Oficial Alcaldía',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.025 * 11,
                          color: ColoresApp.primarioOscuro,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/logo-buga-report.png',
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Crea tu Cuenta\nCiudadana',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ColoresApp.sobreSuperficie,
                height: 30 / 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Únete a los veedores cívicos de Buga. Registra '
              'incidencias, valida obras y recibe trazabilidad '
              'oficial del despacho municipal.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ColoresApp.sobreSuperficieVariante,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Segmented tabs ──
  Widget _construirTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Iniciar sesión (inactivo)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(
                context,
              ).pushReplacementNamed(RutasApp.login),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 13,
                      color: ColoresApp.sobreSuperficie,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Iniciar Sesión',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.sobreSuperficie,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Registrarme (activo)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: ColoresApp.primarioOscuro,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add_outlined,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Registrarme',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Formulario de registro ──
  Widget _construirFormulario() {
    return Form(
      key: _claveFormulario,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Nombre completo
          CampoTextoBugaReport(
            etiqueta: 'Nombre y Apellidos completos *',
            pista: 'Ej. Carlos Mauricio Benítez',
            textoAyuda: 'Como en tu cédula',
            iconoIzquierdo: Icons.person_outline,
            controlador: _ctrlNombre,
            tipoPunteroTeclado: TextInputType.name,
            validador: (v) =>
                (v == null || v.trim().length < 3)
                    ? 'Ingresa tu nombre completo'
                    : null,
          ),

          const SizedBox(height: 16),

          // 2. Documento de identidad
          _construirCampoDocumento(),

          const SizedBox(height: 16),

          // 3. Celular
          _construirCampoCelular(),

          const SizedBox(height: 16),

          // 4. Email
          CampoTextoBugaReport(
            etiqueta: 'Correo electrónico *',
            pista: 'correo@ejemplo.com',
            iconoIzquierdo: Icons.email_outlined,
            controlador: _ctrlEmail,
            tipoPunteroTeclado: TextInputType.emailAddress,
            validador: _validarEmail,
          ),

          const SizedBox(height: 16),

          // 5. Comuna / cuadrante
          _construirCampoComuna(),

          const SizedBox(height: 16),

          // 6. Contraseña
          _construirCampoContrasena(),

          const SizedBox(height: 16),

          // 7. Repetir contraseña
          _construirCampoRepetirContrasena(),

          const SizedBox(height: 16),

          // 8. Checkbox política
          _construirCheckboxPolitica(),

          const SizedBox(height: 20),

          // 9. Botón crear cuenta
          BotonPrimario(
            texto: 'Crear Cuenta Ciudadana',
            iconoSufijo: Icons.arrow_forward,
            cargando: _cargando,
            alTocar: _crearCuenta,
          ),
        ],
      ),
    );
  }

  // ── Campo tipo + número de documento ──
  Widget _construirCampoDocumento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Documento de Identidad *',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColoresApp.sobreSuperficie,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ColoresApp.terciarioClaro,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 11,
                    color: ColoresApp.terciarioOscuro,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Validación Registraduría',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.terciarioOscuro,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector tipo
            SizedBox(
              width: 90,
              child: SelectorTipoDocumento(
                valorSeleccionado: _tipoDocumento,
                alCambiar: (v) {
                  if (v != null) setState(() => _tipoDocumento = v);
                },
              ),
            ),
            const SizedBox(width: 8),
            // Número
            Expanded(
              child: CampoTextoBugaReport(
                etiqueta: '',
                pista: 'Número de cédula',
                iconoIzquierdo: Icons.badge_outlined,
                controlador: _ctrlNumeroDoc,
                tipoPunteroTeclado: TextInputType.number,
                formateadores: [FilteringTextInputFormatter.digitsOnly],
                validador: (v) =>
                    (v == null || v.trim().length < 6)
                        ? 'Ingresa tu número de documento'
                        : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Campo celular con prefijo +57 ──
  Widget _construirCampoCelular() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Celular de contacto / WhatsApp *',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColoresApp.sobreSuperficie,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Alertas SMS / Chat',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ColoresApp.secundario,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Prefijo fijo +57 Colombia
            Container(
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇨🇴', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '+57',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.sobreSuperficie,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CampoTextoBugaReport(
                etiqueta: '',
                pista: '318 456 7890',
                controlador: _ctrlCelular,
                tipoPunteroTeclado: TextInputType.phone,
                formateadores: [FilteringTextInputFormatter.digitsOnly],
                maxCaracteres: 10,
                validador: (v) =>
                    (v == null || v.trim().length < 10)
                        ? 'Ingresa tu número de celular (10 dígitos)'
                        : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Campo comuna con GPS ──
  Widget _construirCampoComuna() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Comuna o Cuadrante Habitual *',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColoresApp.sobreSuperficie,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Buga, Valle',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ColoresApp.secundario,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _cargandoGps
            ? Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColoresApp.primario,
                    ),
                  ),
                ),
              )
            : SelectorComuna(
                valorSeleccionado: _comunaSeleccionada,
                alSeleccionar: (v) => setState(() {
                  _comunaSeleccionada = v;
                  // Limpiar GPS si seleccionó manualmente
                  _latitudGps = null;
                  _longitudGps = null;
                }),
                alUsarUbicacion: _usarMiUbicacion,
              ),
        // Indicador cuando se usó GPS
        if (_latitudGps != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 12,
                  color: ColoresApp.terciario,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ubicación GPS: ${_latitudGps!.toStringAsFixed(4)}, ${_longitudGps!.toStringAsFixed(4)}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ColoresApp.terciario,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Campo contraseña con indicador de fortaleza ──
  Widget _construirCampoContrasena() {
    return Column(
      children: [
        CampoTextoBugaReport(
          etiqueta: 'Crear Contraseña Segura *',
          iconoIzquierdo: Icons.lock_outline,
          controlador: _ctrlContrasena,
          esClave: true,
          validador: _validarContrasena,
          alCambiar: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        IndicadorFortaleza(contrasena: _ctrlContrasena.text),
      ],
    );
  }

  // ── Campo repetir contraseña ──
  Widget _construirCampoRepetirContrasena() {
    return CampoTextoBugaReport(
      etiqueta: 'Repetir contraseña *',
      iconoIzquierdo: Icons.lock_outline,
      controlador: _ctrlRepetirContrasena,
      esClave: true,
      validador: (v) {
        if (v == null || v.isEmpty) return 'Repite tu contraseña';
        if (v != _ctrlContrasena.text) return 'Las contraseñas no coinciden';
        return null;
      },
    );
  }

  // ── Checkbox de política ──
  Widget _construirCheckboxPolitica() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C2340).withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _aceptoPolitica = !_aceptoPolitica),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: _aceptoPolitica
                    ? ColoresApp.primarioOscuro
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: _aceptoPolitica
                      ? ColoresApp.primarioOscuro
                      : ColoresApp.contorno,
                  width: 1.5,
                ),
              ),
              child: _aceptoPolitica
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ColoresApp.sobreSuperficie,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Acepto la '),
                  TextSpan(
                    text: 'Política de Tratamiento de Datos Personales',
                    style: const TextStyle(
                      color: ColoresApp.primarioOscuro,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' (Ley Estatutaria 1581) de la Alcaldía de Guadalajara de Buga.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer institucional ──
  Widget _construirFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          // Link a login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Ya tienes cuenta en BugaReport?',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ColoresApp.sobreSuperficie,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed(RutasApp.login),
                child: Text(
                  'Inicia Sesión',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColoresApp.primarioOscuro,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Badge soporte municipal
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F2FF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C2340).withValues(alpha: 0.04),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ColoresApp.secundarioClaro.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.headset_mic_outlined,
                    size: 16,
                    color: ColoresApp.secundario,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Línea de soporte municipal',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ColoresApp.sobreSuperficie,
                        ),
                      ),
                      Text(
                        'Llama al 123 Buga o despacho CCO',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: ColoresApp.sobreSuperficieVariante,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE1FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '123',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.primarioOscuro,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Portal de Veeduría Ciudadana • Secretaría de las TIC y Gobierno\nAbierto Buga',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ColoresApp.contorno,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Validaciones ──
  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Ingresa tu correo';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(valor.trim())) return 'Formato de correo inválido';
    return null;
  }

  String? _validarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) return 'Crea una contraseña';
    if (valor.length < 8) return 'Mínimo 8 caracteres';
    if (!valor.contains(RegExp(r'[A-Z]'))) return 'Incluye al menos una mayúscula';
    if (!valor.contains(RegExp(r'[0-9]'))) return 'Incluye al menos un número';
    return null;
  }
}
