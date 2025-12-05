/**
 * COMPONENTE DE AVATAR PERSONALIZADO
 * 
 * Widget reutilizável para exibir avatares de usuário em toda a aplicação.
 * Características:
 * - Tamanho configurável
 * - Cor de fundo customizável
 * - Ícone padrão ou personalizado
 * - Widget filho personalizado (para imagens reais no futuro)
 * - Design circular consistente
 * 
 * Usado em:
 * - Perfis de usuário
 * - Lista de check-ins
 * - Cards de usuário
 * - Headers de tela
 */

import 'package:flutter/material.dart';
import 'package:coderats/shared/theme/app_theme.dart';

// Widget de avatar circular customizável para usuários
class AppAvatar extends StatelessWidget {
  final double size;              // Tamanho do avatar (largura e altura)
  final Widget? child;            // Widget filho customizado (ex: imagem real)
  final Color? backgroundColor;   // Cor de fundo (opcional)
  final IconData? icon;          // Ícone a ser exibido (opcional)
  final double? iconSize;        // Tamanho do ícone (opcional)

  const AppAvatar({
    super.key,
    required this.size,
    this.child,
    this.backgroundColor,
    this.icon,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Cor de fundo padrão ou personalizada
        color: backgroundColor ?? AppColors.surface,
        shape: BoxShape.circle, // Sempre circular
      ),
      child: child ??  // Se não há widget filho personalizado, usa ícone padrão
        Center(
          child: Icon(
            icon ?? Icons.person,  // Ícone padrão de pessoa
            color: Colors.white,   // Cor branca para contraste
            size: iconSize ?? size * 0.5, // Tamanho do ícone (50% do avatar por padrão)
          ),
        ),
    );
  }
}
