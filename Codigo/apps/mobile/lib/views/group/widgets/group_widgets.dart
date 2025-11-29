import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/domain/checkin/checkin.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/utils/string_utils.dart';

class CheckinTile extends StatelessWidget {
  final Checkin c;
  const CheckinTile({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppCorners.md),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
              child: c.author.image != null 
                  ? ClipOval(child: Image.network(c.author.image!, fit: BoxFit.cover))
                  : Center(child: Text(c.author.name.isNotEmpty ? c.author.name[0] : '?', style: const TextStyle(color: Colors.white))),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, 
                      style: AppTextStyles.title.copyWith(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle)),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(c.author.name, 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("+${c.points}", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. HEADER DE DATA ---
class DayHeader extends StatelessWidget {
  final DateTime date;
  const DayHeader({super.key, required this.date});
  
  @override
  Widget build(BuildContext context) {
    final formatted = "${date.day.toString().padLeft(2, '0')} de ${_monthName(date.month)}";
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xs),
      child: Text(formatted, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
    );
  }
  String _monthName(int m) => ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'][m - 1];
}

class DescriptionAccordion extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;
  final Widget child;
  const DescriptionAccordion({super.key, required this.open, required this.onToggle, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppCorners.sm),
            child: Row(
              children: [
                Expanded(child: Text('Ver Descrição', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary))),
                Icon(open ? Icons.expand_less : Icons.expand_more, color: AppColors.textSecondary),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: child),
            crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class RankingTile extends StatelessWidget {
  final String name;
  final String points;
  final String pos;
  final String? imageUrl;
  const RankingTile({super.key, required this.name, required this.points, required this.pos, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface.withOpacity(.3), borderRadius: BorderRadius.circular(AppCorners.md)),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18, 
                  backgroundColor: AppColors.border,
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                  child: imageUrl == null ? Text(name.isNotEmpty ? name[0] : '?') : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(points, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          Text(pos, style: AppTextStyles.title.copyWith(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}

class GroupCodeWidget extends StatefulWidget {
  final String code;
  const GroupCodeWidget({super.key, required this.code});

  @override
  State<GroupCodeWidget> createState() => _GroupCodeWidgetState();
}

class _GroupCodeWidgetState extends State<GroupCodeWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: widget.code));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código copiado!'), duration: Duration(seconds: 1)),
          );
        }
      },
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFF7DCDC1).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppCorners.sm),
            border: Border.all(color: const Color(0xFF7DCDC1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.copy_all_rounded, size: 18, color: Color(0xFF7DCDC1)),
              const SizedBox(width: 8),
              Text(
                'Código: ${widget.code}', 
                style: AppTextStyles.subtitle.copyWith(color: const Color(0xFF7DCDC1), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RankingChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const RankingChip({super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withOpacity(0.2),
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(label, style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 11)),
        ),
      ),
    );
  }
}