import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bugareport/modelos/usuario.dart';

/// Servicio central de autenticación para BugaReport.
///
/// Usa [Supabase Auth] como backend (gratuito, encriptación automática bcrypt,
/// tokens JWT, envío de correos de recuperación incluido sin costo).
///
/// Los tokens de sesión se persisten en [FlutterSecureStorage] (encriptado
/// con Keychain en iOS y EncryptedSharedPreferences en Android).
class ServicioAutenticacion {
  ServicioAutenticacion._();
  static final ServicioAutenticacion instancia = ServicioAutenticacion._();

  final _supabase = Supabase.instance.client;

  static const _almacenSeguro = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Claves de almacenamiento seguro
  static const _claveAccessToken = 'br_access_token';
  static const _claveRefreshToken = 'br_refresh_token';
  static const _claveUserId = 'br_user_id';

  // ═══════════════════════════════════════════════════════
  // REGISTRO
  // ═══════════════════════════════════════════════════════

  /// Registra un nuevo ciudadano en BugaReport.
  ///
  /// 1. Crea la cuenta en Supabase Auth (email + contraseña, bcrypt automático).
  /// 2. Inserta el perfil extendido en [perfiles_ciudadanos].
  /// 3. Persiste la sesión localmente.
  ///
  /// Lanza [ExcepcionAutenticacion] con mensajes amigables si algo falla.
  Future<Usuario> registrar({
    required String email,
    required String contrasena,
    required String nombreCompleto,
    required String tipoDocumento,
    required String numeroDocumento,
    String? celular,
    String? comuna,
    double? latitud,
    double? longitud,
  }) async {
    try {
      // 1. Crear cuenta en Supabase Auth
      final respuesta = await _supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: contrasena,
        data: {'nombre_completo': nombreCompleto},
      );

      final usuario = respuesta.user;
      if (usuario == null) {
        throw const ExcepcionAutenticacion(
          ErrorAutenticacion.desconocido,
          'No se recibió usuario de Supabase',
        );
      }

      // 2. Insertar perfil extendido en perfiles_ciudadanos
      final datosPeril = <String, dynamic>{
        'id': usuario.id,
        'nombre_completo': nombreCompleto.trim(),
        'tipo_documento': tipoDocumento,
        'numero_documento': numeroDocumento.trim(),
        'email': email.trim().toLowerCase(),
        if (celular != null && celular.isNotEmpty) 'celular': celular.trim(),
        if (comuna != null && comuna.isNotEmpty) 'comuna': comuna.trim(),
        'latitud_residencia': ?latitud,
        'longitud_residencia': ?longitud,
        'rol': 'ciudadano',
      };

      await _supabase.from('perfiles_ciudadanos').insert(datosPeril);

      // 3. Persistir sesión si está disponible
      if (respuesta.session != null) {
        await _persistirSesion(respuesta.session!);
      }

      return Usuario(
        id: usuario.id,
        nombreCompleto: nombreCompleto.trim(),
        tipoDocumento: tipoDocumento,
        numeroDocumento: numeroDocumento.trim(),
        celular: celular,
        email: email.trim().toLowerCase(),
        comuna: comuna,
        latitudResidencia: latitud,
        longitudResidencia: longitud,
        creadoEn: DateTime.now(),
      );
    } on ExcepcionAutenticacion {
      rethrow;
    } on AuthException catch (e) {
      throw _mapearErrorAuth(e);
    } catch (e) {
      final mensaje = e.toString().toLowerCase();
      if (mensaje.contains('duplicate') || mensaje.contains('unique')) {
        if (mensaje.contains('email')) {
          throw const ExcepcionAutenticacion(
            ErrorAutenticacion.emailDuplicado,
            'Email duplicado',
          );
        }
        throw const ExcepcionAutenticacion(
          ErrorAutenticacion.documentoDuplicado,
          'Documento duplicado',
        );
      }
      if (mensaje.contains('network') || mensaje.contains('connection')) {
        throw const ExcepcionAutenticacion(
          ErrorAutenticacion.sinConexion,
          'Sin conexión',
        );
      }
      throw ExcepcionAutenticacion(ErrorAutenticacion.desconocido, '$e');
    }
  }

  // ═══════════════════════════════════════════════════════
  // INICIO DE SESIÓN
  // ═══════════════════════════════════════════════════════

  /// Inicia sesión con email y contraseña.
  /// Persiste el token en almacenamiento seguro.
  Future<Usuario> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    try {
      final respuesta = await _supabase.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: contrasena,
      );

      final sesion = respuesta.session;
      final supaUser = respuesta.user;

      if (sesion == null || supaUser == null) {
        throw const ExcepcionAutenticacion(
          ErrorAutenticacion.credencialesInvalidas,
          'Credenciales inválidas',
        );
      }

      // Persistir tokens en almacenamiento seguro
      await _persistirSesion(sesion);

      // Obtener perfil extendido
      return await obtenerPerfilActual() ??
          Usuario(
            id: supaUser.id,
            nombreCompleto: supaUser.userMetadata?['nombre_completo'] ?? '',
            tipoDocumento: 'CC',
            numeroDocumento: '',
            email: supaUser.email ?? email,
            creadoEn: DateTime.now(),
          );
    } on ExcepcionAutenticacion {
      rethrow;
    } on AuthException catch (e) {
      throw _mapearErrorAuth(e);
    } catch (e) {
      final mensaje = e.toString().toLowerCase();
      if (mensaje.contains('network') || mensaje.contains('connection')) {
        throw const ExcepcionAutenticacion(
          ErrorAutenticacion.sinConexion,
          'Sin conexión',
        );
      }
      throw ExcepcionAutenticacion(ErrorAutenticacion.desconocido, '$e');
    }
  }

  // ═══════════════════════════════════════════════════════
  // GESTIÓN DE SESIÓN
  // ═══════════════════════════════════════════════════════

  /// Verifica si existe una sesión activa y válida.
  Future<bool> haySesionActiva() async {
    // Supabase verifica automáticamente el token y lo renueva si expiró
    final sesion = _supabase.auth.currentSession;
    if (sesion == null) return false;
    if (!sesion.isExpired) return true;

    // Intentar renovar con el refresh token
    try {
      final refrescada = await _supabase.auth.refreshSession();
      if (refrescada.session != null) {
        await _persistirSesion(refrescada.session!);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Obtiene el perfil completo del usuario actualmente autenticado.
  Future<Usuario?> obtenerPerfilActual() async {
    final supaUser = _supabase.auth.currentUser;
    if (supaUser == null) return null;

    try {
      final datos =
          await _supabase
              .from('perfiles_ciudadanos')
              .select()
              .eq('id', supaUser.id)
              .maybeSingle();

      if (datos == null) return null;
      return Usuario.desdeJson({...datos, 'email': supaUser.email ?? ''});
    } catch (_) {
      return null;
    }
  }

  /// Cierra la sesión del ciudadano y limpia el almacenamiento seguro.
  Future<void> cerrarSesion() async {
    await Future.wait([
      _supabase.auth.signOut(),
      _limpiarSesionLocal(),
    ]);
  }

  // ═══════════════════════════════════════════════════════
  // RECUPERACIÓN DE CONTRASEÑA (HU3)
  // ═══════════════════════════════════════════════════════

  /// Envía un correo de recuperación de contraseña.
  ///
  /// Supabase genera el token temporal y envía el correo automáticamente
  /// con su SMTP gratuito (50.000 emails/mes incluidos).
  /// El link tiene expiración configurable desde el Dashboard de Supabase.
  Future<void> enviarCorreoRecuperacion(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: 'bugareport://nueva-contrasena',
      );
    } on AuthException catch (e) {
      throw _mapearErrorAuth(e);
    } catch (e) {
      final mensaje = e.toString().toLowerCase();
      if (mensaje.contains('network') || mensaje.contains('connection')) {
        throw const ExcepcionAutenticacion(
          ErrorAutenticacion.sinConexion,
          'Sin conexión',
        );
      }
      throw ExcepcionAutenticacion(ErrorAutenticacion.desconocido, '$e');
    }
  }

  /// Actualiza la contraseña del usuario autenticado (usado tras el deep link).
  Future<void> actualizarContrasena(String nuevaContrasena) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: nuevaContrasena),
      );
    } on AuthException catch (e) {
      throw _mapearErrorAuth(e);
    } catch (e) {
      throw ExcepcionAutenticacion(ErrorAutenticacion.desconocido, '$e');
    }
  }

  // ═══════════════════════════════════════════════════════
  // PRIVADO — Persistencia de sesión
  // ═══════════════════════════════════════════════════════

  Future<void> _persistirSesion(Session sesion) async {
    await Future.wait([
      _almacenSeguro.write(key: _claveAccessToken, value: sesion.accessToken),
      _almacenSeguro.write(
        key: _claveRefreshToken,
        value: sesion.refreshToken ?? '',
      ),
      _almacenSeguro.write(
        key: _claveUserId,
        value: sesion.user.id,
      ),
    ]);
  }

  Future<void> _limpiarSesionLocal() async {
    await Future.wait([
      _almacenSeguro.delete(key: _claveAccessToken),
      _almacenSeguro.delete(key: _claveRefreshToken),
      _almacenSeguro.delete(key: _claveUserId),
    ]);
  }

  // ═══════════════════════════════════════════════════════
  // PRIVADO — Mapeo de errores Supabase → ExcepcionAutenticacion
  // ═══════════════════════════════════════════════════════

  ExcepcionAutenticacion _mapearErrorAuth(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return const ExcepcionAutenticacion(
        ErrorAutenticacion.credencialesInvalidas,
        'Credenciales inválidas',
      );
    }
    if (msg.contains('user already registered') ||
        msg.contains('email already')) {
      return const ExcepcionAutenticacion(
        ErrorAutenticacion.emailDuplicado,
        'Email ya registrado',
      );
    }
    if (msg.contains('user not found')) {
      return const ExcepcionAutenticacion(
        ErrorAutenticacion.emailNoEncontrado,
        'Usuario no encontrado',
      );
    }
    if (msg.contains('password') && msg.contains('weak')) {
      return const ExcepcionAutenticacion(
        ErrorAutenticacion.contrasenaDebil,
        'Contraseña débil',
      );
    }
    if (msg.contains('token') && msg.contains('expir')) {
      return const ExcepcionAutenticacion(
        ErrorAutenticacion.tokenExpirado,
        'Token expirado',
      );
    }
    return ExcepcionAutenticacion(ErrorAutenticacion.desconocido, e.message);
  }
}
