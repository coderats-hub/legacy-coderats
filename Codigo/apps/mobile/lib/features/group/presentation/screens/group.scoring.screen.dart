import 'package:app/features/group/presentation/screens/group.list.screen.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';
import '../../../../shared/components/buttonPrimary.dart';

enum EvaluationMethod {
  photoStreak,
  commitStreak,
  commitCount,
  codeLines,
}

class ScoringModeGroupsScreen extends StatefulWidget {
  const ScoringModeGroupsScreen({super.key});

  @override
  State<ScoringModeGroupsScreen> createState() => _ScoringModeGroupsScreenState();
}

class _ScoringModeGroupsScreenState extends State<ScoringModeGroupsScreen> {
  EvaluationMethod? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Método Avaliativo',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Opção 1: Maior streak de fotos
                  _buildEvaluationOption(
                    iconPath: 'assets/icons/image.png',
                    title: 'Maior streak de fotos',
                    description: 'Usuário com maior frequência usando fotografias',
                    method: EvaluationMethod.photoStreak,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Opção 2: Maior streak de commits
                  _buildEvaluationOption(
                    iconPath: 'assets/icons/github.png',
                    title: 'Maior streak de commits',
                    description: 'Usuário com maior frequência usando commits',
                    method: EvaluationMethod.commitStreak,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Opção 3: Maior número de commits
                  _buildEvaluationOption(
                    iconPath: 'assets/icons/code.png',
                    title: 'Maior número de commits',
                    description: 'Usuário com maior números de commits acumulados',
                    method: EvaluationMethod.commitCount,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Opção 4: Maior número de linhas de código
                  _buildEvaluationOption(
                    iconPath: 'assets/icons/list.png',
                    title: 'Maior número de linhas de código',
                    description: 'Usuário com maior acumulo de linhas de código',
                    method: EvaluationMethod.codeLines,
                  ),
                ],
              ),
            ),
          ),
          
          // Botão Criar Grupo
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppButtonPrimary(
              type: AppButtonPrimaryType.secondary,
              text: 'Criar grupo',
              onPressed: _selectedMethod != null ? _createGroup : null,
              disabled: _selectedMethod == null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationOption({
    required String iconPath,
    required String title,
    required String description,
    required EvaluationMethod method,
  }) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Ícone
            SizedBox(
              width: 48,
              height: 48,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Image.asset(
                  iconPath,
                  width: 32,
                  height: 32,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Radio Button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textPrimary,
                  width: 2,
                ),
                color: isSelected ? AppColors.textPrimary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _createGroup() {
    if (_selectedMethod != null) {
      // TODO: Implementar lógica de criação do grupo com método selecionado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grupo criado com método: ${_getMethodName(_selectedMethod!)}'),
          backgroundColor: AppColors.accent,
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GroupsPage(),
        ),
      );
    }
  }

  String _getMethodName(EvaluationMethod method) {
    switch (method) {
      case EvaluationMethod.photoStreak:
        return 'Maior streak de fotos';
      case EvaluationMethod.commitStreak:
        return 'Maior streak de commits';
      case EvaluationMethod.commitCount:
        return 'Maior número de commits';
      case EvaluationMethod.codeLines:
        return 'Maior número de linhas de código';
    }
  }
}
