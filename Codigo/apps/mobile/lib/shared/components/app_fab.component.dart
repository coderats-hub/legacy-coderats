/**
 * COMPONENTE DE BOTÃO FLUTUANTE PADRÃO
 * 
 * FloatingActionButton padronizado da aplicação.
 * Usa a cor primária (verde) e ícone branco por padrão.
 */

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  
  const AppFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
