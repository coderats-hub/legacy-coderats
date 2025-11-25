/**
 * COMPONENTE DE NAVEGAÇÃO INFERIOR
 * 
 * Barra de navegação padronizada com 3 abas:
 * - Início (Feed)
 * - Grupos
 * - Perfil
 */

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppNavbar extends StatelessWidget {
  final int currentIndex;           // Índice da aba atualmente selecionada
  final ValueChanged<int> onTap;    // Função chamada quando uma aba é tocada
  
  const AppNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.surface,
      currentIndex: currentIndex,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textDisabled,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.groups_2_outlined), label: 'Grupos'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    );
  }
}
