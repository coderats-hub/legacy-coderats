import 'package:flutter/material.dart';

enum AppButtonPrimaryType { primary, secondary, tertiary, error }

class AppButtonPrimary extends StatelessWidget {
  final AppButtonPrimaryType type;
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool disabled;

  const AppButtonPrimary({
    super.key,
    required this.type,
    required this.text,
    this.onPressed,
    this.icon,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Color background;
    Color foreground;

    switch (type) {
      case AppButtonPrimaryType.primary:
        background = colors.primary;
        foreground = colors.onPrimary;
        break;
      case AppButtonPrimaryType.secondary:
        background = colors.secondary;
        foreground = colors.onSecondary;
        break;
      case AppButtonPrimaryType.tertiary:
        background = colors.tertiary;
        foreground = colors.onTertiary;
        break;
      case AppButtonPrimaryType.error:
        background = colors.error;
        foreground = colors.onError;
        break;
    }

    if (disabled) {
      background = colors.surfaceVariant;
      foreground = colors.onSurfaceVariant;
    }

    return ElevatedButton.icon(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
      label: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
