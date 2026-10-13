import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bugareport/config/tema_app.dart';

/// Widget selector de fotografía para el formulario de reporte.
///
/// Permite:
/// - Tomar foto con la cámara
/// - Seleccionar desde la galería
/// - Ver previsualización de la foto elegida
/// - Eliminar la foto seleccionada
class SelectorFoto extends StatelessWidget {
  final File? fotoSeleccionada;
  final void Function(File foto) alSeleccionar;
  final VoidCallback? alEliminar;
  final String? errorTexto;

  const SelectorFoto({
    super.key,
    this.fotoSeleccionada,
    required this.alSeleccionar,
    this.alEliminar,
    this.errorTexto,
  });

  Future<void> _seleccionarFuente(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: ColoresApp.superficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ColoresApp.bordeClaro,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              Text(
                'Agregar evidencia fotográfica',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.sobreSuperficie,
                ),
              ),
              const SizedBox(height: 16),
              _OpcionFuente(
                icono: Icons.camera_alt_outlined,
                titulo: 'Tomar foto',
                subtitulo: 'Captura el incidente en tiempo real',
                alTocar: () async {
                  Navigator.pop(context);
                  await _capturar(ImageSource.camera);
                },
              ),
              const Divider(height: 16),
              _OpcionFuente(
                icono: Icons.photo_library_outlined,
                titulo: 'Seleccionar de galería',
                subtitulo: 'Elige una foto ya tomada',
                alTocar: () async {
                  Navigator.pop(context);
                  await _capturar(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _capturar(ImageSource fuente) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: fuente,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (xFile != null) {
      alSeleccionar(File(xFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fotoSeleccionada == null)
          _construirAreaSinFoto(context)
        else
          _construirPreviewFoto(context),
        if (errorTexto != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: ColoresApp.error),
              const SizedBox(width: 4),
              Text(
                errorTexto!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: ColoresApp.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _construirAreaSinFoto(BuildContext context) {
    return GestureDetector(
      onTap: () => _seleccionarFuente(context),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F2FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: errorTexto != null
                ? ColoresApp.error
                : const Color(0xFFCECEFF),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ColoresApp.primarioClaro.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: ColoresApp.primario,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Agregar foto del incidente *',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColoresApp.primario,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cámara o galería • Máx. 5MB',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: ColoresApp.contorno,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirPreviewFoto(BuildContext context) {
    return Stack(
      children: [
        // Imagen previsualizada
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            fotoSeleccionada!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Overlay oscuro en la parte inferior
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Foto agregada correctamente',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Botón cambiar foto
                GestureDetector(
                  onTap: () => _seleccionarFuente(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Cambiar',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Botón eliminar (X)
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: alEliminar,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _OpcionFuente extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback alTocar;

  const _OpcionFuente({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: ColoresApp.primario, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.sobreSuperficie,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ColoresApp.contorno,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: ColoresApp.contorno,
            ),
          ],
        ),
      ),
    );
  }
}
