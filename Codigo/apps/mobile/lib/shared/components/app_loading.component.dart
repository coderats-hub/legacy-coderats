/**
 * COMPONENTE DE LOADING PADRONIZADO
 * 
 * Loading spinner consistente em toda a aplicação.
 * Sempre utiliza a cor primária (verde) do tema.
 * Por padrão, é exibido centralizado na tela.
 */

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLoading extends StatelessWidget {
  final double? size;
  final double? strokeWidth;
  
  const AppLoading({
    super.key,
    this.size,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      strokeWidth: strokeWidth ?? 4.0,
    );
    
    // Se tem tamanho específico, não centraliza
    if (size != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: indicator),
      );
    }
    
    // Sempre retorna centralizado
    return Center(child: indicator);
  }
}
