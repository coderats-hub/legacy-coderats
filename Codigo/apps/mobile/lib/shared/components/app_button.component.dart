/**
 * COMPONENTE DE BOTÃO PADRONIZADO
 * 
 * Botão customizável usado em toda a aplicação.
 * Características:
 * - Cor configurável (padrão: verde primário)
 * - Largura expansível ou compacta
 * - Texto e ação personalizáveis
 * - Estilo consistente com o design system
 */

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool expanded;
  
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.sm),
        ),
        elevation: 0,
      ),
      child: Text(text, style: AppTextStyles.button),
    );
    
    return expanded 
        ? SizedBox(width: double.infinity, height: 44, child: button) 
        : button;
  }
}
