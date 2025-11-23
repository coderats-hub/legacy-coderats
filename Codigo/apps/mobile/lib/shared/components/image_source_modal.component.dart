/**
 * COMPONENTE MODAL DE SELEÇÃO DE FONTE DE IMAGEM
 * 
 * Modal padronizado para escolher entre galeria e câmera
 * para seleção de imagens em toda a aplicação.
 * 
 * Retorna String em vez de ImageSource devido à remoção
 * do plugin ImagePicker para resolver conflitos Android SDK.
 */

import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';

class ImageSourceModal {
  /// Exibe modal para escolher fonte da imagem (galeria ou câmera)
  /// 
  /// Retorna:
  /// - 'gallery' se usuário escolher galeria
  /// - 'camera' se usuário escolher câmera  
  /// - null se usuário cancelar
  static Future<String?> show(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppCorners.lg),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador visual do modal
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Título do modal
                Text(
                  'Selecionar imagem',
                  style: AppTextStyles.inputLabel.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Opção Galeria
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppCorners.sm),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Galeria',
                    style: AppTextStyles.inputLabel,
                  ),
                  subtitle: Text(
                    'Escolher da galeria de fotos',
                    style: AppTextStyles.subtitle,
                  ),
                  onTap: () => Navigator.of(ctx).pop('gallery'),
                ),
                
                // Opção Câmera
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppCorners.sm),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Câmera',
                    style: AppTextStyles.inputLabel,
                  ),
                  subtitle: Text(
                    'Tirar uma nova foto',
                    style: AppTextStyles.subtitle,
                  ),
                  onTap: () => Navigator.of(ctx).pop('camera'),
                ),
                
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }
}