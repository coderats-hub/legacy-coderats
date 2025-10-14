import 'package:flutter/material.dart';
import '../theme/app_theme.dart';


/// Header dinâmico com botão voltar e título customizável
class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  const AppHeader({super.key, required this.title, this.onBack, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      title: Text(title, style: AppTextStyles.title),
      actions: actions,
      centerTitle: false,
    );
  }
}

/// Navbar padrão do app com navegação
class AppNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
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

/// Campo de input dinâmico
class AppTextField extends StatelessWidget {
  final String placeholder;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.placeholder,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      style: AppTextStyles.inputLabel,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 16),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
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
    return expanded ? SizedBox(width: double.infinity, height: 56, child: button) : button;
  }
}
