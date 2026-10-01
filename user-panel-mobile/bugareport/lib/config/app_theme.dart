import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens extracted from Figma (node 3826-8684).
/// All colors, typography, and spacing constants for BugaReport.
class AppColors {
  AppColors._();

  // ── Primary Palette ──
  static const Color primary = Color(0xFF7A1E23);
  static const Color primaryDark = Color(0xFF5B0510);
  static const Color primaryLight = Color(0xFFFFDAD8);
  static const Color primaryShadow = Color(0x407A1E23); // 25% opacity

  // ── Secondary Palette ──
  static const Color secondary = Color(0xFF86521B);
  static const Color secondaryContainer = Color(0xFFFEB877);
  static const Color secondaryLight = Color(0xFFFFDCC0);

  // ── Tertiary Palette ──
  static const Color tertiary = Color(0xFF184938);
  static const Color tertiaryDark = Color(0xFF003223);
  static const Color tertiaryLight = Color(0xFFBBEED6);

  // ── Semantic Colors ──
  static const Color warning = Color(0xFFE8760A);
  static const Color warningBg = Color(0xFFFFF0E0);
  static const Color error = Color(0xFFBA1A1A);
  static const Color emergencyBg = Color(0xFFFCE8E9);
  static const Color serviciosPublicos = Color(0xFF2B5C8F);
  static const Color comunitario = Color(0xFFC4864A);
  static const Color aseoParques = Color(0xFF2E5D4B);

  // ── Surface & Background ──
  static const Color background = Color(0xFFFBF8FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF1F5F9);
  static const Color categoryIconBg = Color(0xFFFAF7F2);
  static const Color categoryIconBorder = Color(0xFFE5E0D8);

  // ── Text ──
  static const Color onSurface = Color(0xFF131A36);
  static const Color onSurfaceVariant = Color(0xFF564241);
  static const Color outline = Color(0xFF897170);

  // ── Borders & Effects ──
  static const Color borderLight = Color(0x66DDC0BE); // 40% opacity
  static const Color borderCard = Color(0x80DDC0BE); // 50% opacity
  static const Color connectivityPillBg = Color(0x26184938); // 15% opacity

  // ── Map Pin Colors (by category) ──
  static Color pinForCategory(String category) {
    switch (category) {
      case 'hueco_via':
        return primary;
      case 'servicios_publicos':
        return serviciosPublicos;
      case 'comunitario':
        return comunitario;
      case 'aseo_parques':
        return aseoParques;
      default:
        return outline;
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        tertiary: AppColors.tertiary,
        onTertiary: Colors.white,
        error: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // Headlines use Montserrat
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 40 / 32,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 32 / 24,
          letterSpacing: -0.025 * 24,
          color: AppColors.onSurface,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 28 / 20,
          color: AppColors.onSurface,
        ),
        // Title (Montserrat)
        titleLarge: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: Colors.white,
        ),
        // Body uses Inter
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: AppColors.onSurface,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 16 / 12,
          color: AppColors.onSurfaceVariant,
        ),
        // Labels use Inter
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
          color: AppColors.onSurface,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
          color: AppColors.onSurface,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 14 / 11,
          color: AppColors.onSurface,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
