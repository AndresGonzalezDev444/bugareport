import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/config/constantes_app.dart';
import 'package:bugareport/modelos/incidente.dart';
import 'package:bugareport/servicios/servicio_incidentes.dart';
import 'package:bugareport/servicios/servicio_ubicacion.dart';
import 'package:bugareport/widgets/compartidos/pin_mapa_incidente.dart';

/// Pantalla de mapa completo e interactivo.
/// Muestra la ubicación real del usuario + todos los incidentes desde Supabase.
/// Funciona como Waze: los reportes de otros ciudadanos aparecen en tiempo real.
class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _EstadoPantallaMapa();
}

class _EstadoPantallaMapa extends State<PantallaMapa> {
  final _controladorMapa = MapController();
  final _servicioIncidentes = ServicioIncidentes();
  final _servicioUbicacion = ServicioUbicacion.instancia;

  LatLng? _ubicacionUsuario;
  bool _cargandoUbicacion = true;
  String? _categoriaFiltro; // null = todas las categorías
  Incidente? _incidenteSeleccionado;

  // Categorías para el filtro
  static const _filtros = [
    (clave: null, etiqueta: 'Todos', icono: Icons.map_outlined),
    (clave: 'hueco_via', etiqueta: 'Hueco/Vía', icono: Icons.warning_rounded),
    (clave: 'servicios_publicos', etiqueta: 'Servicios', icono: Icons.water_drop),
    (clave: 'comunitario', etiqueta: 'Comunitario', icono: Icons.groups),
    (clave: 'aseo_parques', etiqueta: 'Aseo/Parques', icono: Icons.park),
  ];

  @override
  void initState() {
    super.initState();
    _inicializarUbicacion();
  }

  Future<void> _inicializarUbicacion() async {
    final posicion = await _servicioUbicacion.obtenerPosicionActual();
    if (!mounted) return;
    setState(() {
      _ubicacionUsuario = posicion;
      _cargandoUbicacion = false;
    });
    // Centrar el mapa en la ubicación del usuario
    _controladorMapa.move(posicion, 15.0);
  }

