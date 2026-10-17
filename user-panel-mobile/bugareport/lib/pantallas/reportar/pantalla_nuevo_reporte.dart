import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/modelos/incidente.dart';
import 'package:bugareport/servicios/servicio_incidentes.dart';
import 'package:bugareport/servicios/servicio_ubicacion.dart';
import 'package:bugareport/servicios/servicio_almacenamiento.dart';
import 'package:bugareport/servicios/servicio_logger.dart';
import 'package:bugareport/servicios/servicio_conectividad.dart';
import 'package:bugareport/servicios/servicio_borrador.dart';
import 'package:bugareport/servicios/servicio_exif.dart';
import 'widgets/selector_foto.dart';


/// Pantalla para crear un nuevo reporte ciudadano con evidencia fotográfica.
///
/// Flujo completo:
/// 1. Selección de foto (cámara o galería) — obligatoria
/// 2. Título, categoría, severidad, descripción
/// 3. Ubicación GPS automática (ajustable)
/// 4. Validación frontend antes de enviar
/// 5. Si hay red: sube foto → inserta incidente → diálogo éxito
/// 6. Si no hay red: guarda borrador local (SharedPreferences)
class PantallaNuevoReporte extends StatefulWidget {
  /// Categoría pre-seleccionada (HU8: accesos rápidos desde inicio).
  final String? categoriaInicial;

  const PantallaNuevoReporte({super.key, this.categoriaInicial});

  @override
  State<PantallaNuevoReporte> createState() => _EstadoPantallaNuevoReporte();
}

class _EstadoPantallaNuevoReporte extends State<PantallaNuevoReporte> {
  final _claveFormulario = GlobalKey<FormState>();
  final _ctrlTitulo = TextEditingController();
  final _ctrlDescripcion = TextEditingController();

  // ── Estado del formulario ──
  File? _foto;
  late String _categoriaSeleccionada;
  String _severidadSeleccionada = 'media';
  double? _latitud;
  double? _longitud;

  // ── Estado de la operación ──
  bool _cargandoUbicacion = false;
  bool _enviando = false;
  String? _errorFoto;
  bool _tieneBorrador = false; // HU9: hay borrador guardado

  // ── Servicios ──
  final _svcIncidentes = ServicioIncidentes();
  final _svcBorrador   = ServicioBorrador.instancia;

  @override
  void initState() {
    super.initState();
    // HU8: pre-seleccionar categoría si viene de acceso rápido
    _categoriaSeleccionada = widget.categoriaInicial ?? 'hueco_via';
    _obtenerUbicacion();
    _verificarBorrador(); // HU9: ofrecer recuperar borrador
    _configurarAutoGuardado(); // HU9: auto-guardar al escribir
  }

  @override
  void dispose() {
    _ctrlTitulo.dispose();
    _ctrlDescripcion.dispose();
    super.dispose();
  }

  // ── HU9: Borrador ──

