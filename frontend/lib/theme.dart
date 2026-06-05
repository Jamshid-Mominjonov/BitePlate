library;

import 'package:flutter/material.dart';

class BiteTheme {
  static const Color accent = Color(0xFF1A1A1A);
  static const Color amber = Color(0xFF1A1A1A);
  static const Color terracotta = Color(0xFFB3261E);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color canvas = Color(0xFFF7F7F5);
  static const Color line = Color(0xFFE6E4E0);

  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      primary: accent,
      onPrimary: Colors.white,
      secondary: const Color(0xFF6B6B6B),
      surface: surface,
      onSurface: const Color(0xFF1A1A1A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      fontFamily: 'Helvetica Neue',
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: line),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Color(0xFF1A1A1A),
        titleTextStyle: TextStyle(
          fontFamily: 'Helvetica Neue',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: Color(0xFF1A1A1A),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: canvas,
        side: const BorderSide(color: line),
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A1A1A),
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line),
        ),
        isDense: true,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: Color(0xFFEDEBE7),
        selectedIconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
        unselectedIconTheme: IconThemeData(color: Color(0xFF9A9A9A)),
        selectedLabelTextStyle: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelTextStyle: TextStyle(color: Color(0xFF9A9A9A), fontSize: 12),
      ),
    );
  }

  static Color stateColor(String state) {
    switch (state) {
      case 'free':
        return const Color(0xFF4F7D63);
      case 'reserved':
        return const Color(0xFF9A7B3F);
      case 'occupied':
        return const Color(0xFFB3261E);
      case 'awaitingBill':
        return const Color(0xFF5B5B7A);
      case 'preparing':
      case 'sentToKitchen':
        return const Color(0xFF9A7B3F);
      case 'ready':
        return const Color(0xFF4F7D63);
      case 'served':
        return const Color(0xFF5A6B73);
      case 'cancelled':
        return const Color(0xFF9A9A9A);
      default:
        return const Color(0xFF6B6B6B);
    }
  }
}