  void _centrarEnMiUbicacion() async {
    final posicion = await _servicioUbicacion.obtenerPosicionActual();
    if (!mounted) return;
    setState(() => _ubicacionUsuario = posicion);
    _controladorMapa.move(posicion, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Mapa principal ──
          _construirMapa(),

          // ── AppBar flotante ──
          _construirAppBarFlotante(context),

          // ── Chips de filtro por categoría ──
          _construirFiltros(),

          // ── Indicador de carga ──
          if (_cargandoUbicacion) _construirIndicadorCarga(),

          // ── Panel de detalle del incidente seleccionado ──
          if (_incidenteSeleccionado != null)
            _construirPanelDetalle(_incidenteSeleccionado!),

          // ── FAB: Centrar en mi ubicación ──
          _construirFabUbicacion(),
        ],
      ),
    );
  }

  // ── Mapa con capas ──
  Widget _construirMapa() {
    return StreamBuilder<List<Incidente>>(
      stream: _servicioIncidentes.transmitirIncidentesActivos(),
      builder: (context, instantanea) {
        final todosIncidentes = instantanea.data ?? [];
        final incidentesFiltrados = _categoriaFiltro == null
            ? todosIncidentes
            : todosIncidentes
                .where((i) => i.categoria == _categoriaFiltro)
                .toList();

        return FlutterMap(
          mapController: _controladorMapa,
          options: MapOptions(
            initialCenter: ConstantesApp.bugaCentro,
            initialZoom: ConstantesApp.zoomMapaInicial,
            minZoom: 10,
            maxZoom: 19,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all, // Mapa completamente interactivo
            ),
            onTap: (tapPos, latLng) {
              // Cerrar panel de detalle al tocar el mapa
              setState(() => _incidenteSeleccionado = null);
            },
          ),
          children: [
            // Capa de teselas OpenStreetMap
            TileLayer(
              urlTemplate: ConstantesApp.urlTeselaOsm,
              userAgentPackageName: 'com.bugareport.app',
            ),

            // Marcadores de incidentes ciudadanos desde Supabase
            MarkerLayer(
              markers: incidentesFiltrados.map((incidente) {
                return Marker(
                  point: LatLng(incidente.latitud, incidente.longitud),
                  width: 36,
                  height: 44,
                  child: PinMapaIncidente(
                    incidente: incidente,
                    alTocar: () {
                      setState(() => _incidenteSeleccionado = incidente);
                    },
                  ),
                );
              }).toList(),
            ),

            // Marcador de ubicación del usuario (punto azul)
            if (_ubicacionUsuario != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _ubicacionUsuario!,
                    width: 50,
                    height: 50,
                    child: _PuntoUbicacionUsuario(),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  // ── AppBar flotante sobre el mapa ──
  Widget _construirAppBarFlotante(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Botón regresar
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: ColoresApp.primario,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Título
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: ColoresApp.primario,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Mapa de Incidentes — Buga',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ColoresApp.sobreSuperficie,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Chips de filtro por categoría ──
  Widget _construirFiltros() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _filtros.length,
          separatorBuilder: (context, indice) => const SizedBox(width: 8),
          itemBuilder: (context, indice) {
            final filtro = _filtros[indice];
            final estaActivo = _categoriaFiltro == filtro.clave;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _categoriaFiltro = filtro.clave;
                  _incidenteSeleccionado = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: estaActivo
                      ? ColoresApp.primario
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filtro.icono,
                      size: 14,
                      color: estaActivo
                          ? Colors.white
                          : ColoresApp.sobreSuperficieVariante,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      filtro.etiqueta,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: estaActivo
                            ? Colors.white
                            : ColoresApp.sobreSuperficie,
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

  // ── Indicador de carga mientras se obtiene la ubicación ──
  Widget _construirIndicadorCarga() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColoresApp.primario,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Obteniendo tu ubicación...',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColoresApp.sobreSuperficie,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Panel de detalle al tocar un incidente ──
  Widget _construirPanelDetalle(Incidente incidente) {
    final color = ColoresApp.colorPorCategoria(incidente.categoria);
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {}, // Evita que cierre al tocar el panel
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColoresApp.superficie,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado: categoría + tiempo + cerrar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconoPorCategoria(incidente.categoria),
                          size: 12,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          incidente.etiquetaCategoria,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    incidente.tiempoTranscurrido,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ColoresApp.contorno,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _incidenteSeleccionado = null),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: ColoresApp.contorno,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Título del incidente
              Text(
                incidente.titulo,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.sobreSuperficie,
                ),
              ),

              // Descripción (si existe)
              if (incidente.descripcion != null &&
                  incidente.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  incidente.descripcion!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ColoresApp.sobreSuperficieVariante,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 10),

              // Fila inferior: dirección + estado
              Row(
                children: [
                  if (incidente.direccion != null) ...[
                    const Icon(
                      Icons.place,
                      size: 14,
                      color: ColoresApp.contorno,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        incidente.direccion!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: ColoresApp.contorno,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Chip de estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _colorEstado(incidente.estado)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _etiquetaEstado(incidente.estado),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _colorEstado(incidente.estado),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── FAB para centrar en la ubicación del usuario ──
  Widget _construirFabUbicacion() {
    return Positioned(
      right: 16,
      bottom: _incidenteSeleccionado != null ? 200 : 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón centrar en mi ubicación
          FloatingActionButton.small(
            heroTag: 'fab_ubicacion',
            backgroundColor: Colors.white,
            onPressed: _centrarEnMiUbicacion,
            child: const Icon(
              Icons.my_location,
              color: ColoresApp.primario,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          // Zoom in
          FloatingActionButton.small(
            heroTag: 'fab_zoom_in',
            backgroundColor: Colors.white,
            onPressed: () {
              final zoom = _controladorMapa.camera.zoom;
              _controladorMapa.move(
                _controladorMapa.camera.center,
                zoom + 1,
              );
            },
            child: const Icon(
              Icons.add,
              color: ColoresApp.sobreSuperficie,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          // Zoom out
          FloatingActionButton.small(
            heroTag: 'fab_zoom_out',
            backgroundColor: Colors.white,
            onPressed: () {
              final zoom = _controladorMapa.camera.zoom;
              _controladorMapa.move(
                _controladorMapa.camera.center,
                zoom - 1,
              );
            },
            child: const Icon(
              Icons.remove,
              color: ColoresApp.sobreSuperficie,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

  IconData _iconoPorCategoria(String categoria) {
    switch (categoria) {
      case 'hueco_via':
        return Icons.warning_rounded;
      case 'servicios_publicos':
        return Icons.water_drop;
      case 'comunitario':
        return Icons.groups;
      case 'aseo_parques':
        return Icons.park;
      default:
        return Icons.place;
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'resuelto':
        return ColoresApp.terciario;
      case 'en_proceso':
        return ColoresApp.secundario;
      default:
        return ColoresApp.primario;
    }
  }

  String _etiquetaEstado(String estado) {
    switch (estado) {
      case 'resuelto':
        return '✓ Resuelto';
      case 'en_proceso':
        return '⏳ En proceso';
      default:
        return '⚠ Pendiente';
    }
  }
}

/// Punto azul animado que representa la ubicación real del usuario.
class _PuntoUbicacionUsuario extends StatefulWidget {
  @override
  State<_PuntoUbicacionUsuario> createState() =>
      _EstadoPuntoUbicacionUsuario();
}

class _EstadoPuntoUbicacionUsuario
    extends State<_PuntoUbicacionUsuario>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controladorAnimacion;
  late final Animation<double> _animacionPulso;

  @override
  void initState() {
    super.initState();
    _controladorAnimacion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animacionPulso = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controladorAnimacion,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controladorAnimacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Aro exterior pulsante (efecto de radar)
        AnimatedBuilder(
          animation: _animacionPulso,
          builder: (context, child) {
            return Container(
              width: 50 * _animacionPulso.value,
              height: 50 * _animacionPulso.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2196F3)
                    .withValues(alpha: 1 - _animacionPulso.value),
              ),
            );
          },
        ),
        // Círculo blanco exterior
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        // Punto azul interior
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF2196F3),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
