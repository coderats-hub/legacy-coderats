import 'package:coderats/repositories/group.repository.dart';
import 'package:coderats/services/http_client.dart';
import 'package:coderats/services/local_database.dart';
import 'package:flutter/material.dart';
import 'package:coderats/shared/theme/app_theme.dart';
import 'package:coderats/shared/components/components.dart';

import 'package:coderats/domain/group/group.dart';
import 'package:coderats/database/group/group.dao.dart';
import 'package:coderats/services/group/group_remote_service.dart';
import 'package:coderats/core/session_manager.dart';
import 'package:coderats/services/connectivity_service.dart';
import 'package:coderats/views/group/screens/group.list.screen.dart'; 
import 'package:coderats/services/user/user_remote_service.dart';

enum EvaluationMethod {
  photoStreak,
  commitStreak,
}

class ScoringModeGroupsScreen extends StatefulWidget {
  final String name;
  final String? description;
  final String? image;
  final DateTime startDate;
  final DateTime endDate;

  const ScoringModeGroupsScreen({
    super.key,
    required this.name,
    this.description,
    this.image,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ScoringModeGroupsScreen> createState() => _ScoringModeGroupsScreenState();
}

class _ScoringModeGroupsScreenState extends State<ScoringModeGroupsScreen> {
  EvaluationMethod? _selectedMethod;
  final _repositoryController = TextEditingController();
  
  // Estado de carregamento para o botão
  bool _isLoading = false;

  @override
  void dispose() {
    _repositoryController.dispose();
    super.dispose();
  }

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
                  _buildEvaluationOption(
                    iconPath: 'assets/icons/image.png',
                    title: 'Maior streak de fotos',
                    description: 'Usuário com maior frequência usando fotografias',
                    method: EvaluationMethod.photoStreak,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildEvaluationOption(
                    iconPath: 'assets/icons/github.png',
                    title: 'Maior streak de commits',
                    description: 'Usuário com maior frequência usando commits',
                    method: EvaluationMethod.commitStreak,
                  ),
                  
                  // Campo condicional: Só aparece se for Commit Streak
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
                            hintText: 'https://github.com/usuario/repo',
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
                  
                  // Botão de Criar com Loading
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedMethod != null 
                            ? AppColors.primary 
                            : AppColors.textDisabled,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppCorners.md),
                        ),
                        elevation: 0,
                      ),
                      // Desabilita o botão se estiver carregando ou sem método selecionado
                      onPressed: (_selectedMethod != null && !_isLoading) 
                          ? _createGroup 
                          : null,
                      child: _isLoading 
                          ? const SizedBox(
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
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
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppCorners.md),
          border: isSelected ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
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
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // --- LÓGICA DE CRIAÇÃO ---

  Future<void> _createGroup() async {
    // 1. Validação Final
    if (_selectedMethod == EvaluationMethod.commitStreak && 
        _repositoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, adicione o link do repositório'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Montagem de Dependências (Idealmente usar Injeção de Dependência como GetIt/Modular)
      // Aqui estamos montando manualmente baseado nos seus códigos anteriores:
      final session = SessionManager.instance;
      final localDb = await LocalDatabase.maybeGetInstance();
      
      // Assume que você tem uma classe ConnectivityService simples
      final connectivity = ConnectivityService(); 
      
      final httpClient = HttpClient(session);
      final remoteService = GroupRemoteService(httpClient);
      final userRemote = UserRemoteService(httpClient);
      
      final repository = GroupRepository(
        remote: remoteService,
        local: localDb?.groups,
        net: connectivity,
        session: session,
        userRemote: userRemote,
      );

      // 3. Conversão do Enum para String da API
      final methodString = _selectedMethod == EvaluationMethod.commitStreak 
          ? 'streak_commits' 
          : 'streak_images';

      // 4. Chamada ao Repositório
      await repository.createGroup(
        name: widget.name,
        description: widget.description,
        image: widget.image,
        startDate: widget.startDate,
        endDate: widget.endDate,
        method: methodString,
        repository: _repositoryController.text.isNotEmpty 
            ? _repositoryController.text 
            : null,
      );

      if (!mounted) return;

      // 5. Sucesso e Navegação
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grupo criado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Redireciona para a tela de Meus Grupos
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => GroupListScreen()),
        (route) => false,
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar grupo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
