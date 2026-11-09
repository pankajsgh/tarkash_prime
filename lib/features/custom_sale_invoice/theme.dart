import 'package:flutter/material.dart';

class AppColors {
  static const sidebar = Color(0xFF0F1D2E);
  static const sidebarText = Color(0xFFB4C0CE);
  static const accent = Color(0xFF0F766E);
  static const bg = Color(0xFFF1F4F8);
  static const border = Color(0xFFDDE3EA);
  static const headerFill = Color(0xFFF6F8FB);
  static const muted = Color(0xFF64748B);
  static const ink = Color(0xFF0F172A);
  static const good = Color(0xFF15803D);
  static const warn = Color(0xFFB45309);
  static const bad = Color(0xFFB91C1C);
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
      scaffoldBackgroundColor: AppColors.bg,
      dividerColor: AppColors.border,
    );
