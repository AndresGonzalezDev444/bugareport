/// Model representing a citizen-reported incident in BugaReport.
/// Maps directly to the `incidents` table in Supabase (PostgreSQL).
class Incident {
  final String id;
  final String? userId;
  final String category;
  final String severity;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final String status;
  final String? quadrant;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Incident({
    required this.id,
    this.userId,
    required this.category,
    required this.severity,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    required this.status,
    this.quadrant,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an Incident from a Supabase JSON row.
  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      category: json['category'] as String,
      severity: json['severity'] as String? ?? 'media',
      title: json['title'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      photoUrl: json['photo_url'] as String?,
      status: json['status'] as String? ?? 'pendiente',
      quadrant: json['quadrant'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this Incident to a JSON map for Supabase insertion.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category': category,
      'severity': severity,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photo_url': photoUrl,
      'status': status,
      'quadrant': quadrant,
      'address': address,
    };
  }

  /// Human-readable category label.
  String get categoryLabel {
    switch (category) {
      case 'hueco_via':
        return 'Hueco / Vía';
      case 'servicios_publicos':
        return 'Serv. Públicos';
      case 'comunitario':
        return 'Comunitario';
      case 'aseo_parques':
        return 'Aseo y Parques';
      default:
        return category;
    }
  }

  /// Human-readable severity label.
  String get severityLabel {
    switch (severity) {
      case 'critico':
        return 'Crítico';
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Media';
      case 'baja':
        return 'Baja';
      default:
        return severity;
    }
  }

  /// Time elapsed since the incident was reported.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
