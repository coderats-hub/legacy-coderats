/**
 * COMPONENTE DE AVATAR COM INFORMAÇÕES DO USUÁRIO
 * 
 * Widget reutilizável para exibir avatar + nome + subtítulo.
 * Usado em cards de feed, listas, etc.
 * 
 * Características:
 * - Avatar circular com cor primária
 * - Nome e subtítulo estilizados
 * - Tamanho do avatar configurável
 * - Opção de tornar clicável
 * - Opção de ocultar avatar
 */

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UserAvatarInfo extends StatelessWidget {
  final String label;
  final String subtitle;
  final double avatarRadius;
  final VoidCallback? onTap;
  final bool showAvatar;
  final String? imageUrl;
  
  const UserAvatarInfo({
    super.key,
    required this.label,
    required this.subtitle,
    this.avatarRadius = 18,
    this.onTap,
    this.showAvatar = true,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Row(
      children: [
        if (showAvatar) ...[
          CircleAvatar(
            radius: avatarRadius, 
            backgroundColor: AppColors.accent,
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
            child: imageUrl == null || imageUrl!.isEmpty
                ? null
                : null,
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
