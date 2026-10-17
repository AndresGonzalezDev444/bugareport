import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/config/rutas_app.dart';
import 'package:bugareport/modelos/incidente.dart';
import 'package:bugareport/servicios/servicio_incidentes.dart';
import 'package:bugareport/servicios/servicio_borrador.dart';
import 'widgets/tarjeta_incidente.dart';

/// Pantalla "Mis Reportes" — muestra todos los incidentes del usuario autenticado.
///
/// Incluye:
/// • 3 KPI cards en fila (Total / En gestión / Resueltos)
/// • Filtros tipo píldora horizontal scrollable
/// • Lista de TarjetaIncidente
/// • Callout de borradores pendientes
/// • CTA "Reportar" en footer
class PantallaMisReportes extends StatefulWidget {
  const PantallaMisReportes({super.key});

  @override
  State<PantallaMisReportes> createState() => _EstadoPantallaMisReportes();
}

class _EstadoPantallaMisReportes extends State<PantallaMisReportes> {
  final _svcIncidentes = ServicioIncidentes();

  List<Incidente> _todos = [];
  List<Incidente> _filtrados = [];
  bool _cargando = true;
  String _filtroActual = 'todos';
  int _cantidadBorradores = 0;
  String _busqueda = '';

  // Mapa de etiquetas de filtros
  static const _filtros = [
    ('todos', 'Todos'),
    ('en_proceso', 'En Proceso'),
    ('resuelto', 'Resueltos'),
    ('borrador', 'Borradores'),
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final idUsuario = Supabase.instance.client.auth.currentUser?.id;
      final futures = await Future.wait([
        if (idUsuario != null)
          _svcIncidentes.obtenerIncidentesUsuario(idUsuario)
        else
          Future.value(<Incidente>[]),
        ServicioBorrador.instancia.tieneBorrador(),
      ]);

      final incidentes = futures[0] as List<Incidente>;
      final hayBorrador = futures[1] as bool;

      if (mounted) {
        setState(() {
          _todos = incidentes;
          _cantidadBorradores = hayBorrador ? 1 : 0;
          _cargando = false;
        });
        _aplicarFiltro(_filtroActual);
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _aplicarFiltro(String filtro) {
    setState(() {
      _filtroActual = filtro;
      if (filtro == 'todos') {
        _filtrados = _todos.where(_coincideBusqueda).toList();
      } else if (filtro == 'borrador') {
        _filtrados = [];
      } else {
        _filtrados = _todos
            .where((i) => i.estado == filtro && _coincideBusqueda(i))
            .toList();
      }
    });
  }

  bool _coincideBusqueda(Incidente i) {
    if (_busqueda.isEmpty) return true;
    final q = _busqueda.toLowerCase();
    return i.titulo.toLowerCase().contains(q) ||
        (i.descripcion?.toLowerCase().contains(q) ?? false);
  }

  // ── Estadísticas ──
  int get _totalCount    => _todos.length;
  int get _enGestionCount => _todos.where((i) => i.estado == 'en_proceso').length;
  int get _resueltosCount => _todos.where((i) => i.estado == 'resuelto').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      body: RefreshIndicator(
        color: ColoresApp.primario,
        onRefresh: _cargarDatos,
        child: CustomScrollView(
          slivers: [
            _construirAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 112),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── KPI Cards ──
                  _construirKpiCards(),
                  const SizedBox(height: 20),

                  // ── Buscador ──
                  _construirBuscador(),
                  const SizedBox(height: 20),

                  // ── Filtros ──
                  _construirFiltros(),
                  const SizedBox(height: 20),

                  // ── Lista ──
                  if (_cargando)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: ColoresApp.primario),
                      ),
                    )
                  else if (_filtroActual == 'borrador')
                    _construirSeccionBorradores()
                  else if (_filtrados.isEmpty)
                    _construirEstadoVacio()
                  else
                    Column(
                      children: _filtrados
                          .map((i) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: TarjetaIncidente(
                                  incidente: i,
                                  alVerMapa: () =>
                                      Navigator.of(context).pushNamed(RutasApp.mapa),
                                ),
                              ))
                          .toList(),
                    ),

                  // ── Callout borradores ──
                  if (_cantidadBorradores > 0) ...[
                    const SizedBox(height: 4),
                    _construirCalloutBorradores(),
                  ],

                  const SizedBox(height: 16),

