import 'package:flutter/material.dart';
import '../../domain/feed.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'github_activity_modal.dart';

class FeedCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onLike;
  final bool isLikeLoading;
  
  const FeedCard({
    Key? key, 
    required this.item,
    this.onLike,
    this.isLikeLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item.hasGithub) {
      return _GithubCard(
        item: item, 
        onLike: onLike,
        isLikeLoading: isLikeLoading,
      );
    }
    return _RegularCard(
      item: item, 
      onLike: onLike,
      isLikeLoading: isLikeLoading,
    );
  }
}

class _GithubCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onLike;
  final bool isLikeLoading;
  
  const _GithubCard({
    required this.item,
    this.onLike,
    this.isLikeLoading = false,
  });

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
                  label: item.author.name,
                  subtitle: '@${item.author.githubUser}',
                  avatarRadius: 16,
                  imageUrl: item.author.image,
                ),
              ),
              Text('${item.points} pts', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Botão de like mais proeminente
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LikeButton(
                likesCount: item.likesCount,
                isLiked: item.userHasLiked,
                onTap: onLike,
                isLoading: isLikeLoading,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppCorners.lg),
              gradient: _getGradient(),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  GitHubActivityModal.show(
                    context,
                    title: item.title,
                    description: item.cleanDescription,
                    summaryAi: item.summaryAi,
                    commits: item.commits,
                  );
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
                      const Expanded(
                        child: Text('Visualizar atividade Github', textAlign: TextAlign.center, style: AppTextStyles.button),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: AppSpacing.sm),
                        child: const Icon(Icons.code, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Título em negrito
          Text(
            item.title,
            style: AppTextStyles.inputLabel.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          // Descrição limpa (sem commits)
          if (item.cleanDescription != null && item.cleanDescription!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.cleanDescription!,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          
          const SizedBox(height: AppSpacing.sm),
          
          // Footer com commits e data
          Row(
            children: [
              Icon(
                Icons.commit,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.commitsCount} ${item.commitsCount == 1 ? 'commit' : 'commits'}',
                style: AppTextStyles.inputHint.copyWith(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(item.createdAt),
                style: AppTextStyles.inputHint.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
        ],
      ),
    );
  }

  // Lista de gradientes roxos diferentes
  static const List<List<Color>> _purpleGradients = [
    [Color(0xFF6A00F4), Color(0xFF9B22FF)], // Roxo escuro para roxo médio
    [Color(0xFF8B5CF6), Color(0xFFC084FC)], // Roxo médio para roxo claro
    [Color(0xFF9333EA), Color(0xFFD946EF)], // Roxo vibrante para rosa roxo
    [Color(0xFF7C3AED), Color(0xFFA78BFA)], // Roxo índigo para lavanda
    [Color(0xFF6366F1), Color(0xFF9B22FF)], // Azul roxo para roxo
    [Color(0xFF8B5CF6), Color(0xFFEC4899)], // Roxo para rosa
  ];

  // Seleciona um gradiente baseado no ID do item
  LinearGradient _getGradient() {
    final hash = item.id.hashCode.abs();
    final colors = _purpleGradients[hash % _purpleGradients.length];
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class _RegularCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onLike;
  final bool isLikeLoading;
  
  const _RegularCard({
    required this.item,
    this.onLike,
    this.isLikeLoading = false,
  });

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
                  label: item.author.name,
                  subtitle: '@${item.author.githubUser}',
                  avatarRadius: 16,
                  imageUrl: item.author.image,
                ),
              ),
              Text('${item.points} pts', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Botão de like mais proeminente
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LikeButton(
                likesCount: item.likesCount,
                isLiked: item.userHasLiked,
                onTap: onLike,
                isLoading: isLikeLoading,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: item.title, style: AppTextStyles.inputLabel.copyWith(fontSize: 14)),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const TextSpan(text: ' '),
                  TextSpan(text: item.description!, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(_formatDate(item.createdAt), style: AppTextStyles.inputHint.copyWith(fontSize: 12)),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
        ],
      ),
    );
  }
}

// Widget de botão de like
class _LikeButton extends StatelessWidget {
  final int likesCount;
  final bool isLiked;
  final VoidCallback? onTap;
  final bool isLoading;

  const _LikeButton({
    required this.likesCount,
    required this.isLiked,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textSecondary,
              ),
            )
          else
            Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : AppColors.textSecondary,
              size: 18,
            ),
          const SizedBox(width: 4),
          Text(
            likesCount.toString(),
            style: AppTextStyles.inputHint.copyWith(
              fontSize: 12,
              color: isLiked ? Colors.red : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 30) {
    return 'Há ${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'mês' : 'meses'}';
  } else if (difference.inDays > 0) {
    return 'Há ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
  } else if (difference.inHours > 0) {
    return 'Há ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
  } else if (difference.inMinutes > 0) {
    return 'Há ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
  } else {
    return 'Agora mesmo';
  }
}
