import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../widgets/shared/connectivity_pill.dart';

/// Top app bar matching the Figma design:
/// Logo BugaReport (left) + Connectivity pill + notification bell (right).
class BugaTopAppBar extends StatelessWidget {
  const BugaTopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo BugaReport from assets
            Image.asset(
              'assets/images/logo-buga-report.png',
              height: 40,
              fit: BoxFit.contain,
            ),

            // Right side: connectivity pill + notifications
            Row(
              children: [
                const ConnectivityPill(isOnline: true),
                const SizedBox(width: 4),
                // Notification bell with badge
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Navigate to notifications
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    // Red notification dot
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
