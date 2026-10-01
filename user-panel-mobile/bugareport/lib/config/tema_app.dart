import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores, tipografías y constantes de espaciado para BugaReport.
class ColoresApp {
  ColoresApp._();

  // ── Paleta Primaria ──
  static const Color primario = Color(0xFF7A1E23);
  static const Color primarioOscuro = Color(0xFF5B0510);
  static const Color primarioClaro = Color(0xFFFFDAD8);
  static const Color primarioSombra = Color(0x407A1E23); // 25% opacidad

  // ── Paleta Secundaria ──
  static const Color secundario = Color(0xFF86521B);
  static const Color secundarioContenedor = Color(0xFFFEB877);
  static const Color secundarioClaro = Color(0xFFFFDCC0);

  // ── Paleta Terciaria ──
  static const Color terciario = Color(0xFF184938);
  static const Color terciarioOscuro = Color(0xFF003223);
  static const Color terciarioClaro = Color(0xFFBBEED6);

  // ── Colores Semánticos ──
  static const Color advertencia = Color(0xFFE8760A);
  static const Color advertenciaFondo = Color(0xFFFFF0E0);
  static const Color error = Color(0xFFBA1A1A);
  static const Color emergenciaFondo = Color(0xFFFCE8E9);
  static const Color serviciosPublicos = Color(0xFF2B5C8F);
  static const Color comunitario = Color(0xFFC4864A);
  static const Color aseoParques = Color(0xFF2E5D4B);

  // ── Superficies y Fondo ──
  static const Color fondo = Color(0xFFFBF8FF);
  static const Color superficie = Color(0xFFFFFFFF);
  static const Color superficieTenue = Color(0xFFF1F5F9);
  static const Color iconoCategoriaBg = Color(0xFFFAF7F2);
  static const Color iconoCategoriaBorde = Color(0xFFE5E0D8);

  // ── Texto ──
  static const Color sobreSuperficie = Color(0xFF131A36);
  static const Color sobreSuperficieVariante = Color(0xFF564241);
  static const Color contorno = Color(0xFF897170);

  // ── Bordes y Efectos ──
  static const Color bordeClaro = Color(0x66DDC0BE);
  static const Color bordeCard = Color(0x80DDC0BE);
  static const Color conexionPildoraFondo = Color(0x26184938);

  /// Color del pin según la categoría del incidente.
  static Color colorPorCategoria(String categoria) {
    switch (categoria) {
      case 'hueco_via':
        return primario;
      case 'servicios_publicos':
        return serviciosPublicos;
      case 'comunitario':
        return comunitario;
      case 'aseo_parques':
        return aseoParques;
      default:
        return contorno;
    }
  }
}

class TemaApp {
  TemaApp._();

  static ThemeData get temaClaro {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ColoresApp.fondo,
      colorScheme: const ColorScheme.light(
        primary: ColoresApp.primario,
        onPrimary: Colors.white,
        secondary: ColoresApp.secundario,
        onSecondary: Colors.white,
        tertiary: ColoresApp.terciario,
        onTertiary: Colors.white,
        error: ColoresApp.error,
        surface: ColoresApp.superficie,
        onSurface: ColoresApp.sobreSuperficie,
        onSurfaceVariant: ColoresApp.sobreSuperficieVariante,
        outline: ColoresApp.contorno,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 40 / 32,
          color: ColoresApp.sobreSuperficie,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 32 / 24,
          letterSpacing: -0.025 * 24,
          color: ColoresApp.sobreSuperficie,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 28 / 20,
          color: ColoresApp.sobreSuperficie,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: ColoresApp.sobreSuperficie,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: ColoresApp.sobreSuperficie,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 16 / 12,
          color: ColoresApp.sobreSuperficieVariante,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
          color: ColoresApp.sobreSuperficie,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
          color: ColoresApp.sobreSuperficie,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 14 / 11,
          color: ColoresApp.sobreSuperficie,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.fondo,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
