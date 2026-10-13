
/// Modelo del perfil de un ciudadano registrado en BugaReport.
/// Corresponde a la tabla [perfiles_ciudadanos] en Supabase.
class Usuario {
  final String id;
  final String nombreCompleto;
  final String tipoDocumento;
  final String numeroDocumento;
  final String? celular;
  final String email;
  final String? comuna;
  final double? latitudResidencia;
  final double? longitudResidencia;
  final String rol;
  final DateTime creadoEn;

  const Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.tipoDocumento,
    required this.numeroDocumento,
    this.celular,
    required this.email,
    this.comuna,
    this.latitudResidencia,
    this.longitudResidencia,
    this.rol = 'ciudadano',
    required this.creadoEn,
  });

  // ── Deserialización ──

  factory Usuario.desdeJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      tipoDocumento: json['tipo_documento'] as String? ?? 'CC',
      numeroDocumento: json['numero_documento'] as String,
      celular: json['celular'] as String?,
      email: json['email'] as String? ?? '',
      comuna: json['comuna'] as String?,
      latitudResidencia: (json['latitud_residencia'] as num?)?.toDouble(),
      longitudResidencia: (json['longitud_residencia'] as num?)?.toDouble(),
      rol: json['rol'] as String? ?? 'ciudadano',
      creadoEn: DateTime.parse(
        json['creado_en'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // ── Serialización ──

  Map<String, dynamic> aJson() => {
    'id': id,
    'nombre_completo': nombreCompleto,
    'tipo_documento': tipoDocumento,
    'numero_documento': numeroDocumento,
    if (celular != null) 'celular': celular,
    'email': email,
    if (comuna != null) 'comuna': comuna,
    if (latitudResidencia != null) 'latitud_residencia': latitudResidencia,
    if (longitudResidencia != null) 'longitud_residencia': longitudResidencia,
    'rol': rol,
  };

  // ── Helpers ──

  bool get esAdmin => rol == 'admin';

  /// Nombre corto para mostrar en la app (primer nombre).
  String get primerNombre {
    final partes = nombreCompleto.trim().split(' ');
    return partes.isNotEmpty ? partes.first : nombreCompleto;
  }

  @override
  String toString() => 'Usuario($email, rol=$rol)';
}

/// Tipos de error de autenticación para mostrar mensajes apropiados.
enum ErrorAutenticacion {
  emailDuplicado,
  documentoDuplicado,
  credencialesInvalidas,
  emailNoEncontrado,
  contrasenaDebil,
  sinConexion,
  tokenExpirado,
  desconocido,
}

/// Excepción tipada para errores del servicio de autenticación.
class ExcepcionAutenticacion implements Exception {
  final ErrorAutenticacion tipo;
  final String mensaje;

  const ExcepcionAutenticacion(this.tipo, this.mensaje);

  /// Mensaje amigable en español para mostrar al ciudadano.
  String get mensajeAmigable {
    switch (tipo) {
      case ErrorAutenticacion.emailDuplicado:
        return 'Este correo electrónico ya está registrado en BugaReport.';
      case ErrorAutenticacion.documentoDuplicado:
        return 'Este número de documento ya tiene una cuenta registrada.';
      case ErrorAutenticacion.credencialesInvalidas:
        return 'Correo o contraseña incorrectos. Por favor verifica tus datos.';
      case ErrorAutenticacion.emailNoEncontrado:
        return 'No encontramos una cuenta con ese correo electrónico.';
      case ErrorAutenticacion.contrasenaDebil:
        return 'La contraseña debe tener al menos 8 caracteres, una mayúscula, un número y un símbolo.';
      case ErrorAutenticacion.sinConexion:
        return 'Sin conexión a internet. Verifica tu red e intenta de nuevo.';
      case ErrorAutenticacion.tokenExpirado:
        return 'Tu sesión ha expirado. Por favor inicia sesión de nuevo.';
      case ErrorAutenticacion.desconocido:
        return 'Ocurrió un error inesperado. Intenta de nuevo más tarde.';
    }
  }

  @override
  String toString() => 'ExcepcionAutenticacion($tipo): $mensaje';
}
