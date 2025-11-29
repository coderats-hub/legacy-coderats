/**
 * COMPONENTE DE CAMPO DE TEXTO PADRONIZADO
 * 
 * TextField customizado usado em toda a aplicação.
 * Características:
 * - Label opcional com indicador de campo obrigatório
 * - Placeholder personalizado
 * - Validação
 * - Suporte a senha (obscureText)
 * - Múltiplas linhas
 * - Callback onChange
 */

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
  final void Function(String)? onChanged;      // Callback quando texto muda

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
    this.onChanged,
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
          onChanged: onChanged,
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
