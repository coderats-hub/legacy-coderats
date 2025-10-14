import 'package:flutter/material.dart';

/// Paleta de cores padrão do app, baseada nas telas started, login e register.
class AppColors {
  static const background = Color(0xFF222222);
  static const surface = Color(0xFF333333);
  static const border = Color(0xFF444444);

  static const primary = Color(0xFF25A18E); // Verde principal
  static const accent = Color(0xFF9A24DD); // Roxo escuro
  static const accentLight = Color(0xFFB24DEB); // Roxo claro
  static const textPrimary = Color(0xFFD9D9D9);
  static const textSecondary = Color(0xFFAAAAAA);
  static const textDisabled = Color(0xFF666666);
  static const skip = Color(0xFFFF7A45); // Laranja para links
}

/// Tipografia padrão do app
class AppTextStyles {
  static const title = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  static const subtitle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  static const button = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  static const inputLabel = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  static const inputHint = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: AppColors.textDisabled,
  );
}

/// Espaçamentos padrão
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Bordas padrão
class AppCorners {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}
