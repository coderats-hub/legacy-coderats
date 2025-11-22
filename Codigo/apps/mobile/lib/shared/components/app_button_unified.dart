import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';

enum AppButtonType { primary, secondary, tertiary, error, outlined }

class AppButtonUnified extends StatelessWidget {
  final AppButtonType type;
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool disabled;
  final bool expanded;
  final double? borderRadius;

  const AppButtonUnified({
    super.key,
    required this.type,
    required this.text,
    this.onPressed,
    this.icon,
    this.disabled = false,
    this.expanded = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Color background;
    Color foreground;
    BorderSide? border;

    switch (type) {
      case AppButtonType.primary:
        background = AppColors.primary;
        foreground = Colors.white;
        break;
      case AppButtonType.secondary:
        background = colors.secondary;
        foreground = colors.onSecondary;
        break;
      case AppButtonType.tertiary:
        background = colors.tertiary;
        foreground = colors.onTertiary;
        break;
      case AppButtonType.error:
        background = colors.error;
        foreground = colors.onError;
        break;
      case AppButtonType.outlined:
        background = Colors.transparent;
        foreground = AppColors.primary;
        border = BorderSide(color: AppColors.primary);
        break;
    }

    if (disabled) {
      background = colors.surfaceVariant;
      foreground = colors.onSurfaceVariant;
      border = null;
    }

    final button = ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        side: border,
        elevation: type == AppButtonType.outlined ? 0 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppCorners.sm),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTextStyles.button.copyWith(color: foreground),
          ),
        ],
      ),
    );

    return expanded 
        ? SizedBox(width: double.infinity, height: 48, child: button) 
        : button;
  }
}