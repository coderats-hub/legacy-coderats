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
                    iconPath: 'assets/icons/image.png',
                    title: 'Maior streak de fotos',
                    description: 'Usuário com maior frequência usando fotografias',
                    method: EvaluationMethod.photoStreak,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),
                  
                  // Opção 2: Maior streak de commits
                  _buildEvaluationOption(
                    iconPath: 'assets/icons/github.png',
                    title: 'Maior streak de commits',
                    description: 'Usuário com maior frequência usando commits',
                    method: EvaluationMethod.commitStreak,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),
                  
                  // Opção 3: Maior número de commits
                  _buildEvaluationOption(
                    iconPath: 'assets/icons/maior.png',
                    title: 'Maior número de commits',
                    description: 'Usuário com maior números de commits acumulados',
                    method: EvaluationMethod.commitCount,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),
                  
                  // Opção 4: Maior número de linhas de código
                  _buildEvaluationOption(
                    iconPath: 'assets/icons/maior2.png',
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
    required String iconPath,
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
        child: Row(
          children: [
            // Ícone
            SizedBox(
              width: 48,
              height: 48,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  iconPath,
                  width: 32,
                  height: 32,
                  color: Colors.white,
                ),
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
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
                  color: Colors.white,
                  width: 2,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
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
