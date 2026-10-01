import 'package:latlong2/latlong.dart';

/// Constantes globales de la aplicación BugaReport.
class ConstantesApp {
  ConstantesApp._();

  // ── Guadalajara de Buga, Valle del Cauca ──
  static const double bugaLatitud = 3.9006;
  static const double bugaLongitud = -76.2978;
  static final LatLng bugaCentro = LatLng(bugaLatitud, bugaLongitud);
  static const double zoomMapaInicial = 14.5;

  // ── URL de teselas OpenStreetMap ──
  static const String urlTeselaOsm =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // ── Categorías de incidentes ──
  static const Map<String, InfoCategoria> categorias = {
    'hueco_via': InfoCategoria(
      clave: 'hueco_via',
      etiqueta: 'Hueco / Vía',
      subtitulo: 'Malla vial',
      icono: 0xe3ab,
    ),
    'servicios_publicos': InfoCategoria(
      clave: 'servicios_publicos',
      etiqueta: 'Serv. Públicos',
      subtitulo: 'Agua / Luz',
      icono: 0xe32a,
    ),
    'comunitario': InfoCategoria(
      clave: 'comunitario',
      etiqueta: 'Comunitario',
      subtitulo: 'Convivencia',
      icono: 0xe7ef,
    ),
    'aseo_parques': InfoCategoria(
      clave: 'aseo_parques',
      etiqueta: 'Aseo y Parques',
      subtitulo: 'Espacio público',
      icono: 0xe1e0,
    ),
  };

  // ── Números de emergencia ──
  static const String lineaEmergencia = '123';
  static const String bomberos = '119';
  static const String cruzRoja = '132';
  static const String defensaCivil = '144';
}

/// Metadatos de cada categoría de incidente.
class InfoCategoria {
  final String clave;
  final String etiqueta;
  final String subtitulo;
  final int icono;

  const InfoCategoria({
    required this.clave,
    required this.etiqueta,
    required this.subtitulo,
    required this.icono,
  });
}
