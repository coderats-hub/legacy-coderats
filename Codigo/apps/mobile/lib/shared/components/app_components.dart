
/**
 * COMPONENTES GLOBAIS DA APLICAÇÃO
 * 
 * Este arquivo contém widgets reutilizáveis usados em toda a aplicação:
 * - AppFAB: Botão flutuante padronizado
 * - AppHeader: Header/AppBar customizado
 * - AppNavbar: Navegação inferior
 * - SharedTextField: Campo de entrada de texto
 * - UserAvatarInfo: Avatar com informações do usuário
 * - AppButton: Botão customizável
 * 
 * Estes componentes garantem consistência visual e reduzem duplicação
 * de código em toda a aplicação.
 */

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Botão flutuante padrão da aplicação
class AppFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  const AppFAB({super.key, required this.onPressed, this.icon = Icons.add, this.tooltip});

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


// Header/AppBar customizado para padronização em toda app
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  final String title;              // Título exibido no header
  final VoidCallback? onBack;      // Função chamada ao tocar "voltar" (opcional)
  final List<Widget>? actions;     // Botões de ação no lado direito (opcional)
  
  const AppHeader({super.key, required this.title, this.onBack, this.actions});

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

// Barra de navegação inferior padrão da aplicação
class AppNavbar extends StatelessWidget {
  final int currentIndex;           // Índice da aba atualmente selecionada
  final ValueChanged<int> onTap;    // Função chamada quando uma aba é tocada
  
  const AppNavbar({super.key, required this.currentIndex, required this.onTap});

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

// Campo de entrada de texto padronizado e customizável
class SharedTextField extends StatelessWidget {
  final String? label;                          // Rótulo do campo (opcional)
  final String placeholder;                     // Texto de placeholder
  final TextEditingController? controller;      // Controlador do campo
  final bool isPassword;                        // Se é campo de senha
  final bool? obscureText;                      // Se deve ocultar texto
  final TextInputType? keyboardType;           // Tipo de teclado
  final String? Function(String?)? validator;  // Função de validação
  final int? maxLines;                         // Número máximo de linhas
  final bool enabled;                          // Se o campo está habilitado
  final bool required;                         // Se o campo é obrigatório

  const SharedTextField({
    super.key,
    this.label,
    required this.placeholder,
    this.controller,
    this.isPassword = false,
    this.obscureText,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: AppTextStyles.inputLabel,
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: AppTextStyles.inputLabel.copyWith(color: Colors.red),
                      )
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText ?? isPassword,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          style: AppTextStyles.inputLabel,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFFACACAC),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppCorners.sm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppCorners.sm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppCorners.sm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

/// Componente reutilizável para avatar com informações do usuário
class UserAvatarInfo extends StatelessWidget {
  final String label;
  final String subtitle;
  final double avatarRadius;
  final VoidCallback? onTap;
  final bool showAvatar;
  
  const UserAvatarInfo({
    super.key,
    required this.label,
    required this.subtitle,
    this.avatarRadius = 18,
    this.onTap,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Row(
      children: [
        if (showAvatar) ...[
          CircleAvatar(
            radius: avatarRadius, 
            backgroundColor: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label, 
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 14, 
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle, 
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 13, 
                color: Colors.white, 
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: widget)
        : widget;
  }
}

/// Botão customizável
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool expanded;
  const AppButton({super.key, required this.text, required this.onPressed, this.color, this.expanded = true});

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
  return expanded ? SizedBox(width: double.infinity, height: 44, child: button) : button;
  }
}
