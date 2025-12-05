import 'package:flutter/material.dart';
import 'package:coderats/shared/theme/app_theme.dart';

/// Dialog de confirmação reutilizável para ações destrutivas ou importantes.
/// 
/// Uso:
/// ```dart
/// showConfirmationDialog(
///   context: context,
///   title: 'Excluir grupo?',
///   icon: Icons.warning_amber_rounded,
///   iconColor: AppColors.error,
///   description: 'Esta ação não pode ser desfeita.',
///   details: 'O grupo será marcado como inativo...',
///   confirmText: 'Excluir',
///   confirmColor: AppColors.error,
///   onConfirm: () => _deleteGroup(),
/// );
/// ```
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  IconData? icon,
  Color? iconColor,
  required String description,
  String? details,
  String confirmText = 'Confirmar',
  Color confirmColor = AppColors.primary,
  String cancelText = 'Cancelar',
  VoidCallback? onConfirm,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.lg),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? AppColors.primary, size: 28),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details,
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              cancelText,
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
              onConfirm?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppCorners.md),
              ),
            ),
            child: Text(confirmText, style: AppTextStyles.button),
          ),
        ],
      );
    },
  );
}
