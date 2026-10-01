import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Small pill showing connectivity status.
/// Green dot + "En línea" or red dot + "Sin conexión".
class ConnectivityPill extends StatelessWidget {
  final bool isOnline;

  const ConnectivityPill({super.key, this.isOnline = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.connectivityPillBg
            : AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.tertiaryDark : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'En línea' : 'Sin conexión',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isOnline ? AppColors.tertiaryDark : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
