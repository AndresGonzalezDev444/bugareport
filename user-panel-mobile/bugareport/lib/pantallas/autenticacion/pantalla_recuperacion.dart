import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/config/rutas_app.dart';
import 'package:bugareport/servicios/servicio_autenticacion.dart';
import 'package:bugareport/modelos/usuario.dart';
import 'widgets/campo_texto_bugareport.dart';
import 'widgets/widgets_autenticacion.dart';

/// Pantalla de recuperación de contraseña — Paso 1.
///
/// El ciudadano ingresa su correo y Supabase envía automáticamente
/// un enlace de recuperación a su bandeja de entrada.
/// COSTO: $0 — el SMTP está incluido en el plan gratuito de Supabase.
class PantallaRecuperacion extends StatefulWidget {
  const PantallaRecuperacion({super.key});

  @override
  State<PantallaRecuperacion> createState() => _EstadoPantallaRecuperacion();
}

class _EstadoPantallaRecuperacion extends State<PantallaRecuperacion> {
  final _claveFormulario = GlobalKey<FormState>();
  final _ctrlEmail = TextEditingController();
  bool _cargando = false;
  bool _correoEnviado = false;
  int _segundosReenvio = 0;

  @override
  void dispose() {
    _ctrlEmail.dispose();
    super.dispose();
  }

  Future<void> _enviarCorreo() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _cargando = true);

    try {
      await ServicioAutenticacion.instancia.enviarCorreoRecuperacion(
        _ctrlEmail.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _correoEnviado = true;
        _segundosReenvio = 60;
      });
      _iniciarCountdown();
    } on ExcepcionAutenticacion catch (e) {
      if (!mounted) return;
      _mostrarError(e.mensajeAmigable);
    } catch (_) {
      if (!mounted) return;
      _mostrarError('Error al enviar el correo. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _iniciarCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _segundosReenvio--);
      return _segundosReenvio > 0;
    });
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
      appBar: AppBar(
        backgroundColor: ColoresApp.superficie,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: ColoresApp.sobreSuperficie,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Recuperar Contraseña',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColoresApp.primarioOscuro,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: ColoresApp.primarioOscuro,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.key_outlined, color: Colors.white, size: 14),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _correoEnviado ? _construirEstadoEnviado() : _construirFormulario(),
          ],
        ),
      ),
    );
  }

  Widget _construirFormulario() {
    return Column(
      children: [
        // Icono ilustrativo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ColoresApp.primarioClaro.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 40,
            color: ColoresApp.primario,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          '¿Olvidaste tu contraseña?',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ColoresApp.sobreSuperficie,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Ingresa el correo electrónico con el que te registraste '
          'y te enviaremos un enlace para restablecer tu contraseña.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: ColoresApp.sobreSuperficieVariante,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Formulario
        Container(
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
          child: Form(
            key: _claveFormulario,
            child: Column(
              children: [
                CampoTextoBugaReport(
                  etiqueta: 'Correo electrónico registrado',
                  pista: 'correo@ejemplo.com',
                  iconoIzquierdo: Icons.email_outlined,
                  controlador: _ctrlEmail,
                  tipoPunteroTeclado: TextInputType.emailAddress,
                  accionTeclado: TextInputAction.done,
                  validador: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa tu correo electrónico';
                    }
                    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!regex.hasMatch(v.trim())) {
                      return 'Formato de correo inválido';
                    }
                    return null;
                  },
                  alEnviar: (_) => _enviarCorreo(),
                ),
                const SizedBox(height: 16),
                BotonPrimario(
                  texto: 'Enviar enlace de recuperación',
                  iconoSufijo: Icons.send_outlined,
                  cargando: _cargando,
                  alTocar: _enviarCorreo,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Nota informativa
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: ColoresApp.sobreSuperficieVariante,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'El enlace llega en pocos minutos. Revisa también tu bandeja de spam.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: ColoresApp.sobreSuperficieVariante,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Volver a Iniciar Sesión',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColoresApp.primarioOscuro,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirEstadoEnviado() {
    return Column(
      children: [
        // Ícono de éxito
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: ColoresApp.terciarioClaro.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 44,
            color: ColoresApp.terciario,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          '¡Correo enviado!',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ColoresApp.sobreSuperficie,
          ),
        ),

        const SizedBox(height: 8),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ColoresApp.sobreSuperficieVariante,
              height: 1.6,
            ),
            children: [
              const TextSpan(
                text: 'Hemos enviado un enlace de recuperación a\n',
              ),
              TextSpan(
                text: _ctrlEmail.text.trim(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.sobreSuperficie,
                ),
              ),
              const TextSpan(
                text:
                    '\n\nRevisa tu bandeja de entrada y sigue las instrucciones del correo.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Card de instrucciones
        Container(
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
              _pasosInstruccion(
                '1',
                'Abre el correo de BugaReport',
                Icons.email_outlined,
              ),
              const Divider(height: 20),
              _pasosInstruccion(
                '2',
                'Toca el enlace "Restablecer contraseña"',
                Icons.touch_app_outlined,
              ),
              const Divider(height: 20),
              _pasosInstruccion(
                '3',
                'Ingresa y confirma tu nueva contraseña',
                Icons.lock_outline,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Botón reenviar con countdown
        _segundosReenvio > 0
            ? Text(
                '¿No recibiste el correo? Reenviar en $_segundosReenvio s',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ColoresApp.contorno,
                ),
              )
            : GestureDetector(
                onTap: _enviarCorreo,
                child: Text(
                  '¿No recibiste el correo? Reenviar',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColoresApp.primarioOscuro,
                    decoration: TextDecoration.underline,
                    decorationColor: ColoresApp.primarioOscuro,
                  ),
                ),
              ),

        const SizedBox(height: 16),

        OutlinedButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(RutasApp.login),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: ColoresApp.primarioOscuro),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Volver a Iniciar Sesión',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColoresApp.primarioOscuro,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pasosInstruccion(String numero, String texto, IconData icono) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: ColoresApp.primarioOscuro,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              numero,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icono, size: 18, color: ColoresApp.sobreSuperficieVariante),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ColoresApp.sobreSuperficie,
            ),
          ),
        ),
      ],
    );
  }
}
