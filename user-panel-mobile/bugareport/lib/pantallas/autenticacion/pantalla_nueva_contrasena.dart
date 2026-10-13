import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/config/rutas_app.dart';
import 'package:bugareport/servicios/servicio_autenticacion.dart';
import 'package:bugareport/modelos/usuario.dart';
import 'widgets/campo_texto_bugareport.dart';
import 'widgets/widgets_autenticacion.dart';

/// Pantalla de nueva contraseña — Paso 2 de recuperación.
///
/// Se abre cuando el ciudadano toca el enlace del correo de recuperación
/// (Deep Link: bugareport://nueva-contrasena).
/// Supabase establece una sesión temporal para permitir el cambio.
class PantallaNuevaContrasena extends StatefulWidget {
  const PantallaNuevaContrasena({super.key});

  @override
  State<PantallaNuevaContrasena> createState() =>
      _EstadoPantallaNuevaContrasena();
}

class _EstadoPantallaNuevaContrasena extends State<PantallaNuevaContrasena> {
  final _claveFormulario = GlobalKey<FormState>();
  final _ctrlNuevaContrasena = TextEditingController();
  final _ctrlConfirmar = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _ctrlNuevaContrasena.dispose();
    _ctrlConfirmar.dispose();
    super.dispose();
  }

  Future<void> _actualizarContrasena() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _cargando = true);

    try {
      await ServicioAutenticacion.instancia.actualizarContrasena(
        _ctrlNuevaContrasena.text,
      );
      if (!mounted) return;
      _mostrarDialogoExito();
    } on ExcepcionAutenticacion catch (e) {
      if (!mounted) return;
      _mostrarError(e.mensajeAmigable);
    } catch (_) {
      if (!mounted) return;
      _mostrarError(
        'No se pudo actualizar la contraseña. El enlace puede haber expirado. '
        'Solicita un nuevo enlace de recuperación.',
      );
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
        duration: const Duration(seconds: 5),
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ColoresApp.terciarioClaro.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 40,
                color: ColoresApp.terciario,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Contraseña\nactualizada!',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ColoresApp.sobreSuperficie,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tu contraseña ha sido cambiada exitosamente. '
              'Ya puedes iniciar sesión con tu nueva contraseña.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ColoresApp.sobreSuperficieVariante,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            BotonPrimario(
              texto: 'Iniciar Sesión',
              iconoSufijo: Icons.arrow_forward,
              alTocar: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RutasApp.login,
                  (route) => false,
                );
              },
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
          'Nueva Contraseña',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColoresApp.primarioOscuro,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Ícono
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ColoresApp.primarioClaro.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 40,
                color: ColoresApp.primario,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Crea tu nueva contraseña',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ColoresApp.sobreSuperficie,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Ingresa una contraseña segura para proteger tu cuenta de BugaReport.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ColoresApp.sobreSuperficieVariante,
                height: 1.5,
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
                    // Nueva contraseña
                    CampoTextoBugaReport(
                      etiqueta: 'Nueva contraseña *',
                      iconoIzquierdo: Icons.lock_outline,
                      controlador: _ctrlNuevaContrasena,
                      esClave: true,
                      validador: (v) {
                        if (v == null || v.isEmpty) return 'Crea una contraseña';
                        if (v.length < 8) return 'Mínimo 8 caracteres';
                        if (!v.contains(RegExp(r'[A-Z]'))) {
                          return 'Incluye al menos una mayúscula';
                        }
                        if (!v.contains(RegExp(r'[0-9]'))) {
                          return 'Incluye al menos un número';
                        }
                        return null;
                      },
                      alCambiar: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 8),

                    // Indicador fortaleza
                    IndicadorFortaleza(
                      contrasena: _ctrlNuevaContrasena.text,
                    ),

                    const SizedBox(height: 16),

                    // Confirmar contraseña
                    CampoTextoBugaReport(
                      etiqueta: 'Confirmar nueva contraseña *',
                      iconoIzquierdo: Icons.lock_outline,
                      controlador: _ctrlConfirmar,
                      esClave: true,
                      validador: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirma tu contraseña';
                        }
                        if (v != _ctrlNuevaContrasena.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    BotonPrimario(
                      texto: 'Actualizar contraseña',
                      iconoSufijo: Icons.check,
                      cargando: _cargando,
                      alTocar: _actualizarContrasena,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alerta si el link puede estar expirado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColoresApp.advertenciaFondo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    size: 16,
                    color: ColoresApp.advertencia,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El enlace de recuperación expira en 1 hora. '
                      'Si ves un error, solicita un nuevo enlace desde la pantalla de login.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ColoresApp.advertencia,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
