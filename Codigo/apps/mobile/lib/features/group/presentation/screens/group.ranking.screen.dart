import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';

class GroupRankingScreen extends StatelessWidget {
  final List<UserRanking>? rankings;
  GroupRankingScreen({super.key, this.rankings});

  @override
  Widget build(BuildContext context) {
    final rankingList = rankings ?? sampleRanking;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Ranking do Grupo',
          style: AppTextStyles.title,
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          itemCount: rankingList.length,
          separatorBuilder: (context, i) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) {
            final user = rankingList[i];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppCorners.md),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Text(
                      user.position.toString(),
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${user.points} pontos',
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ícone de troféu para top 3
                  if (user.position == 1)
                    const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28)
                  else if (user.position == 2)
                    const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 28)
                  else if (user.position == 3)
                    const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 28)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserRanking {
  final int position;
  final String name;
  final double points;
  UserRanking({required this.position, required this.name, required this.points});
}

final List<UserRanking> sampleRanking = [
  UserRanking(position: 1, name: 'Alice', points: 49.5),
  UserRanking(position: 2, name: 'Felipe', points: 45.5),
  UserRanking(position: 3, name: 'Gustavo', points: 45.5),
  UserRanking(position: 4, name: 'Bruna', points: 40.0),
  UserRanking(position: 5, name: 'Lucas', points: 38.0),
  UserRanking(position: 6, name: 'Marina', points: 35.0),
  UserRanking(position: 7, name: 'João', points: 30.0),
  UserRanking(position: 8, name: 'Paula', points: 28.0),
  UserRanking(position: 9, name: 'Rafael', points: 25.0),
  UserRanking(position: 10, name: 'Carla', points: 20.0),
];
