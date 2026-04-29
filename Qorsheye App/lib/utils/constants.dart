// ============================================================
// lib/utils/constants.dart
// App-wide constants, colors, and API base URL
// ============================================================

import 'package:flutter/material.dart';

/// Change this to your server IP when testing on a physical device.
/// Use 10.0.2.2 for Android emulator (maps to host localhost).
const String kApiBaseUrl = 'https://darkcyan-wallaby-957345.hostingersite.com/qorsheye_api/api';

class AppColors {
  // Primary palette
  static const Color primary      = Color(0xFF6C63FF);
  static const Color primaryDark  = Color(0xFF4B44CC);
  static const Color accent       = Color(0xFF00D4AA);
  static const Color warning      = Color(0xFFFFB547);
  static const Color error        = Color(0xFFFF5F6D);
  static const Color success      = Color(0xFF00C897);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF4F6FF);
  static const Color backgroundDark  = Color(0xFF0F0F1A);

  // Cards
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark  = Color(0xFF1C1C2E);

  // Text
  static const Color textLight = Color(0xFF1A1A2E);
  static const Color textDark  = Color(0xFFF0F0FF);

  // Status colors
  static const Color pending    = Color(0xFFFFB547);
  static const Color inProgress = Color(0xFF6C63FF);
  static const Color completed  = Color(0xFF00C897);
  static const Color overdue    = Color(0xFFFF5F6D);

  // Priority colors
  static const Color priorityLow    = Color(0xFF00C897);
  static const Color priorityMedium = Color(0xFFFFB547);
  static const Color priorityHigh   = Color(0xFFFF5F6D);
}

/// Utility helpers used across the app.
class AppConstants {
  /// Parses a hex color string into a Flutter [Color].
  ///
  /// Accepts formats:
  ///   - `#RRGGBB`  → `Color(0xFFRRGGBB)`
  ///   - `#AARRGGBB`
  ///   - `0xFFRRGGBB` (Flutter-style int string stored in DB)
  ///   - `0xAARRGGBB`
  ///
  /// Falls back to [AppColors.primary] if the string is invalid.
  static Color parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;

    // Handle Flutter-style 0xFFRRGGBB strings from the DB
    if (hex.startsWith('0x') || hex.startsWith('0X')) {
      final intVal = int.tryParse(hex);
      if (intVal != null) return Color(intVal);
    }

    // Strip leading '#'
    final clean = hex.replaceAll('#', '').trim();

    if (clean.length == 6) {
      final intVal = int.tryParse('FF$clean', radix: 16);
      if (intVal != null) return Color(intVal);
    } else if (clean.length == 8) {
      final intVal = int.tryParse(clean, radix: 16);
      if (intVal != null) return Color(intVal);
    }

    return AppColors.primary;
  }
}

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static TextStyle heading1(BuildContext context) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.5,
      );

  static TextStyle heading2(BuildContext context) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
        height: 1.5,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      );
}
