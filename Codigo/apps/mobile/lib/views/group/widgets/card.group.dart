import 'package:flutter/material.dart';
import 'package:coderats/shared/theme/app_theme.dart';

enum BannerStyle { primary, secondary, tertiary }
enum GroupStatus { ativo, concluido }

class GroupCard extends StatefulWidget {
  final String title;
  final String? imageUrl;                 
  final BannerStyle bannerStyle;          
  final GroupStatus status;
  final Widget? expanded;                
  final EdgeInsets margin;

  final VoidCallback? onBannerTap;

  final ValueChanged<bool>? onExpandChanged;

  const GroupCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.bannerStyle = BannerStyle.tertiary,
    this.status = GroupStatus.ativo,
    this.expanded,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.onBannerTap,
    this.onExpandChanged,
  });

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  bool _open = false;

  void _toggle() {
    setState(() => _open = !_open);
    widget.onExpandChanged?.call(_open);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: widget.margin,
      child: Column(
        children: [
          InkWell(
            onTap: _toggle, // abre/fecha o acordeon
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grupo',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            )),
                        const SizedBox(height: 2),
                        Text(
                          widget.title, 
                          style: AppTextStyles.actionBoldWhite.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(status: widget.status),
                  const SizedBox(width: 6),
                  Icon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _BannerHero(
              imageUrl: widget.imageUrl,
              style: widget.bannerStyle,
              onTap: widget.onBannerTap,
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: widget.expanded ?? const SizedBox.shrink(),
            crossFadeState:
                _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final GroupStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isActive = status == GroupStatus.ativo;
    final bg = isActive ? AppColors.primary.withOpacity(0.2) : cs.error.withOpacity(.15);
    final fg = isActive ? AppColors.primary : cs.error;
    final label = isActive ? 'Ativo' : 'Concluído';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label, 
        style: AppTextStyles.descriptionWhite.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BannerHero extends StatelessWidget {
  final String? imageUrl;
  final BannerStyle style;
  final VoidCallback? onTap;

  const _BannerHero({
    required this.imageUrl,
    required this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(14);

    final gradientByStyle = <BannerStyle, List<Color>>{
      BannerStyle.primary: [cs.primary, cs.primaryContainer],
      BannerStyle.secondary: [cs.secondary, cs.secondaryContainer],
      BannerStyle.tertiary: [cs.tertiary, cs.tertiaryContainer],
    };

    Widget child;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final src = imageUrl!;
      final isNetwork = src.startsWith('http://') || src.startsWith('https://');
      final onError = (BuildContext _, Object __, StackTrace? ___) =>
          _gradient(radius, gradientByStyle[style]!);

      child = ClipRRect(
        borderRadius: radius,
        child: isNetwork
            ? Image.network(
                src,
                fit: BoxFit.cover,
                errorBuilder: onError,
              )
            : Image.asset(
                src,
                fit: BoxFit.cover,
                errorBuilder: onError,
              ),
      );
    } else {
      child = _gradient(radius, gradientByStyle[style]!);
    }

    return SizedBox(
      width: double.infinity, 
      height: 112,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap, // navega p/ detalhes
          child: child,
        ),
      ),
    );
  }

  Widget _gradient(BorderRadius radius, List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }
}
