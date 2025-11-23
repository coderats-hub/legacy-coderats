/**
 * COMPONENTE DE HEADER PADRONIZADO
 * 
 * AppBar customizado usado em toda a aplicação.
 * Características:
 * - Título alinhado à esquerda
 * - Botão de voltar opcional
 * - Actions personalizáveis
 * - Altura aumentada para melhor espaçamento
 */

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  final String title;              // Título exibido no header
  final VoidCallback? onBack;      // Função chamada ao tocar "voltar" (opcional)
  final List<Widget>? actions;     // Botões de ação no lado direito (opcional)
  
  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      // Desce bastante o título dentro do AppBar para ficar bem mais baixo
      toolbarHeight: 120,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(AppSpacing.sm),
        child: SizedBox(height: AppSpacing.sm),
      ),
      // Aproxima o título do ícone sem cortar o botão
      leadingWidth: 44,
      titleSpacing: 0,
      leading: onBack == null
          ? (Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  padding: const EdgeInsets.all(8),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null)
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              padding: const EdgeInsets.all(8),
              onPressed: onBack,
            ),
      title: Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 0, 20),
        child: Text(title, style: AppTextStyles.headerTitle),
      ),
      actions: actions,
      centerTitle: false,
    );
  }
}
