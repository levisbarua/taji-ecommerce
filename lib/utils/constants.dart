import 'package:flutter/material.dart';

// ── Premium Golden Amber Palette ──
// Accent
const Color tajiAmber = Color(0xFFFFB800);
const Color tajiAmberDark = Color(0xFFE5A600);

// Dark mode surfaces
const Color tajiDarkBg = Color(0xFF000000);
const Color tajiDarkSurface = Color(0xFF151515);
const Color tajiDarkBorder = Color(0xFF333333);

// Light mode surfaces
const Color tajiLightBg = Color(0xFFF5F5F0);
const Color tajiLightSurface = Color(0xFFFFFFFF);
const Color tajiLightBorder = Color(0xFFE0E0D8);

// Text colors
const Color tajiTextLight = Color(0xFFF5F5F5);
const Color tajiTextDark = Color(0xFF000000);
const Color tajiTextMutedDark = Color(0xFFAAAAAA);
const Color tajiTextMutedLight = Color(0xFF666666);

// Semantic colors
const Color tajiError = Color(0xFFD32F2F);
const Color tajiSuccess = Color(0xFF2E7D32);

// Legacy aliases
const Color pureBlack = tajiDarkBg;
const Color pureWhite = tajiLightSurface;
const Color pureYellow = tajiAmber;

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

ThemeData buildLightTheme() => ThemeData(
  scaffoldBackgroundColor: tajiLightBg,
  cardColor: tajiLightSurface,
  colorScheme: const ColorScheme.light(
    primary: tajiAmber,
    onPrimary: tajiTextDark,
    secondary: tajiAmberDark,
    onSecondary: tajiTextDark,
    surface: tajiLightSurface,
    onSurface: tajiTextDark,
    error: tajiError,
    outline: tajiLightBorder,
    surfaceContainerHighest: tajiLightBg,
  ),
  dividerColor: tajiLightBorder,
  useMaterial3: true,
);

ThemeData buildDarkTheme() => ThemeData(
  scaffoldBackgroundColor: tajiDarkBg,
  cardColor: tajiDarkSurface,
  colorScheme: const ColorScheme.dark(
    primary: tajiAmber,
    onPrimary: tajiTextDark,
    secondary: tajiAmberDark,
    onSecondary: tajiTextDark,
    surface: tajiDarkBg,
    onSurface: tajiTextLight,
    error: tajiError,
    outline: tajiDarkBorder,
    surfaceContainerHighest: tajiDarkSurface,
  ),
  dividerColor: tajiDarkBorder,
  useMaterial3: true,
);
