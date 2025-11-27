/**
 * SISTEMA DE TEMA PRINCIPAL DA APLICAÇÃO
 * 
 * Este arquivo define o design system completo do Code Rats:
 * - AppColors: Paleta de cores padronizada
 * - AppTextStyles: Estilos de tipografia
 * - AppSpacing: Espaçamentos consistentes  
 * - AppCorners: Raios de borda padronizados
 * 
 * O tema é baseado em um design escuro com:
 * - Fundo principal: #222222
 * - Superfícies: #333333  
 * - Cor primária: #25A18E (verde)
 * - Cor de destaque: #9A24DD (roxo)
 * - Tipografia: Inter em diferentes pesos
 * 
 * Todos os componentes da app devem usar essas constantes
 * para manter consistência visual.
 */

import 'package:flutter/material.dart';

// Paleta de cores padrão da aplicação Code Rats
class AppColors {
  // Cores utilitárias
  static const dividerAccent = Color(0xFFACACAC); // Cor para divisórias
  static const iconWhite = Color(0xFFFFFFFF);     // Ícones brancos padrão
  
  // Cores de fundo e superfície (tema escuro)
  static const background = Color(0xFF222222);    // Fundo principal da app
  static const surface = Color(0xFF333333);       // Superfícies (cards, botões)
  static const border = Color(0xFF444444);        // Bordas e divisores
  
  // Cores da marca Code Rats
  static const primary = Color(0xFF25A18E);       // Verde principal (botões, destaques)
  static const accent = Color(0xFF9A24DD);        // Roxo escuro (acentos, gradientes)
  static const accentLight = Color(0xFFB24DEB);   // Roxo claro (variações)
  
  // Cores de texto (hierarquia visual)
  static const textPrimary = Color(0xFFD9D9D9);   // Texto principal (títulos)
  static const textSecondary = Color(0xFFAAAAAA); // Texto secundário (descrições)
  static const textDisabled = Color(0xFF666666);  // Texto desabilitado
  
  // Cores funcionais
  static const skip = Color(0xFFFF7A45);          // Laranja para links "pular"
  static const error = Color(0xFFE53935);         // Vermelho para erros
  static const success = Color(0xFF4CAF50);       // Verde para sucesso
}

// Sistema de tipografia da aplicação (fonte Inter)
class AppTextStyles {
  // Estilo para títulos de header/AppBar
  static const headerTitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w900, // Extra bold para destaque
    fontSize: 20,
    color: Colors.white,        // Sempre branco para contraste
  );
  static const titleBlack = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w900,
    fontSize: 24,
    color: Colors.white,
    height: 1.2,
  );
  static const descriptionWhite = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: Colors.white,
    height: 1.35,
  );
  static const actionBoldWhite = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.white,
    height: 1.2,
  );
  static const skipBold = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: AppColors.skip,
    decoration: TextDecoration.none,
  );
  static const headlineBold16White = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: AppColors.iconWhite,
    height: 1.2,
  );

  // Estilos de texto para diferentes hierarquias
  static const title = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,    // Bold para títulos
    fontSize: 22,
    color: AppColors.textPrimary,   // Cor primária de texto
    height: 1.2,                    // Altura da linha
  );
  static const subtitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: AppColors.textSecondary, // Cor secundária (menos destaque)
    height: 1.4,
  );
  static const button = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,    // Semi-bold para botões
    fontSize: 18,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  static const inputLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  static const inputHint = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    color: AppColors.textDisabled,
  );
}

// Sistema de espaçamentos padronizados (múltiplos de 4)
class AppSpacing {
  static const double xs = 4;    // Extra pequeno (4px)
  static const double sm = 8;    // Pequeno (8px) 
  static const double md = 16;   // Médio (16px) - padrão
  static const double lg = 24;   // Grande (24px)
  static const double xl = 32;   // Extra grande (32px)
  static const double xxl = 40;  // Muito grande (40px)
  static const double xxxl = 56; // Extremamente grande (56px)
}

// Sistema de raios de borda padronizados
class AppCorners {
  static const double sm = 8;   // Pequeno - botões, campos
  static const double md = 12;  // Médio - cards pequenos
  static const double lg = 16;  // Grande - cards principais
  static const double xl = 24;  // Extra grande - containers especiais
}
