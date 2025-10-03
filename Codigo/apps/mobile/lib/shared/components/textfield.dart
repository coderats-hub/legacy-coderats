import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final bool required;
  final bool enabled;
  final IconData? icon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.required = false,
    this.enabled = true,
    this.icon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
            children: required
                ? [
                    TextSpan(
                      text: ' *',
                      style: textTheme.bodyMedium?.copyWith(color: colors.error),
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon != null ? Icon(icon, color: colors.onSurfaceVariant) : null,
            filled: true,
            fillColor: enabled ? colors.surfaceVariant : colors.surface.withOpacity(0.6),
            hintStyle: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
