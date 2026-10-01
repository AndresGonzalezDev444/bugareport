import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/app_theme.dart';

/// Bottom navigation bar with 5 tabs.
/// Tab 3 "Reportar" is the prominent central circular button (elevated).
/// Active tab is "Inicio" (index 0). Matches Figma node #3826:8867.
class BugaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BugaBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x141C2340), // rgba(28,35,64, 0.08)
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 1. Inicio
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Inicio',
              isActive: currentIndex == 0,
              onTap: () => onTap?.call(0),
            ),

            // 2. Mapa
            _NavItem(
              icon: Icons.map_outlined,
              activeIcon: Icons.map,
              label: 'Mapa',
              isActive: currentIndex == 1,
              onTap: () => onTap?.call(1),
            ),

            // 3. Reportar — elevated central circular button
            _ReportarButton(
              isActive: currentIndex == 2,
              onTap: () => onTap?.call(2),
            ),

            // 4. Borradores
            _NavItem(
              icon: Icons.cloud_off_outlined,
              label: 'Borradores',
              isActive: currentIndex == 3,
              onTap: () => onTap?.call(3),
              showBadge: true, // TODO: show when offline drafts exist
            ),

            // 5. Perfil
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Perfil',
              isActive: currentIndex == 4,
              onTap: () => onTap?.call(4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Regular navigation tab item.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final bool showBadge;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    this.showBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryDark : AppColors.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with optional badge dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? (activeIcon ?? icon) : icon,
                  color: color,
                  size: icon == Icons.cloud_off_outlined ? 20 : 18,
                ),
                if (showBadge)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 2),

            // Label
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                height: 14 / 11,
                color: color,
              ),
            ),

            // Active indicator dot
            if (isActive) ...[
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The central elevated "Reportar +" circular button.
class _ReportarButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;

  const _ReportarButton({required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 44,
      child: Column(
        children: [
          // Elevated circle — positioned above the nav bar
          Transform.translate(
            offset: const Offset(0, -20),
            child: Column(
              children: [
                // Circular button with shadow
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x59781E23), // rgba(122,30,35, 0.35)
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Label below
                Text(
                  'Reportar',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 14 / 11,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
