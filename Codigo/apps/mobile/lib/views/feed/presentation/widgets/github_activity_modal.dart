import 'package:flutter/material.dart';
import 'package:coderats/shared/theme/app_theme.dart';

class GitHubActivityModal extends StatelessWidget {
  final String title;
  final String? description;
  final String? summaryAi;
  final List<String> commits;

  const GitHubActivityModal({
    Key? key,
    required this.title,
    this.description,
    this.summaryAi,
    required this.commits,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? description,
    String? summaryAi,
    required List<String> commits,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GitHubActivityModal(
        title: title,
        description: description,
        summaryAi: summaryAi,
        commits: commits,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(AppSpacing.lg),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? 320 : 400,
          maxHeight: isSmallScreen ? 450 : 500,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(AppCorners.lg),
        ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header com título e botão fechar
              Container(
                padding: EdgeInsets.all(isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.title.copyWith(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Conteúdo scrollável
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Descrição do commit
                      if (description != null && description!.isNotEmpty) ...[
                        Text(
                          'Descrição',
                          style: AppTextStyles.inputLabel.copyWith(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? AppSpacing.sm : AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(AppCorners.md),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            description!,
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                      ],

                      // Resumo da IA
                      if (summaryAi != null && summaryAi!.isNotEmpty) ...[
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? AppSpacing.xs : AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A00F4), Color(0xFF9B22FF)],
                              ),
                              borderRadius: BorderRadius.circular(AppCorners.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Resumo IA',
                                  style: AppTextStyles.inputLabel.copyWith(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isSmallScreen ? double.infinity : 400,
                            ),
                            padding: EdgeInsets.all(isSmallScreen ? AppSpacing.sm : AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppCorners.md),
                              border: Border.all(
                                color: const Color(0xFF6A00F4).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              summaryAi!,
                              style: AppTextStyles.subtitle.copyWith(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                      ],

                      // Lista de commits
                      if (commits.isNotEmpty) ...[
                        Text(
                          'Commits (${commits.length})',
                          style: AppTextStyles.inputLabel.copyWith(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
                        Column(
                          children: commits.map((commit) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: isSmallScreen ? AppSpacing.xs : AppSpacing.sm,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: isSmallScreen ? 4 : 6,
                                    height: isSmallScreen ? 4 : 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      commit,
                                      style: AppTextStyles.subtitle.copyWith(
                                        fontSize: isSmallScreen ? 12 : 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
