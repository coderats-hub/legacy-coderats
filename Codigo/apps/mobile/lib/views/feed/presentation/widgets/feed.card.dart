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
    void openDetail() => _showDetail(context, item);

    if (item.hasGithub) {
      return _GithubCard(
        item: item, 
        onLike: onLike,
        isLikeLoading: isLikeLoading,
        onOpen: openDetail,
      );
    }
    return _RegularCard(
      item: item, 
      onLike: onLike,
      isLikeLoading: isLikeLoading,
      onOpen: openDetail,
    );
  }

  void _showDetail(BuildContext context, FeedItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _FeedDetailModal(item: item),
    );
  }
}

class _GithubCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onLike;
  final bool isLikeLoading;
  final VoidCallback onOpen;
  
  const _GithubCard({
    required this.item,
    this.onLike,
    this.isLikeLoading = false,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: UserAvatarInfo(
                    label: item.author.name,
                    subtitle: _formatDate(item.createdAt),
                    avatarRadius: 16,
                    imageUrl: item.author.image,
                  ),
                ),
                Text('${item.points} pts', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _MediaPreview(
              imageUrl: item.image,
              fallbackGradient: _getGradient(),
              cta: _GithubCTA(
                onTap: () {
                  GitHubActivityModal.show(
                    context,
                    title: item.title,
                    description: item.cleanDescription,
                    summaryAi: item.summaryAi,
                    commits: item.commits,
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.title,
              style: AppTextStyles.inputLabel.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (item.cleanDescription != null && item.cleanDescription!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.cleanDescription!,
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (item.commits.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.commit, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Commits (${item.commitsCount})',
                    style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _LikeButton(
                  likesCount: item.likesCount,
                  isLiked: item.userHasLiked,
                  onTap: onLike,
                  isLoading: isLikeLoading,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.border),
          ],
        ),
      ),
    );
  }

  static const List<List<Color>> _purpleGradients = [
    [Color(0xFF6A00F4), Color(0xFF9B22FF)],
    [Color(0xFF8B5CF6), Color(0xFFC084FC)],
    [Color(0xFF9333EA), Color(0xFFD946EF)],
    [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    [Color(0xFF6366F1), Color(0xFF9B22FF)],
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  ];

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
  final VoidCallback onOpen;
  
  const _RegularCard({
    required this.item,
    this.onLike,
    this.isLikeLoading = false,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: UserAvatarInfo(
                    label: item.author.name,
                    subtitle: _formatDate(item.createdAt),
                    avatarRadius: 16,
                    imageUrl: item.author.image,
                  ),
                ),
                Text('${item.points} pts', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (item.image != null && item.image!.isNotEmpty) ...[
              _MediaPreview(
                imageUrl: item.image,
                fallbackGradient: null,
                cta: null,
                height: 200,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(
              item.title,
              style: AppTextStyles.inputLabel.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.description!,
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _LikeButton(
                  likesCount: item.likesCount,
                  isLiked: item.userHasLiked,
                  onTap: onLike,
                  isLoading: isLikeLoading,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.border),
          ],
        ),
      ),
    );
  }
}

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

class _MediaPreview extends StatelessWidget {
  final String? imageUrl;
  final Gradient? fallbackGradient;
  final Widget? cta;
  final double height;

  const _MediaPreview({
    this.imageUrl,
    this.fallbackGradient,
    this.cta,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppCorners.lg),
      child: Stack(
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(decoration: BoxDecoration(gradient: fallbackGradient));
                    },
                  )
                : Container(decoration: BoxDecoration(gradient: fallbackGradient)),
          ),
          if (cta != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: cta!,
            ),
        ],
      ),
    );
  }
}

class _GithubCTA extends StatelessWidget {
  final VoidCallback onTap;
  const _GithubCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

class _FeedDetailModal extends StatelessWidget {
  final FeedItem item;
  const _FeedDetailModal({required this.item});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = MediaQuery.of(context).size.width < 600;
    final commits = item.commits;
    final hasGithub = item.summaryAi != null && item.summaryAi!.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppSpacing.md : AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isSmall ? double.infinity : 520,
          maxHeight: screenHeight * 0.9,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(AppCorners.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(isSmall ? AppSpacing.md : AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.title.copyWith(
                          fontSize: isSmall ? 16 : 18,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              if (item.image != null && item.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppCorners.lg),
                  child: Image.network(
                    item.image!,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 240,
                      color: AppColors.border,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmall ? AppSpacing.md : AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: isSmall ? 18 : 20,
                            backgroundColor: AppColors.primary,
                            backgroundImage: item.author.image != null && item.author.image!.isNotEmpty
                                ? NetworkImage(item.author.image!)
                                : null,
                            child: item.author.image == null || item.author.image!.isEmpty
                                ? Text(
                                    item.author.name.isNotEmpty ? item.author.name[0].toUpperCase() : '?',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isSmall ? 14 : 16),
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.author.name, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
                                Text(_formatDate(item.createdAt), style: AppTextStyles.inputHint.copyWith(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppCorners.sm),
                              border: Border.all(color: AppColors.primary, width: 1),
                            ),
                            child: Text(
                              '${item.points} pts',
                              style: AppTextStyles.inputLabel.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (item.cleanDescription != null && item.cleanDescription!.isNotEmpty) ...[
                        Text('Descrição', style: AppTextStyles.inputLabel.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.background.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(AppCorners.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            item.cleanDescription!,
                            style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (hasGithub) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF6A00F4), Color(0xFF9B22FF)]),
                                borderRadius: BorderRadius.circular(AppCorners.sm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text('Resumo IA', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppCorners.md),
                            border: Border.all(color: const Color(0xFF6A00F4).withOpacity(0.3), width: 1),
                          ),
                          child: Text(
                            item.summaryAi ?? '',
                            style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (commits.isNotEmpty) ...[
                        Text('Commits (${commits.length})', style: AppTextStyles.inputLabel.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: AppSpacing.sm),
                        ...commits.asMap().entries.map((entry) {
                          final commit = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.background.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppCorners.sm),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    commit,
                                    style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
