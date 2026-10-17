import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/config/rutas_app.dart';
import 'package:bugareport/modelos/usuario.dart';
import 'package:bugareport/servicios/servicio_autenticacion.dart';
import 'package:bugareport/servicios/servicio_preferencias.dart';
import 'package:bugareport/servicios/servicio_borrador.dart';

/// Pantalla de Configuración y Ajustes de BugaReport.
///
/// Comportamiento según el modo de acceso:
/// - **Invitado (sin sesión):** Sección de perfil muestra "Invitado" + botón "Iniciar Sesión".
/// - **Autenticado:** Muestra nombre, email, documento y comuna del ciudadano.
///
/// Las secciones de Notificaciones e Info se muestran siempre.
class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _EstadoPantallaAjustes();
}

class _EstadoPantallaAjustes extends State<PantallaAjustes> {
  final _prefs = ServicioPreferencias.instancia;

  Usuario? _usuario;
  bool _cargandoPerfil = true;
  bool _cerrandoSesion = false;

  // Estado de toggles de notificaciones
  bool _notifReportes = true;
  bool _notifMantenimiento = true;
  bool _notifAlcaldia = false;

  // Información de versión
  String _versionApp = '...';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final resultados = await Future.wait([
      ServicioAutenticacion.instancia.obtenerPerfilActual(),
      _prefs.notificacionesReportesActivas(),
      _prefs.notificacionesMantenimientoActivas(),
      _prefs.notificacionesAlcaldiaActivas(),
      _prefs.obtenerVersionApp(),
    ]);

