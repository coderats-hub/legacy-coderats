import 'package:flutter/material.dart';

enum BannerStyle { primary, secondary, tertiary }

/// Banner full-width (100%) com imagem ou degradê do tema.
class BannerHero extends StatelessWidget {
  final String? imageUrl;
  final BannerStyle style;
  final double height;
  final double radius;

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

    final gradientByStyle = <BannerStyle, List<Color>>{
      BannerStyle.primary: [cs.primary, cs.primaryContainer],
      BannerStyle.secondary: [cs.secondary, cs.secondaryContainer],
      BannerStyle.tertiary: [cs.tertiary, cs.tertiaryContainer],
    };

    final borderRadius = BorderRadius.circular(radius);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return SizedBox(
        width: double.infinity, // 100% da largura
        height: height,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(gradientByStyle, borderRadius),
          ),
        ),
      );
    }

    return _fallback(gradientByStyle, borderRadius);
  }

  Widget _fallback(Map<BannerStyle, List<Color>> map, BorderRadius radius) {
    return Container(
      width: double.infinity, // 100% da largura
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: map[style]!,
        ),
      ),
    );
  }
}
