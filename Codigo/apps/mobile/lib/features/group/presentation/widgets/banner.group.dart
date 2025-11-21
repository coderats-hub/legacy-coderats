/**
 * WIDGET DE BANNER PARA GRUPOS
 * 
 * Componente reutilizável para exibir banners de grupos com:
 * - Imagem personalizada (quando disponível) 
 * - Gradientes temáticos como fallback
 * - Estilos predefinidos (primary, secondary, tertiary)
 * - Tamanho e radius configuráveis
 * 
 * Usado em:
 * - Cards de grupos (GroupCard)
 * - Tela de detalhes do grupo (GroupDetailPage)
 * - Tela de edição do grupo (GroupEditScreen)
 * 
 * Características:
 * - Full-width (100% da largura do container)
 * - Fallback automático para gradiente se imagem falhar
 * - BorderRadius configurável
 * - Integração com tema do Material Design
 */

import 'package:flutter/material.dart';

// Enum para diferentes estilos de gradiente do banner
enum BannerStyle { primary, secondary, tertiary }

// Widget de banner full-width com imagem ou gradiente temático
class BannerHero extends StatelessWidget {
  final String? imageUrl;    // URL da imagem (opcional)
  final BannerStyle style;   // Estilo do gradiente de fallback
  final double height;       // Altura do banner (padrão: 112)
  final double radius;       // Raio das bordas (padrão: 14)

  const BannerHero({
    super.key,
    required this.imageUrl,
    required this.style,
    this.height = 112,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Mapeamento de estilos para cores do gradiente
    final gradientByStyle = <BannerStyle, List<Color>>{
      BannerStyle.primary: [cs.primary, cs.primaryContainer],
      BannerStyle.secondary: [cs.secondary, cs.secondaryContainer],
      BannerStyle.tertiary: [cs.tertiary, cs.tertiaryContainer],
    };

    final borderRadius = BorderRadius.circular(radius);

    // Se há URL de imagem, tenta carregá-la
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return SizedBox(
        width: double.infinity, // 100% da largura
        height: height,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            // Em caso de erro, usa gradiente como fallback
            errorBuilder: (_, __, ___) => _fallback(gradientByStyle, borderRadius),
          ),
        ),
      );
    }

    // Sem imagem, usa gradiente diretamente
    return _fallback(gradientByStyle, borderRadius);
  }

  // Widget de fallback com gradiente baseado no estilo escolhido
  Widget _fallback(Map<BannerStyle, List<Color>> map, BorderRadius radius) {
    return Container(
      width: double.infinity, // 100% da largura
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: map[style]!, // Cores baseadas no BannerStyle
        ),
      ),
    );
  }
}