    if (!mounted) return;
    setState(() {
      _usuario = resultados[0] as Usuario?;
      _notifReportes = resultados[1] as bool;
      _notifMantenimiento = resultados[2] as bool;
      _notifAlcaldia = resultados[3] as bool;
      _versionApp = resultados[4] as String;
      _cargandoPerfil = false;
    });
  }

  bool get _esInvitado => _usuario == null;

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        content: const Text('¿Estás seguro que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Salir',
              style: TextStyle(color: ColoresApp.error),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _cerrandoSesion = true);
    // HU13: limpiar borrador local al cerrar sesión
    await ServicioBorrador.instancia.descartarBorrador();
    await ServicioAutenticacion.instancia.cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      RutasApp.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: _construirAppBar(),
      body: _cargandoPerfil
          ? const Center(
              child: CircularProgressIndicator(color: ColoresApp.primario),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Sección Perfil ──
                  _construirSeccionPerfil(),
                  const SizedBox(height: 20),

                  // ── Sección Notificaciones ──
                  _construirSeccionNotificaciones(),
                  const SizedBox(height: 20),

                  // ── Sección Acerca de ──
                  _construirSeccionAcercaDe(),
                  const SizedBox(height: 20),

                  // ── Acciones de cuenta (solo si autenticado) ──
                  if (!_esInvitado) _construirAccionesCuenta(),
                ],
              ),
            ),
    );
  }

  // ── AppBar ──
  AppBar _construirAppBar() {
    return AppBar(
      backgroundColor: ColoresApp.superficie,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        color: ColoresApp.sobreSuperficie,
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Configuración',
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ColoresApp.sobreSuperficie,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ColoresApp.primarioOscuro,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.settings_outlined, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  // ── Sección Perfil — cambia según invitado/autenticado ──
  Widget _construirSeccionPerfil() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiquetaSeccion('Perfil', Icons.person_outline),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _decoracionCard(),
          child: _esInvitado
              ? _construirPerfilInvitado()
              : _construirPerfilAutenticado(),
        ),
      ],
    );
  }

  /// Perfil para modo invitado — muestra avatar genérico + botón de login.
  Widget _construirPerfilInvitado() {
    return Row(
      children: [
        // Avatar genérico
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: ColoresApp.superficieTenue,
            shape: BoxShape.circle,
            border: Border.all(color: ColoresApp.bordeClaro, width: 1.5),
          ),
          child: const Icon(
            Icons.person_outline,
            size: 28,
            color: ColoresApp.contorno,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invitado',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.sobreSuperficie,
                ),
              ),
              Text(
                'Estás explorando en modo consulta',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ColoresApp.sobreSuperficieVariante,
                ),
              ),
            ],
          ),
        ),
        // Botón Iniciar Sesión
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(RutasApp.login),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ColoresApp.primarioOscuro,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Iniciar Sesión',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Perfil para usuario autenticado — datos reales de la BD.
  Widget _construirPerfilAutenticado() {
    final usuario = _usuario!;
    return Column(
      children: [
        // Avatar con inicial
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ColoresApp.primarioClaro,
                shape: BoxShape.circle,
                border: Border.all(color: ColoresApp.primario, width: 1.5),
              ),
              child: Center(
                child: Text(
                  usuario.primerNombre.isNotEmpty
                      ? usuario.primerNombre[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ColoresApp.primarioOscuro,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombreCompleto,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ColoresApp.sobreSuperficie,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    usuario.email,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ColoresApp.sobreSuperficieVariante,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Badge rol
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ColoresApp.terciarioClaro.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                usuario.esAdmin ? 'Admin' : 'Ciudadano',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.terciarioOscuro,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 20),
        // Datos de documento y comuna
        _filaInfo(
          Icons.badge_outlined,
          '${usuario.tipoDocumento} ${usuario.numeroDocumento}',
          'Documento de identidad',
        ),
        if (usuario.celular != null && usuario.celular!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _filaInfo(Icons.phone_outlined, usuario.celular!, 'Celular'),
        ],
        if (usuario.comuna != null && usuario.comuna!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _filaInfo(Icons.location_on_outlined, usuario.comuna!, 'Zona habitual'),
        ],
      ],
    );
  }

  // ── Sección Notificaciones ──
  Widget _construirSeccionNotificaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiquetaSeccion('Notificaciones', Icons.notifications_outlined),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: _decoracionCard(),
          child: Column(
            children: [
              _filadeToggle(
                icono: Icons.assignment_outlined,
                titulo: 'Alertas de mis reportes',
                subtitulo: 'Cuando cambie el estado de un reporte tuyo',
                valor: _notifReportes,
                alCambiar: (v) async {
                  setState(() => _notifReportes = v);
                  await _prefs.setNotificacionesReportes(v);
                },
              ),
              _divisorLeve(),
              _filadeToggle(
                icono: Icons.build_outlined,
                titulo: 'Avisos de mantenimiento',
                subtitulo: 'Mantenimiento planificado de la plataforma',
                valor: _notifMantenimiento,
                alCambiar: (v) async {
                  setState(() => _notifMantenimiento = v);
                  await _prefs.setNotificacionesMantenimiento(v);
                },
              ),
              _divisorLeve(),
              _filadeToggle(
                icono: Icons.account_balance_outlined,
                titulo: 'Noticias de la Alcaldía',
                subtitulo: 'Anuncios oficiales del despacho municipal',
                valor: _notifAlcaldia,
                alCambiar: (v) async {
                  setState(() => _notifAlcaldia = v);
                  await _prefs.setNotificacionesAlcaldia(v);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Sección Acerca de ──
  Widget _construirSeccionAcercaDe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiquetaSeccion('Acerca de BugaReport', Icons.info_outline),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: _decoracionCard(),
          child: Column(
            children: [
              // Versión
              _filaInfoCard(
                icono: Icons.info_outline,
                titulo: 'Versión',
                valor: _versionApp,
              ),
              _divisorLeve(),

              // Actualización
              _filaAccionCard(
                icono: Icons.system_update_outlined,
                titulo: 'Buscar actualización',
                subtitulo: 'Descargar última versión disponible',
                alTocar: () => _abrirUrl(ServicioPreferencias.urlDescargaApk),
              ),
              _divisorLeve(),

              // Términos
              _filaAccionCard(
                icono: Icons.gavel_outlined,
                titulo: 'Términos y condiciones',
                subtitulo: 'Ver el documento legal completo',
                alTocar: () => Navigator.of(context).pushNamed(RutasApp.terminos),
              ),
              _divisorLeve(),

              // Licencias
              _filaAccionCard(
                icono: Icons.code_outlined,
                titulo: 'Licencias open source',
                subtitulo: 'Paquetes usados en esta app',
                alTocar: () => showLicensePage(
                  context: context,
                  applicationName: 'BugaReport',
                  applicationVersion: _versionApp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Botones de cuenta ──
  Widget _construirAccionesCuenta() {
    return Column(
      children: [
        // Cerrar sesión
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _cerrandoSesion ? null : _cerrarSesion,
            icon: _cerrandoSesion
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.logout, size: 18),
            label: Text(
              _cerrandoSesion ? 'Cerrando sesión...' : 'Cerrar Sesión',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Footer institucional
        Text(
          'Portal de Veeduría Ciudadana\nAlcaldía de Guadalajara de Buga',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: ColoresApp.contorno,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Helpers de UI ──

  Widget _etiquetaSeccion(String texto, [IconData? icono]) {
    return Row(
      children: [
        if (icono != null) ...[
          Icon(icono, size: 16, color: ColoresApp.primarioOscuro),
          const SizedBox(width: 6),
        ],
        Text(
          texto,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: ColoresApp.primarioOscuro,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  BoxDecoration _decoracionCard() {
    return BoxDecoration(
      color: ColoresApp.superficie,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  Widget _filaInfo(IconData icono, String valor, String etiqueta) {
    return Row(
      children: [
        Icon(icono, size: 16, color: ColoresApp.sobreSuperficieVariante),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: ColoresApp.contorno,
                ),
              ),
              Text(
                valor,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ColoresApp.sobreSuperficie,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filadeToggle({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required Future<void> Function(bool) alCambiar,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ColoresApp.superficieTenue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, size: 18, color: ColoresApp.sobreSuperficieVariante),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColoresApp.sobreSuperficie,
                  ),
                ),
                Text(
                  subtitulo,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ColoresApp.contorno,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: valor,
            onChanged: alCambiar,
            activeThumbColor: Colors.white,
            activeTrackColor: ColoresApp.terciario,
          ),
        ],
      ),
    );
  }

  Widget _filaInfoCard({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icono, size: 18, color: ColoresApp.sobreSuperficieVariante),
          const SizedBox(width: 12),
          Text(
            titulo,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ColoresApp.sobreSuperficie,
            ),
          ),
          const Spacer(),
          Text(
            valor,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ColoresApp.sobreSuperficieVariante,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaAccionCard({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback alTocar,
  }) {
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icono, size: 18, color: ColoresApp.sobreSuperficieVariante),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColoresApp.sobreSuperficie,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ColoresApp.contorno,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: ColoresApp.contorno,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divisorLeve() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
      color: Color(0xFFEEEEEE),
    );
  }

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
