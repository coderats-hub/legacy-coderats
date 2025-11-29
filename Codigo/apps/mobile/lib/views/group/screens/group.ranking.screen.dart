import 'package:flutter/material.dart';
import 'package:app/domain/group/group_participant.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'package:app/shared/utils/string_utils.dart';

class GroupRankingScreen extends StatelessWidget {
  final List<GroupParticipant> participants; 

  const GroupRankingScreen({
    super.key, 
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Ranking do Grupo',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: participants.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                itemCount: participants.length,
                separatorBuilder: (context, i) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final user = participants[index];
                  final position = index + 1; 

                  return _buildRankingCard(user, position);
                },
              ),
      ),
    );
  }

  Widget _buildRankingCard(GroupParticipant user, int position) {
    final pointsFormatted = user.points % 1 == 0 
        ? user.points.toInt().toString() 
        : user.points.toString();

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
            radius: 18,
            backgroundColor: _getPositionColor(position), 
            child: Text(
              position.toString(),
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.background,
            backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
            child: user.image == null 
                ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)) 
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringUtils.truncateName(user.name),
                  style: AppTextStyles.subtitle.copyWith(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$pointsFormatted pontos',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),

          // Troféus Especiais
          if (position == 1)
            const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28) // Ouro
          else if (position == 2)
            const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 28) // Prata
          else if (position == 3)
            const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 28) // Bronze
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            "Nenhum participante pontuou ainda.",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position == 1) return const Color(0xFFE0AA3E); 
    if (position == 2) return const Color(0xFF909090);
    if (position == 3) return const Color(0xFFA05934); 
    return AppColors.accent; 
  }
}