                  // ── CTA Reportar ──
                  _construirCtaReportar(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar con blur ──
  SliverAppBar _construirAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: ColoresApp.superficie.withValues(alpha: 0.95),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        color: ColoresApp.sobreSuperficie,
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PANEL CIUDADANO BUGA',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05 * 10,
              color: ColoresApp.sobreSuperficieVariante,
            ),
          ),
          Text(
            'Mis Reportes',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ColoresApp.primarioOscuro,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F2FF),
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.gavel_outlined, size: 14, color: ColoresApp.primarioOscuro),
              const SizedBox(width: 4),
              Text(
                'Radicados Oficiales',
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
    );
  }

  // ── KPI Cards ──
  Widget _construirKpiCards() {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'Total',
            valor: _totalCount,
            unidad: 'actas',
            subLabel: 'Histórico 2025',
            fondoColor: ColoresApp.superficie,
            textoColor: const Color(0xFF131A36),
            iconoFondo: const Color(0xFFECEDFF),
            iconoColor: ColoresApp.primario,
            icono: Icons.description_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            label: 'En Gestión',
            valor: _enGestionCount,
            unidad: 'activas',
            subLabel: 'Prioridad alta',
            fondoColor: const Color(0x59FFDCC0),
            textoColor: const Color(0xFF6A3B03),
            iconoFondo: const Color(0xFFFEB877),
            iconoColor: const Color(0xFF6A3B03),
            icono: Icons.pending_actions_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            label: 'Resueltos',
            valor: _resueltosCount,
            unidad: 'éxito',
            subLabel: _totalCount > 0
                ? 'Impacto ${(_resueltosCount / _totalCount * 100).round()}%'
                : 'Sin reportes',
            fondoColor: const Color(0x66BBEED6),
            textoColor: const Color(0xFF003223),
            iconoFondo: const Color(0x99BBEED6),
            iconoColor: const Color(0xFF003223),
            icono: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }

  // ── Buscador ──
  Widget _construirBuscador() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B7280), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) {
          _busqueda = v;
          _aplicarFiltro(_filtroActual);
        },
        style: GoogleFonts.inter(fontSize: 13, color: ColoresApp.sobreSuperficie),
        decoration: InputDecoration(
          hintText: 'Buscar en mis reportes...',
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: ColoresApp.sobreSuperficieVariante,
          ),
          prefixIcon: const Icon(Icons.search, size: 18, color: ColoresApp.contorno),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  // ── Filtros horizontales ──
  Widget _construirFiltros() {
    final conteos = {
      'todos': _totalCount,
      'en_proceso': _enGestionCount,
      'resuelto': _resueltosCount,
      'borrador': _cantidadBorradores,
    };

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filtros.length,
        separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (clave, etiqueta) = _filtros[i];
          final activo = _filtroActual == clave;
          final count  = conteos[clave] ?? 0;

          final puntoClave = clave == 'en_proceso'
              ? const Color(0xFF86521B)
              : clave == 'resuelto'
                  ? const Color(0xFF003223)
                  : clave == 'borrador'
                      ? const Color(0xFF6A3B03)
                      : null;

          return GestureDetector(
            onTap: () => _aplicarFiltro(clave),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: activo ? ColoresApp.primario : ColoresApp.superficie,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (puntoClave != null && !activo) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: puntoClave,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    '$etiqueta ($count)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: activo ? Colors.white : ColoresApp.sobreSuperficie,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Sección borradores (cuando filtro = borrador) ──
  Widget _construirSeccionBorradores() {
    if (_cantidadBorradores == 0) {
      return _construirEstadoVacio(mensaje: 'No tienes borradores guardados');
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RutasApp.nuevoReporte),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColoresApp.superficie,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0x66FEB877),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.cloud_off_outlined, color: Color(0xFF6A3B03), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1 reporte en borrador',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ColoresApp.sobreSuperficie,
                    ),
                  ),
                  Text(
                    'Guarda foto y coordenadas. Toca para continuar.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ColoresApp.sobreSuperficieVariante,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: ColoresApp.primario),
          ],
        ),
      ),
    );
  }

  // ── Estado vacío ──
  Widget _construirEstadoVacio({String? mensaje}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: ColoresApp.contorno.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            mensaje ?? 'No hay reportes en esta categoría',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ColoresApp.sobreSuperficieVariante,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Callout borradores pendientes ──
  Widget _construirCalloutBorradores() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RutasApp.nuevoReporte),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0x66FFDCC0), Color(0xFFF3F2FF)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEB877),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Icon(Icons.cloud_off_outlined, size: 18, color: Color(0xFF2D1600)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tienes $_cantidadBorradores reporte${_cantidadBorradores > 1 ? "s" : ""} en borrador',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF131A36),
                      ),
                    ),
                    Text(
                      'Guardan fotos y coordenadas sin\nconexión.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ColoresApp.sobreSuperficieVariante,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 13, color: ColoresApp.primarioOscuro),
          ],
        ),
      ),
    );
  }

  // ── CTA Reportar ──
  Widget _construirCtaReportar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.primario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.primario.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign_outlined, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    '¿Tienes una nueva incidencia?',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Radica un reporte ante la Alcaldía',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(RutasApp.nuevoReporte),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 15, color: ColoresApp.primarioOscuro),
                  const SizedBox(width: 4),
                  Text(
                    'Reportar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ColoresApp.primarioOscuro,
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
}

// ── KPI Card widget ──
class _KpiCard extends StatelessWidget {
  final String label;
  final int valor;
  final String unidad;
  final String subLabel;
  final Color fondoColor;
  final Color textoColor;
  final Color iconoFondo;
  final Color iconoColor;
  final IconData icono;

  const _KpiCard({
    required this.label,
    required this.valor,
    required this.unidad,
    required this.subLabel,
    required this.fondoColor,
    required this.textoColor,
    required this.iconoFondo,
    required this.iconoColor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fondoColor,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textoColor,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconoFondo,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Icon(icono, size: 13, color: iconoColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$valor',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textoColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unidad,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: textoColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
