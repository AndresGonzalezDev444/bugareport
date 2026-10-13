import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/config/rutas_app.dart';
import 'package:bugareport/servicios/servicio_consentimiento.dart';

/// Pantalla de Splash / Decisor de Ruta.
///
/// Muestra el logo mientras determina a qué pantalla debe ir el usuario:
///
///   1. ¿Aceptó los términos?  NO → /terminos
///   2. ¿Tiene sesión activa?  SÍ → /inicio
///   3. En cualquier otro caso → /login
///
/// Este flujo garantiza el bloqueo de navegación (criterio HU1).
class PantallaSplash extends StatefulWidget {
  const PantallaSplash({super.key});

  @override
  State<PantallaSplash> createState() => _EstadoPantallaSplash();
}

class _EstadoPantallaSplash extends State<PantallaSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controladorAnimacion;
  late final Animation<double> _animacionOpacidad;
  late final Animation<double> _animacionEscala;

  @override
  void initState() {
    super.initState();

    _controladorAnimacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animacionOpacidad = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controladorAnimacion,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animacionEscala = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controladorAnimacion,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controladorAnimacion.forward();
    _determinarRuta();
  }

  @override
  void dispose() {
    _controladorAnimacion.dispose();
    super.dispose();
  }

  Future<void> _determinarRuta() async {
    // Esperar mínimo 1.4s para que la animación sea visible
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1400)),
      _obtenerRutaDestino().then(_navegarA),
    ]);
  }

  Future<String> _obtenerRutaDestino() async {
    // Prioridad 1: ¿Aceptó los términos?
    final acepto = await ServicioConsentimiento.instancia.haAceptadoTerminos();
    if (!acepto) return RutasApp.terminos;

    // Prioridad 2: ¿Tiene sesión activa válida en Supabase?
    final sesion = Supabase.instance.client.auth.currentSession;
    if (sesion != null && !sesion.isExpired) return RutasApp.inicio;

    // Sin sesión activa → pantalla de login
    return RutasApp.login;
  }

  void _navegarA(String ruta) {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(ruta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.primarioOscuro,
      body: Center(
        child: AnimatedBuilder(
          animation: _controladorAnimacion,
          builder: (context, _) {
            return Opacity(
              opacity: _animacionOpacidad.value,
              child: Transform.scale(
                scale: _animacionEscala.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo principal blanco
                    Image.asset(
                      'assets/images/logo-buga-report.png',
                      width: 200,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),

                    const SizedBox(height: 16),

                    // Tagline
                    Text(
                      'Ciudadanos que reportan,\nuna ciudad que avanza',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Indicador de carga discreto
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Marca institucional
                    Text(
                      'ALCALDÍA DE GUADALAJARA DE BUGA',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.05 * 10,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
