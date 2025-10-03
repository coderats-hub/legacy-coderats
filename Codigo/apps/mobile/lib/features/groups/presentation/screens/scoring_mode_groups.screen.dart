import 'package:flutter/material.dart';
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        titleSpacing: 8,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Método Avaliativo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Opção 1: Maior streak de fotos
                  _buildEvaluationOption(
                    icon: Icons.photo_library_outlined,
                    title: 'Maior streak de fotos',
                    description: 'Usuário com maior frequência usando fotografias',
                    method: EvaluationMethod.photoStreak,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),
                  
                  // Opção 2: Maior streak de commits
                  _buildEvaluationOption(
                    icon: Icons.code,
                    title: 'Maior streak de commits',
                    description: 'Usuário com maior frequência usando commits',
                    method: EvaluationMethod.commitStreak,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),
                  
                  // Opção 3: Maior número de commits
                  _buildEvaluationOption(
                    icon: Icons.integration_instructions,
                    title: 'Maior número de commits',
                    description: 'Usuário com maior números de commits acumulados',
                    method: EvaluationMethod.commitCount,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),
                  
                  // Opção 4: Maior número de linhas de código
                  _buildEvaluationOption(
                    icon: Icons.code_off,
                    title: 'Maior número de linhas de código',
                    description: 'Usuário com maior acumulo de linhas de código',
                    method: EvaluationMethod.codeLines,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ),
          ),
          
          // Botão Criar Grupo
          Container(
            padding: const EdgeInsets.all(24),
            child:             AppButtonPrimary(
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
    required IconData icon,
    required String title,
    required String description,
    required EvaluationMethod method,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? colors.primary.withOpacity(0.2) : colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
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
                  color: isSelected ? colors.primary : colors.outline,
                  width: 2,
                ),
                color: isSelected ? colors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: colors.onPrimary,
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
      final colors = Theme.of(context).colorScheme;
      
      // TODO: Implementar lógica de criação do grupo com método selecionado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grupo criado com método: ${_getMethodName(_selectedMethod!)}'),
          backgroundColor: colors.secondary,
        ),
      );
      
      // Navegar de volta para a tela inicial ou para uma tela de sucesso
      Navigator.of(context).popUntil((route) => route.isFirst);
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
