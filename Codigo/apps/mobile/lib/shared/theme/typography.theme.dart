/**
 * SISTEMA DE TIPOGRAFIA
 * 
 * Constrói o TextTheme baseado na fonte Inter do Google Fonts.
 * Aplica pesos e espaçamentos otimizados para legibilidade.
 * 
 * Configurações:
 * - Fonte base: Inter (via Google Fonts)
 * - Display: peso 700 com letter-spacing negativo
 * - Headings: peso 600 para hierarquia clara
 * - Body: altura de linha otimizada (1.3-1.35)
 * - Labels: peso 600 para destaque em botões
 * 
 * Cores aplicadas automaticamente baseadas no ColorScheme.
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Constrói TextTheme personalizado com fonte Inter e pesos otimizados
TextTheme buildTextTheme(ColorScheme scheme) {
  final base = GoogleFonts.interTextTheme();

  return base.copyWith(
    displayLarge:   base.displayLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
    displayMedium:  base.displayMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.25),
    headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
    titleLarge:     base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    titleMedium:    base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    bodyLarge:      base.bodyLarge?.copyWith(height: 1.3),
    bodyMedium:     base.bodyMedium?.copyWith(height: 1.35),
    labelLarge:     base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  ).apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );
}
