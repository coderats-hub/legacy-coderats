/**
 * EXTENSÕES DO SISTEMA DE TEMA
 * 
 * Este arquivo estende o tema base da aplicação com estilos pré-definidos
 * para reduzir o uso excessivo de copyWith() no código.
 * 
 * Contém:
 * - AppTextStylesExtended: Estilos de texto comumente usados
 * - AppColorsExtended: Cores consolidadas e variações
 * 
 * Benefícios:
 * - Reduz duplicação de código
 * - Melhora consistência visual
 * - Facilita manutenção de estilos
 * - Performance melhor (estilos pré-compilados)
 */

import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';

// Estilos de texto pré-definidos para evitar copyWith excessivos
class AppTextStylesExtended {
  // Estilos de título com texto branco em diferentes tamanhos
  static final titleWhite = AppTextStyles.title.copyWith(
    color: Colors.white,
  );
  
  static final titleWhiteLarge = AppTextStyles.title.copyWith(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  
  static final titleWhiteMedium = AppTextStyles.title.copyWith(
    color: Colors.white,
    fontSize: 18,
  );
  
  static final titleWhiteSmall = AppTextStyles.title.copyWith(
    color: Colors.white,
    fontSize: 16,
  );
  
  static final subtitleWhite = AppTextStyles.subtitle.copyWith(
    color: Colors.white,
  );
  
  static final subtitleWhiteBold = AppTextStyles.subtitle.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  
  static final buttonWhite = AppTextStyles.button.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );
  
  static final inputWhite = AppTextStyles.inputLabel.copyWith(
    color: Colors.white,
  );
  
  static final inputHintWhite = AppTextStyles.inputHint.copyWith(
    color: Colors.white70,
  );
  
  static final inputHintWhiteLight = AppTextStyles.inputHint.copyWith(
    color: Colors.white54,
  );
  
  // Estilos com cores específicas
  static final errorText = AppTextStyles.inputLabel.copyWith(
    color: Colors.red,
  );
  
  static final primaryText = AppTextStyles.inputHint.copyWith(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
    fontSize: 10,
  );
}

// Cores consolidadas para eliminar valores hardcoded espalhados no código
class AppColorsExtended {
  // Cores base do tema principal
  static const primary = AppColors.primary;       // Verde principal
  static const accent = AppColors.accent;         // Roxo do tema
  static const background = AppColors.background; // Fundo escuro
  static const surface = AppColors.surface;       // Superfícies
  
  // Variações de branco padronizadas para consistência
  static const white = Colors.white;                    // Branco puro
  static const whiteTransparent = Colors.white10;       // Branco bem transparente
  static final white70 = Colors.white.withOpacity(0.7); // Branco 70% opaco
  static final white54 = Colors.white.withOpacity(0.54); // Branco 54% opaco
  static final white92 = Colors.white.withOpacity(0.92); // Branco 92% opaco
  
  // Cores funcionais para diferentes estados
  static const error = Colors.red;           // Vermelho para erros
  static const success = AppColors.accent;   // Roxo para sucesso
  static const transparent = Colors.transparent; // Transparente
  static const black = Colors.black;         // Preto puro
}