/**
 * Tela de Configuração de Pontuação do Grupo (ScoringModeGroupsScreen)
 * 
 * NAVEGAÇÃO: Segunda etapa da criação de grupos, vinda de group.create.screen.dart
 * 
 * FUNÇÃO:
 * - Configura método avaliativo para pontuação do grupo
 * - Permite escolher entre diferentes critérios de avaliação
 * - Define como os membros serão pontuados e ranqueados
 * - Finaliza processo de criação do grupo
 * 
 * MÉTODOS DISPONÍVEIS:
 * - Maior streak de fotos: Pontuação baseada na frequência de check-ins fotográficos
 * - Maior streak de commits: Pontuação baseada na consistência de commits no repositório
 * - (Futuros: Quantidade de commits, Linhas de código)
 * 
 * COMPONENTES:
 * - Cards de seleção para cada método avaliativo
 * - Campo opcional para repositório (quando aplicável)
 * - Botão de finalização que cria o grupo
 * 
 * FLUXO:
 * - Usuário seleciona método de pontuação
 * - Insere repositório se necessário (método de commits)
 * - Finaliza criação e volta para lista de grupos
 * 
 * NAVEGAÇÃO DE SAÍDA:
 * - Para lista de grupos → group.list.screen.dart (após criação bem-sucedida)
 * - Volta para criação básica ao cancelar
 */

import 'package:app/features/group/presentation/screens/group.list.screen.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';
import '../../../../shared/components/buttonPrimary.dart';

// Enum para métodos de avaliação disponíveis
enum EvaluationMethod {
  photoStreak,  // Streak de fotos/check-ins
  commitStreak, // Streak de commits no repositório
  //commitCount,  // Quantidade total de commits (futuro)
  //codeLines,    // Linhas de código escritas (futuro)
}

class ScoringModeGroupsScreen extends StatefulWidget {
  const ScoringModeGroupsScreen({super.key});

  @override
  State<ScoringModeGroupsScreen> createState() => _ScoringModeGroupsScreenState();
}

class _ScoringModeGroupsScreenState extends State<ScoringModeGroupsScreen> {
  EvaluationMethod? _selectedMethod; // Método de avaliação selecionado
  final _repositoryController = TextEditingController(); // Para URL do repositório
  
  @override
  void dispose() {
    _repositoryController.dispose(); // Evita memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Header com título e botão de voltar para etapa anterior
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
                  // Método 1: Avaliação por streak de fotos/check-ins
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
                  // const SizedBox(height: AppSpacing.md),
                  
                  // // Opção 3: Maior número de commits
                  // _buildEvaluationOption(
                  //   iconPath: 'assets/icons/code.png',
                  //   title: 'Maior número de commits',
                  //   description: 'Usuário com maior números de commits acumulados',
                  //   method: EvaluationMethod.commitCount,
                  // ),
                  // const SizedBox(height: AppSpacing.md),
                  
                  // // Opção 4: Maior número de linhas de código
                  // _buildEvaluationOption(
                  //   iconPath: 'assets/icons/list.png',
                  //   title: 'Maior número de linhas de código',
                  //   description: 'Usuário com maior acumulo de linhas de código',
                  //   method: EvaluationMethod.codeLines,
                  // ),
                  
                  // Campo de repositório (só aparece se commit streak for selecionado)
                  if (_selectedMethod == EvaluationMethod.commitStreak) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Adicionar repositório',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _repositoryController,
                          style: AppTextStyles.inputLabel,
                          decoration: InputDecoration(
                            hintText: 'Adicionar link do repositório do grupo',
                            hintStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFACACAC),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppCorners.md),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppCorners.md),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppCorners.md),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedMethod != null ? AppColors.primary : AppColors.textDisabled,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppCorners.md),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _selectedMethod != null ? _createGroup : null,
                      child: const Text(
                        'Criar grupo',
                        style: AppTextStyles.headlineBold16White,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg), 
        child: Row(
          children: [
            // Ícone
            SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  iconPath,
                  width: 28,
                  height: 28,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Conteúdo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Radio Button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
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
      // Validação: Se for commit streak, repositório é obrigatório
      if (_selectedMethod == EvaluationMethod.commitStreak && _repositoryController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, adicione o link do repositório'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // TODO: Implementar lógica de criação do grupo com método selecionado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grupo criado com método: ${_getMethodName(_selectedMethod!)}'),
          backgroundColor: AppColors.primary,
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
      //case EvaluationMethod.commitCount:
        //return 'Maior número de commits';
      //case EvaluationMethod.codeLines:
        //return 'Maior número de linhas de código';
    }
  }
}
