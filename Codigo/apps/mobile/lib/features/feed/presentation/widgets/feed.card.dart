// ==============================
// Arquivo: features/feed/presentation/widgets/feed.card.dart
// ==============================
// Widget template para exibir um item do feed.

import 'package:flutter/material.dart';
import '../../domain/feed.dart';
import 'package:app/shared/theme/app_theme.dart';

class FeedCard extends StatelessWidget {
  final FeedItem item;
  const FeedCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Two visual variants: github (hero card with gradient + button) and regular
    if (item.hasGithub) {
      return _GithubCard(item: item);
    }
    return _RegularCard(item: item);
  }
}

class _GithubCard extends StatelessWidget {
  final FeedItem item;
  const _GithubCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppCorners.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // big purple hero
            Container(
              height: 160,
              margin: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppCorners.lg),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A00F4), Color(0xFF9B22FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 16, backgroundColor: AppColors.border),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.author, style: AppTextStyles.title.copyWith(fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(item.title, style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
                          ],
                        ),
                      ),
                      Text('${item.points} pts', style: AppTextStyles.subtitle),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            // abrir URL externamente em app real; aqui apenas placeholder
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Abrir: \\${item.githubUrl}')),
                            );
                          },
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Visualizar atividade Github'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.favorite_border, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text('${item.likes}', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(width: AppSpacing.md),
                      Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text('${item.comments}', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegularCard extends StatelessWidget {
  final FeedItem item;
  const _RegularCard({required this.item});

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
            const CircleAvatar(radius: 18, backgroundColor: AppColors.border),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.title.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(item.description, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: AppSpacing.xs),
                      Text('${item.likes}', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(width: AppSpacing.md),
                      Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: AppSpacing.xs),
                      Text('${item.comments}', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Text('${item.points} pnts', style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
