import 'package:flutter/material.dart';
import '../../domain/feed.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';

class FeedCard extends StatelessWidget {
  final FeedItem item;
  const FeedCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item.hasGithub) return _GithubCard(item: item);
    return _RegularCard(item: item);
  }
}

class _GithubCard extends StatelessWidget {
  final FeedItem item;
  const _GithubCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: UserAvatarInfo(
                  label: item.groupName,
                  subtitle: item.userName,
                  avatarRadius: 16,
                ),
              ),
              Text('${item.points} pts', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppCorners.lg),
              gradient: const LinearGradient(
                colors: [Color(0xFF6A00F4), Color(0xFF9B22FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abrir: ${item.githubUrl}')));
                },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A0B3C).withOpacity(0.9),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppCorners.lg)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text('Visualizar atividade Github', textAlign: TextAlign.center, style: AppTextStyles.button),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: Image.asset('assets/icons/github.png', width: 20, height: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // show title + description in one line (like regular check-ins)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: item.title, style: AppTextStyles.inputLabel.copyWith(fontSize: 14)),
                const TextSpan(text: ' '),
                TextSpan(text: item.description, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Há 2 dias', style: AppTextStyles.inputHint.copyWith(fontSize: 12)),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
        ],
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: UserAvatarInfo(
                  label: item.groupName,
                  subtitle: item.userName,
                  avatarRadius: 16,
                ),
              ),
              Text('${item.points} pts', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: item.title, style: AppTextStyles.inputLabel.copyWith(fontSize: 14)),
                TextSpan(text: ' '),
                TextSpan(text: item.description, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
        ],
      ),
    );
  }
}
