import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from VIRTUM_FLUTTER_STANDALONE_SPEC (light / Apple-like).
abstract final class VirtumColors {
  static const Color bgPage = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF2F2F7);
  static const Color line = Color(0xFFD2D2D7);
  static const Color lineSoft = Color(0xFFE5E5EA);
  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textMuted = Color(0xFF6E6E73);
  static const Color placeholder = Color(0xFF8E8E93);
  static const Color accent = Color(0xFF0071E3);
  static const Color accentHover = Color(0xFF0066CC);
  static const Color success = Color(0xFF34C759);
  static const Color danger = Color(0xFFFF3B30);
  static const Color bannerOffline = Color(0xFFC53030);
}

ThemeData buildVirtumTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: VirtumColors.bgPage,
    colorScheme: ColorScheme.fromSeed(
      seedColor: VirtumColors.accent,
      brightness: Brightness.light,
      primary: VirtumColors.accent,
      surface: VirtumColors.surface,
    ),
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: VirtumColors.textPrimary,
    displayColor: VirtumColors.textPrimary,
  );

  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: VirtumColors.lineSoft),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: VirtumColors.surface,
      foregroundColor: VirtumColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: VirtumColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: VirtumColors.lineSoft),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: VirtumColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF3F536E),
        backgroundColor: const Color(0xFFEEF2F7),
        side: const BorderSide(color: Color(0xFFCFD9E8)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: VirtumColors.surface,
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: VirtumColors.accent, width: 1.5),
      ),
      hintStyle: const TextStyle(color: VirtumColors.placeholder),
      labelStyle: const TextStyle(color: VirtumColors.textMuted),
    ),
  );
}
