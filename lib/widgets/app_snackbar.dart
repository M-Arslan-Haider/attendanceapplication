import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Centralized SnackBar styles for the whole app.
/// Use these instead of building SnackBar/ScaffoldMessenger calls manually,
/// so every screen shows the exact same look.
class AppSnackBar {
  AppSnackBar._();

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Clear any currently showing snackbar so they don't stack up.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        elevation: 4,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Green success snackbar. e.g. Login success, Check-in success.
  static void success(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      subtitle: subtitle,
      backgroundColor: AppTheme.successColor,
      icon: Icons.check_circle,
      duration: duration,
    );
  }

  /// Red error snackbar. e.g. Login failed, out of range.
  static void error(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      subtitle: subtitle,
      backgroundColor: AppTheme.errorColor,
      icon: Icons.error,
      duration: duration,
    );
  }

  /// Orange warning snackbar. e.g. permission needed, GPS off.
  static void warning(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      subtitle: subtitle,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning_amber_rounded,
      duration: duration,
    );
  }

  /// Neutral info snackbar. e.g. "Feature coming soon".
  static void info(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      subtitle: subtitle,
      backgroundColor: AppTheme.textPrimaryColor,
      icon: Icons.info_outline,
      duration: duration,
    );
  }
}
