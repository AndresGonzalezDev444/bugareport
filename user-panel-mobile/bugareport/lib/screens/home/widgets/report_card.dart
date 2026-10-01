import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/app_theme.dart';

/// Individual info card used in the 2-column action grid.
/// Can be configured as "Mis Reportes" or "Borradores offline".
class ReportCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final String title;
  final List<ReportCardStat> stats;
  final String? subtitle;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.title,
    this.stats = const [],
    this.subtitle,
    this.onTap,
  });

  /// Pre-configured "Mis Reportes" card with live stats from Supabase.
  factory ReportCard.misReportes({
    required Map<String, int> stats,
    VoidCallback? onTap,
  }) {
    return ReportCard(
      icon: Icons.description_outlined,
      iconBgColor: const Color(0x80FFDAD8), // rgba(255, 218, 216, 0.5)
      iconColor: const Color(0xFF410007),
      badgeText: '${stats['total'] ?? 0} Total',
      badgeBgColor: const Color(0xFFFFDCC0),
      badgeTextColor: const Color(0xFF2D1600),
      title: 'Mis Reportes',
      stats: [
        ReportCardStat(
          dotColor: AppColors.secondary,
          text: '${stats['en_proceso'] ?? 0} en proceso',
        ),
        ReportCardStat(
          dotColor: AppColors.tertiaryDark,
          text: '${stats['resuelto'] ?? 0} resueltos',
        ),
      ],
      onTap: onTap,
    );
  }

  /// Pre-configured "Borradores offline" card.
  factory ReportCard.borradoresOffline({
    int pendingCount = 0,
    VoidCallback? onTap,
  }) {
    return ReportCard(
      icon: Icons.cloud_off_outlined,
      iconBgColor: const Color(0x66FEB877), // rgba(254, 184, 119, 0.4)
      iconColor: const Color(0xFF78470F),
      badgeText: '$pendingCount Pendientes',
      badgeBgColor: AppColors.warningBg,
      badgeTextColor: AppColors.warning,
      title: 'Borradores offline',
      subtitle: 'Listos para sincronizar al\nreconectar',
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderCard.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                // Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _isBadgePill ? 8 : 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(_isBadgePill ? 9999 : 4),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 14 / 11,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 16 / 12,
                color: AppColors.onSurface,
              ),
            ),

            // Stats list (for Mis Reportes)
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 2),
              ...stats.map((stat) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: stat.dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          stat.text,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            // Subtitle (for Borradores)
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 15 / 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _isBadgePill =>
      badgeBgColor == AppColors.warningBg;
}

/// A single stat row in the ReportCard (e.g., "3 en proceso").
class ReportCardStat {
  final Color dotColor;
  final String text;

  const ReportCardStat({required this.dotColor, required this.text});
}
