/**
 * TEMA PRINCIPAL DA APLICAÇÃO
 * 
 * Define ThemeData completo usando Material 3 e ColorScheme.
 * Integra tokens da AppPalette em um esquema de cores semântico.
 * 
 * Recursos:
 * - Material 3 habilitado para componentes modernos
 * - ColorScheme escuro completo com containers
 * - Mapeamento semântico (primary, secondary, error, etc.)
 * - Cores de superfície e outline consistentes
 * 
 * Uso: MaterialApp(theme: AppTheme.dark())
 */

import 'package:flutter/material.dart';
import 'tokens.theme.dart';   // onde está o AppPalette

class AppTheme {
  // Tema escuro principal da aplicação
  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkScheme,
        scaffoldBackgroundColor: _darkScheme.background,
      );

  // ColorScheme escuro com mapeamento semântico das cores da AppPalette
  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,

    primary: AppPalette.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF143F2C),
    onPrimaryContainer: Color(0xFFC7F6DE),

    secondary: AppPalette.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF0C2E3A),
    onSecondaryContainer: Color(0xFFBFEAFF),

    tertiary: AppPalette.tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF2E2046),
    onTertiaryContainer: Color(0xFFE6DDFF),

    error: AppPalette.danger,
    onError: Colors.white,
    errorContainer: Color(0xFF5C1A1A),
    onErrorContainer: Color(0xFFFFDAD6),

    background: AppPalette.background,
    onBackground: AppPalette.textPrimary,
    surface: AppPalette.surface,
    onSurface: AppPalette.textPrimary,
    surfaceVariant: AppPalette.surfaceVariant,
    onSurfaceVariant: AppPalette.textSecondary,

    outline: AppPalette.divider,
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: Color(0xFFE7E7E7),
    onInverseSurface: Color(0xFF1B1B1B),
    inversePrimary: Color(0xFF0F8C59),
  );
}
