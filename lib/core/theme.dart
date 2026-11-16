import 'package:flutter/material.dart';

class AppPalette {
  static const teal = Color(0xFF22D3BA);
  static const navy = Color(0xFF0A1424);
  static const blue = Color(0xFF62A8FF);
  static const amber = Color(0xFFF3BD65);
  static const rose = Color(0xFFF48191);
}

ThemeData appTheme({required bool dark, required bool highContrast}) {
  final brightness = dark ? Brightness.dark : Brightness.light;
  final background = dark ? const Color(0xFF091321) : const Color(0xFFF2F7FA);
  final surface = dark ? const Color(0xFF142237) : Colors.white;
  final scheme = ColorScheme.fromSeed(
    seedColor: highContrast ? const Color(0xFF00DDFF) : AppPalette.teal,
    brightness: brightness,
    surface: surface,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarThemeData(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: dark ? Colors.white : AppPalette.navy,
        fontWeight: FontWeight.w800, fontSize: 19,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    visualDensity: VisualDensity.standard,
  );
}
