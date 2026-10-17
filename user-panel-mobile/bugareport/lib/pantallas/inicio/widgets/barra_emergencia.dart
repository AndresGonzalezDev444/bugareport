import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/servicios/servicio_ubicacion.dart';

/// Sección de emergencia expandida con llamadas directas + WhatsApp con ubicación.
///
/// Números oficiales de emergencia Guadalajara de Buga, Valle del Cauca.
class BarraEmergencia extends StatelessWidget {
  const BarraEmergencia({super.key});

  // ── Números reales de Buga ──
  static const _lineas = [
    _LineaEmergencia('Policía', '123', Icons.local_police_outlined, Color(0xFF1A237E)),
    _LineaEmergencia('Bomberos', '119', Icons.local_fire_department_outlined, Color(0xFFB71C1C)),
    _LineaEmergencia('Cruz Roja', '132', Icons.medical_services_outlined, Color(0xFFC62828)),
    _LineaEmergencia('Def. Civil', '144', Icons.security_outlined, Color(0xFF1B5E20)),
  ];

  static const String _numeroWhatsApp = '573132640001'; // Alcaldía Buga – confirmar
  static const String _mensajePredeterminado =
      'Necesito asistencia. Estoy reportando una emergencia desde la app BugaReport.\n'
      'Mi ubicación: ';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.emergenciaFondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColoresApp.primario.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: ColoresApp.primario,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emergency_outlined, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LÍNEA DE EMERGENCIA',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ColoresApp.primario,
                      letterSpacing: -0.025 * 12,
                    ),
                  ),
                  Text(
                    'Cuadrantes Emergencia Buga',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ColoresApp.sobreSuperficieVariante,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFFFDAD8)),
          const SizedBox(height: 10),

          // ── Grid 2×2 de llamadas ──
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: _lineas
                .map((l) => _BotonLlamada(linea: l))
                .toList(),
          ),

          const SizedBox(height: 10),

          // ── Botón WhatsApp con ubicación ──
          _BotonWhatsApp(
            numero: _numeroWhatsApp,
            mensajeBase: _mensajePredeterminado,
          ),
        ],
      ),
    );
  }
}

// ── Modelo de línea de emergencia ──
class _LineaEmergencia {
  final String nombre;
  final String numero;
  final IconData icono;
  final Color color;
  const _LineaEmergencia(this.nombre, this.numero, this.icono, this.color);
}

// ── Botón de llamada individual ──
class _BotonLlamada extends StatelessWidget {
  final _LineaEmergencia linea;
  const _BotonLlamada({required this.linea});

  Future<void> _llamar() async {
    final uri = Uri.parse('tel:${linea.numero}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _llamar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: linea.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: linea.color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(linea.icono, size: 16, color: linea.color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    linea.nombre,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.sobreSuperficie,
                    ),
                  ),
                  Text(
                    linea.numero,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: linea.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.call, size: 14, color: linea.color),
          ],
        ),
      ),
    );
  }
}

// ── Botón WhatsApp con mensaje y ubicación GPS ──
class _BotonWhatsApp extends StatefulWidget {
  final String numero;
  final String mensajeBase;
  const _BotonWhatsApp({required this.numero, required this.mensajeBase});

  @override
  State<_BotonWhatsApp> createState() => _EstadoBotonWhatsApp();
}

class _EstadoBotonWhatsApp extends State<_BotonWhatsApp> {
  bool _cargando = false;

  Future<void> _abrirWhatsApp() async {
    setState(() => _cargando = true);
    try {
      String ubicacion = '';
      try {
        final pos = await ServicioUbicacion.instancia
            .obtenerPosicionActual()
            .timeout(const Duration(seconds: 5));
        ubicacion =
            'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
      } catch (_) {
        ubicacion = '(ubicación no disponible)';
      }

      final mensaje = Uri.encodeComponent(
        '${widget.mensajeBase}$ubicacion',
      );
      final uri = Uri.parse('https://wa.me/${widget.numero}?text=$mensaje');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _cargando ? null : _abrirWhatsApp,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF25D366).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.chat_outlined, size: 18, color: Color(0xFF128C7E)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WhatsApp Alcaldía de Buga',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF075E54),
                    ),
                  ),
                  Text(
                    'Adjunta tu ubicación en tiempo real',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ColoresApp.sobreSuperficieVariante,
                    ),
                  ),
                ],
              ),
            ),
            if (_cargando)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF128C7E),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: Color(0xFF128C7E),
              ),
          ],
        ),
      ),
    );
  }
}
