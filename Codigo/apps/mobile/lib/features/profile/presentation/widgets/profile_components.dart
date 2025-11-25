/**
 * COMPONENTES REUTILIZÁVEIS DE PERFIL
 * 
 * Este arquivo contém widgets especializados para telas de perfil:
 * - ProfileHeader: Cabeçalho com avatar, nome e botão de ação
 * - ChipButton: Botão estilo chip para ações secundárias
 * 
 * Estes componentes são usados tanto no perfil público quanto privado,
 * garantindo consistência visual e reduzindo duplicação de código.
 * 
 * Funcionalidades:
 * - Header padronizado para perfis
 * - Botões de ação configuráveis
 * - Integração com sistema de tema
 */

import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/theme/app_theme_extended.dart';
import 'package:app/shared/components/components.dart';

// Cabeçalho padrão para telas de perfil (público e privado)
class ProfileHeader extends StatelessWidget {
  final String name;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar circular grande
        const AppAvatar(size: 96),
        const SizedBox(height: AppSpacing.sm),
        
        // Nome do usuário
        Text(
          name,
          style: AppTextStylesExtended.titleWhiteLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Botão de ação principal (ex: "Ver GitHub", "Seguir")
        ChipButton(
          label: actionLabel,
          icon: actionIcon,
          onPressed: onAction,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

// Botão estilo chip para ações secundárias
class ChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const ChipButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // Ação executada ao tocar
      child: Container(
        // Estilo visual do botão chip
        decoration: BoxDecoration(
          color: color,                                    // Cor de fundo
          borderRadius: BorderRadius.circular(AppCorners.lg), // Bordas arredondadas
          border: Border.all(color: color),                // Borda da mesma cor do fundo
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7), // Espaçamento interno
        child: Row(
          mainAxisSize: MainAxisSize.min, // Tamanho mínimo necessário
          children: [
            // Ícone à esquerda
            Icon(icon, size: 15, color: AppColorsExtended.white),
            const SizedBox(width: 6),
            // Texto do botão
            Text(
              label,
              style: AppTextStylesExtended.buttonWhite.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}