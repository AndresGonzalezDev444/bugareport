import 'package:latlong2/latlong.dart';

/// App-wide constants for BugaReport.
class AppConstants {
  AppConstants._();

  // ── Guadalajara de Buga, Valle del Cauca ──
  static const double bugaLatitude = 3.9006;
  static const double bugaLongitude = -76.2978;
  static final LatLng bugaCenter = LatLng(bugaLatitude, bugaLongitude);
  static const double defaultMapZoom = 14.5;

  // ── OpenStreetMap Tile URL ──
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // ── Incident Categories ──
  static const Map<String, CategoryInfo> categories = {
    'hueco_via': CategoryInfo(
      key: 'hueco_via',
      label: 'Hueco / Vía',
      subtitle: 'Malla vial',
      icon: 0xe3ab, // Icons.warning_rounded
    ),
    'servicios_publicos': CategoryInfo(
      key: 'servicios_publicos',
      label: 'Serv. Públicos',
      subtitle: 'Agua / Luz',
      icon: 0xe32a, // Icons.water_drop
    ),
    'comunitario': CategoryInfo(
      key: 'comunitario',
      label: 'Comunitario',
      subtitle: 'Convivencia',
      icon: 0xe7ef, // Icons.groups
    ),
    'aseo_parques': CategoryInfo(
      key: 'aseo_parques',
      label: 'Aseo y Parques',
      subtitle: 'Espacio público',
      icon: 0xe1e0, // Icons.park
    ),
  };

  // ── Emergency Numbers ──
  static const String emergencyLine = '123';
  static const String bomberos = '119';
  static const String cruzRoja = '132';
  static const String defensaCivil = '144';
}

/// Metadata for each incident category.
class CategoryInfo {
  final String key;
  final String label;
  final String subtitle;
  final int icon;

  const CategoryInfo({
    required this.key,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}
