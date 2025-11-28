import 'package:app/repositories/group.repository.dart'; // Importe seu repo
import 'package:app/services/group/group_remote_service.dart';
import 'package:app/services/http_client.dart';
import 'package:app/services/local_database.dart';
import 'package:app/services/connectivity_service.dart';
import 'package:app/core/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'package:app/views/group/screens/group.details.screen.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  
  // Estado para controlar o loading do botão
  bool _isLoading = false; 

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // Função para processar a entrada no grupo
  Future<void> _handleJoinGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Montar as dependências (Igual fizemos na tela anterior)
      final session = SessionManager.instance;
      final localDb = await LocalDatabase.maybeGetInstance();
      final httpClient = HttpClient(session);
      
      final repository = GroupRepository(
        remote: GroupRemoteService(httpClient),
        local: localDb?.groups,
        net: ConnectivityService(),
        session: session,
      );

      // 2. Chamar o método de entrar no grupo
      final groupId = await repository.joinGroup(_codeController.text.trim().toUpperCase());

      if (mounted) {
        setState(() => _isLoading = false);

        // 3. Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você entrou no grupo com sucesso!'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );

        // 4. Aguardar um frame antes de navegar (melhora transição visual)
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          // 5. Navegar para os detalhes do grupo
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => GroupDetailPage(
                groupId: groupId,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Tratamento de erro mais detalhado
        String errorMessage = 'Erro ao entrar no grupo';
        
        if (e.toString().contains('404')) {
          errorMessage = 'Código inválido. Verifique e tente novamente.';
        } else if (e.toString().contains('410') || e.toString().contains('inativo')) {
          errorMessage = 'Este grupo está inativo e não aceita novos membros.';
        } else if (e.toString().contains('internet') || e.toString().contains('Conexao')) {
          errorMessage = 'Sem conexão com a internet.';
        } else if (e.toString().contains('401') || e.toString().contains('403')) {
          errorMessage = 'Você não tem permissão para entrar neste grupo.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Entrar em um grupo'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: Image.asset(
                          'assets/images/ratsgroupcoding.png',
                          width: 400,
                          height: 240,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Código', style: AppTextStyles.inputLabel),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _codeController,
                          style: AppTextStyles.inputLabel,
                          // Desabilita campo se estiver carregando
                          enabled: !_isLoading, 
                          decoration: InputDecoration(
                            hintText: 'Insira o código do grupo',
                            hintStyle: AppTextStyles.inputHint,
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
                              borderSide: const BorderSide(color: AppColors.accent, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite o código do grupo';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppCorners.md),
                            ),
                            elevation: 0,
                          ),
                          // Chama a função assíncrona
                          onPressed: _isLoading ? null : _handleJoinGroup, 
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Juntar-se',
                                style: AppTextStyles.headlineBold16White,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
