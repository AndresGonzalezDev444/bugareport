/// Modelo de un incidente ciudadano en BugaReport.
/// Mapea directamente la tabla `incidents` de Supabase (PostgreSQL).
class Incidente {
  final String id;
  final String? idUsuario;
  final String categoria;
  final String severidad;
  final String titulo;
  final String? descripcion;
  final double latitud;
  final double longitud;
  final String? urlFoto;
  final String estado;
  final String? cuadrante;
  final String? direccion;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const Incidente({
    required this.id,
    this.idUsuario,
    required this.categoria,
    required this.severidad,
    required this.titulo,
    this.descripcion,
    required this.latitud,
    required this.longitud,
    this.urlFoto,
    required this.estado,
    this.cuadrante,
    this.direccion,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  /// Crea un Incidente a partir de una fila JSON de Supabase.
  factory Incidente.desdeJson(Map<String, dynamic> json) {
    return Incidente(
      id: json['id'] as String,
      idUsuario: json['user_id'] as String?,
      categoria: json['category'] as String,
      severidad: json['severity'] as String? ?? 'media',
      titulo: json['title'] as String,
      descripcion: json['description'] as String?,
      latitud: (json['latitude'] as num).toDouble(),
      longitud: (json['longitude'] as num).toDouble(),
      urlFoto: json['photo_url'] as String?,
      estado: json['status'] as String? ?? 'pendiente',
      cuadrante: json['quadrant'] as String?,
      direccion: json['address'] as String?,
      creadoEn: DateTime.parse(json['created_at'] as String),
      actualizadoEn: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convierte el Incidente a JSON para insertar en Supabase.
  Map<String, dynamic> aJson() {
    return {
      'user_id': idUsuario,
      'category': categoria,
      'severity': severidad,
      'title': titulo,
      'description': descripcion,
      'latitude': latitud,
      'longitude': longitud,
      'photo_url': urlFoto,
      'status': estado,
      'quadrant': cuadrante,
      'address': direccion,
    };
  }

  /// Etiqueta legible de la categoría.
  String get etiquetaCategoria {
    switch (categoria) {
      case 'hueco_via':
        return 'Hueco / Vía';
      case 'servicios_publicos':
        return 'Serv. Públicos';
      case 'comunitario':
        return 'Comunitario';
      case 'aseo_parques':
        return 'Aseo y Parques';
      default:
        return categoria;
    }
  }

  /// Etiqueta legible de la severidad.
  String get etiquetaSeveridad {
    switch (severidad) {
      case 'critico':
        return 'Crítico';
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Media';
      case 'baja':
        return 'Baja';
      default:
        return severidad;
    }
  }

  /// Tiempo transcurrido desde que se reportó el incidente.
  String get tiempoTranscurrido {
    final diferencia = DateTime.now().difference(creadoEn);
    if (diferencia.inMinutes < 1) return 'Ahora';
    if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inHours < 24) return 'Hace ${diferencia.inHours}h';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays}d';
    return '${creadoEn.day}/${creadoEn.month}/${creadoEn.year}';
  }
}