  /// Verifica si hay un borrador y lo ofrece al usuario.
  Future<void> _verificarBorrador() async {
    final hay = await _svcBorrador.tieneBorrador();
    if (!hay || !mounted) return;

    setState(() => _tieneBorrador = true);

    // Mostrar SnackBar con acción
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tienes un borrador guardado. ¿Deseas continuarlo?',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: ColoresApp.primario,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Recuperar',
          textColor: Colors.white,
          onPressed: _recuperarBorrador,
        ),
      ),
    );
  }

  /// Carga los datos del borrador en el formulario.
  Future<void> _recuperarBorrador() async {
    final datos = await _svcBorrador.cargarBorrador();
    if (datos == null || !mounted) return;

    setState(() {
      _ctrlTitulo.text      = datos['titulo']      ?? '';
      _ctrlDescripcion.text = datos['descripcion'] ?? '';
      _categoriaSeleccionada = datos['categoria']  ?? 'hueco_via';
      _severidadSeleccionada = datos['severidad']  ?? 'media';

      // Recuperar foto si la ruta aún existe
      final ruta = datos['rutaFoto'];
      if (ruta != null && File(ruta).existsSync()) {
        _foto = File(ruta);
      }

      // Recuperar coordenadas
      final lat = double.tryParse(datos['latitud'] ?? '');
      final lon = double.tryParse(datos['longitud'] ?? '');
      if (lat != null && lon != null) {
        _latitud  = lat;
        _longitud = lon;
      }

      _tieneBorrador = false;
    });

    _mostrarSnackBar('Borrador recuperado.', esError: false);
  }

  /// Descarta el borrador con confirmación.
  Future<void> _descartarBorrador() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Descartar borrador',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
        content: Text(
          '¿Deseas eliminar el borrador guardado? Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Descartar',
                style: TextStyle(color: ColoresApp.error)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _svcBorrador.descartarBorrador();
      if (mounted) setState(() => _tieneBorrador = false);
      if (mounted) _mostrarSnackBar('Borrador descartado.', esError: false);
    }
  }

  /// Configura listeners de auto-guardado en los controladores de texto.
  void _configurarAutoGuardado() {
    _ctrlTitulo.addListener(_guardarBorradorSiHayCambios);
    _ctrlDescripcion.addListener(_guardarBorradorSiHayCambios);
  }

  void _guardarBorradorSiHayCambios() {
    // Solo guardar si hay contenido significativo
    if (_ctrlTitulo.text.trim().length < 3) return;
    _svcBorrador.guardarBorrador(
      titulo:      _ctrlTitulo.text,
      descripcion: _ctrlDescripcion.text,
      categoria:   _categoriaSeleccionada,
      severidad:   _severidadSeleccionada,
      rutaFoto:    _foto?.path,
      latitud:     _latitud,
      longitud:    _longitud,
    );
  }

  // ── Obtener ubicación GPS ──
  Future<void> _obtenerUbicacion() async {
    setState(() => _cargandoUbicacion = true);
    try {
      final posicion =
          await ServicioUbicacion.instancia.obtenerPosicionActual();
      if (mounted) {
        setState(() {
          _latitud = posicion.latitude;
          _longitud = posicion.longitude;
        });
      }
    } catch (e) {
      ServicioLogger.advertencia(
        'No se pudo obtener ubicación GPS: $e',
        componente: 'NuevoReporte',
      );
    } finally {
      if (mounted) setState(() => _cargandoUbicacion = false);
    }
  }

  // ── Validación de foto ──
  bool _validarFoto() {
    if (_foto == null) {
      setState(() => _errorFoto = 'Adjunta una foto del incidente');
      return false;
    }
    if (!ServicioAlmacenamiento.instancia.validarPesoImagen(_foto!)) {
      setState(() => _errorFoto = 'La imagen supera los 5MB permitidos');
      return false;
    }
    setState(() => _errorFoto = null);
    return true;
  }

  // ── Sanitización de texto ──
  String _sanitizar(String texto) {
    return texto
        .replaceAll(RegExp(r'<[^>]*>'), '') // quitar HTML tags
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // quitar caracteres control
        .trim();
  }

  // ── Enviar reporte ──
  Future<void> _enviarReporte() async {
    final formularioValido =
        _claveFormulario.currentState?.validate() ?? false;
    final fotoValida = _validarFoto();
    if (!formularioValido || !fotoValida) return;

    if (_latitud == null || _longitud == null) {
      _mostrarSnackBar(
        'Activa tu GPS para ubicar el incidente en el mapa',
        esError: true,
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      // HU7: validar antigüedad de la foto por EXIF (antes de subir)
      try {
        await ServicioExif.validarAntiguedad(_foto!);
      } on ExcepcionFotoMuyAntigua catch (e) {
        if (mounted) _mostrarSnackBar(e.mensajeAmigable, esError: true);
        return;
      }

      // Verificar conectividad
      final hayRed = await ServicioConectividad.instancia.tieneConexion();
      if (!hayRed) {
        // HU9: guardar borrador y notificar
        await _svcBorrador.guardarBorrador(
          titulo:      _ctrlTitulo.text,
          descripcion: _ctrlDescripcion.text,
          categoria:   _categoriaSeleccionada,
          severidad:   _severidadSeleccionada,
          rutaFoto:    _foto?.path,
          latitud:     _latitud,
          longitud:    _longitud,
        );
        if (mounted) {
          setState(() => _tieneBorrador = true);
          _mostrarSnackBar(
            'Sin conexión. Tu reporte fue guardado como borrador.',
            esError: false,
          );
        }
        return;
      }

      // Obtener ID del usuario actual
      final supaUser = Supabase.instance.client.auth.currentUser;
      final idUsuario = supaUser?.id ?? 'anonimo';

      // 1. Subir foto a Supabase Storage
      String urlFoto;
      try {
        urlFoto = await ServicioAlmacenamiento.instancia.subirFoto(
          _foto!,
          idUsuario,
        );
      } on ExcepcionAlmacenamiento catch (e) {
        if (mounted) {
          _mostrarSnackBar(e.mensaje, esError: true);
        }
        return;
      }

      // 2. Crear el incidente en Supabase
      final titulo = _sanitizar(_ctrlTitulo.text);
      final descripcion = _sanitizar(_ctrlDescripcion.text);

      final nuevoIncidente = Incidente(
        id: '',
        idUsuario: supaUser?.id,
        categoria: _categoriaSeleccionada,
        severidad: _severidadSeleccionada,
        titulo: titulo,
        descripcion: descripcion,
        latitud: _latitud!,
        longitud: _longitud!,
        urlFoto: urlFoto,
        estado: 'pendiente',
        creadoEn: DateTime.now(),
        actualizadoEn: DateTime.now(),
      );

      // Insertar en Supabase
      await _svcIncidentes.crearIncidente(nuevoIncidente);

      // HU9: descartar borrador al enviar exitosamente
      await _svcBorrador.descartarBorrador();

      if (mounted) {
        _mostrarDialogoExito();
      }
    } catch (e, traza) {
      ServicioLogger.error(
        'Error al enviar reporte',
        excepcion: e,
        traza: traza,
        componente: 'NuevoReporte',
      );
      if (mounted) {
        _mostrarSnackBar(
          'Ocurrió un error al procesar su reporte, intente nuevamente',
          esError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarDialogoExito() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ColoresApp.terciarioClaro.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 40,
                color: ColoresApp.terciario,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Reporte enviado!',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ColoresApp.sobreSuperficie,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu reporte fue recibido por la Alcaldía de Guadalajara de Buga. '
              'Te notificaremos cuando sea atendido.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ColoresApp.sobreSuperficieVariante,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // cierra diálogo
                  Navigator.of(context).pop(); // vuelve al inicio
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primarioOscuro,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Ver en el mapa',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarSnackBar(String mensaje, {required bool esError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor:
            esError ? ColoresApp.error : ColoresApp.terciario,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: _construirAppBar(),
      body: Form(
        key: _claveFormulario,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Foto
              _seccion('Evidencia Fotográfica *', Icons.camera_alt_outlined),
              const SizedBox(height: 8),
              SelectorFoto(
                fotoSeleccionada: _foto,
                errorTexto: _errorFoto,
                alSeleccionar: (f) => setState(() {
                  _foto = f;
                  _errorFoto = null;
                }),
                alEliminar: () => setState(() => _foto = null),
              ),

              const SizedBox(height: 20),

              // 2. Info del incidente
              _seccion('Información del Incidente', Icons.info_outline),
              const SizedBox(height: 8),
              _construirCardInfo(),

              const SizedBox(height: 20),

              // 3. Ubicación
              _seccion('Ubicación del Incidente', Icons.location_on_outlined),
              const SizedBox(height: 8),
              _construirCardUbicacion(),

              const SizedBox(height: 24),

              // 4. Botón enviar
              _construirBotonEnviar(),

              const SizedBox(height: 12),

              // 5. Nota legal
              Text(
                'Tu reporte será recibido por la Secretaría de las TIC '
                'y Gobierno Abierto de la Alcaldía de Guadalajara de Buga.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: ColoresApp.contorno,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        'Nuevo Reporte',
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ColoresApp.sobreSuperficie,
        ),
      ),
      actions: [
        // Botón descartar borrador (solo visible si hay borrador)
        if (_tieneBorrador)
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: ColoresApp.error,
            tooltip: 'Descartar borrador',
            onPressed: _descartarBorrador,
          ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ColoresApp.primarioOscuro,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  Widget _seccion(String texto, [IconData? icono]) {
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
          ),
        ),
      ],
    );
  }

  Widget _construirCardInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Título
          _campoFormulario(
            etiqueta: 'Título del incidente *',
            pista: 'Ej. Hueco peligroso en vía pública',
            controlador: _ctrlTitulo,
            maxCaracteres: 100,
            icono: Icons.title,
            validador: (v) {
              if (v == null || v.trim().length < 5) {
                return 'El título debe tener al menos 5 caracteres';
              }
              if (v.trim().length > 100) {
                return 'El título no puede superar los 100 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Categoría
          _etiquetaCampo('Categoría *'),
          const SizedBox(height: 6),
          _selectorDropdown<String>(
            valor: _categoriaSeleccionada,
            opciones: const [
              ('hueco_via', 'Hueco / Vía deteriorada'),
              ('servicios_publicos', 'Servicios Públicos'),
              ('comunitario', 'Problema Comunitario'),
              ('aseo_parques', 'Aseo y Parques'),
            ],
            alCambiar: (v) {
              if (v != null) setState(() => _categoriaSeleccionada = v);
            },
          ),

          const SizedBox(height: 16),

          // Severidad
          _etiquetaCampo('Severidad'),
          const SizedBox(height: 6),
          _selectorDropdown<String>(
            valor: _severidadSeleccionada,
            opciones: const [
              ('baja', 'Baja — No urgente'),
              ('media', 'Media — Requiere atención'),
              ('alta', 'Alta — Afecta la vía'),
              ('critico', 'Crítico — Peligro inmediato'),
            ],
            alCambiar: (v) {
              if (v != null) setState(() => _severidadSeleccionada = v);
            },
          ),

          const SizedBox(height: 16),

          // Descripción
          _campoFormulario(
            etiqueta: 'Descripción *',
            pista: 'Describe el problema con detalle: tamaño, ubicación exacta, '
                'cuánto tiempo lleva, qué peligro representa...',
            controlador: _ctrlDescripcion,
            maxCaracteres: 500,
            maxLineas: 4,
            icono: Icons.description_outlined,
            validador: (v) {
              if (v == null || v.trim().length < 10) {
                return 'Describe el incidente con al menos 10 caracteres';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _construirCardUbicacion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_cargandoUbicacion)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColoresApp.primario,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Obteniendo ubicación GPS...'),
                ],
              ),
            )
          else if (_latitud != null && _longitud != null) ...[
            // Indicador de ubicación detectada
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColoresApp.terciarioClaro.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.my_location,
                    color: ColoresApp.terciario,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ubicación GPS detectada ✓',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ColoresApp.terciario,
                          ),
                        ),
                        Text(
                          'Lat: ${_latitud!.toStringAsFixed(5)}, '
                          'Lng: ${_longitud!.toStringAsFixed(5)}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: ColoresApp.sobreSuperficieVariante,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actualizar ubicación
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: ColoresApp.terciario,
                      size: 18,
                    ),
                    onPressed: _obtenerUbicacion,
                    tooltip: 'Actualizar ubicación',
                  ),
                ],
              ),
            ),
          ] else ...[
            // Sin GPS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColoresApp.advertenciaFondo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_off_outlined,
                    color: ColoresApp.advertencia,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No se pudo obtener el GPS. Activa la ubicación y toca "Reintentar".',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ColoresApp.advertencia,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _obtenerUbicacion,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirBotonEnviar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _enviando ? null : _enviarReporte,
        icon: _enviando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_outlined, size: 18),
        label: Text(
          _enviando ? 'Enviando reporte...' : 'Enviar Reporte a la Alcaldía',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primarioOscuro,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ColoresApp.contorno,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: ColoresApp.primarioSombra,
        ),
      ),
    );
  }

  // ── Helpers de formulario ──

  Widget _etiquetaCampo(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ColoresApp.sobreSuperficie,
        ),
      ),
    );
  }

  Widget _campoFormulario({
    required String etiqueta,
    required String pista,
    required TextEditingController controlador,
    required String? Function(String?) validador,
    int maxCaracteres = 200,
    int? maxLineas = 1,
    IconData? icono,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiquetaCampo(etiqueta),
        const SizedBox(height: 6),
        TextFormField(
          controller: controlador,
          maxLength: maxCaracteres,
          maxLines: maxLineas,
          validator: validador,
          inputFormatters: [
            // Bloquea caracteres peligrosos de inyección
            FilteringTextInputFormatter.deny(RegExp(r'[<>"\x00-\x1F]')),
          ],
          style: GoogleFonts.inter(
            fontSize: 14,
            color: ColoresApp.sobreSuperficie,
          ),
          decoration: InputDecoration(
            hintText: pista,
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: ColoresApp.contorno.withValues(alpha: 0.7),
            ),
            prefixIcon: icono != null
                ? Icon(icono, size: 18, color: ColoresApp.sobreSuperficieVariante)
                : null,
            filled: true,
            fillColor: const Color(0xFFF3F2FF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ColoresApp.primario, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ColoresApp.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ColoresApp.error, width: 1.5),
            ),
            counterStyle: GoogleFonts.inter(
              fontSize: 10,
              color: ColoresApp.contorno,
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectorDropdown<T>({
    required T valor,
    required List<(T, String)> opciones,
    required void Function(T?) alCambiar,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: valor,
          onChanged: alCambiar,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: ColoresApp.contorno,
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: ColoresApp.sobreSuperficie,
          ),
          items: opciones.map(((T, String) opcion) {
            return DropdownMenuItem<T>(
              value: opcion.$1,
              child: Text(opcion.$2),
            );
          }).toList(),
        ),
      ),
    );
  }
}
