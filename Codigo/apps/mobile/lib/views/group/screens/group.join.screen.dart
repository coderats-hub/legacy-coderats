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

      // 2. Chamar o método de entrar no grupo (Você precisará criar esse método no Repo se não existir)
      // Supondo que o backend retorne o ID do grupo ao entrar com sucesso
      final groupId = await repository.joinGroup(_codeController.text.trim());

      if (mounted) {
        setState(() => _isLoading = false);

        // 3. Navegar passando o ID recebido da API
        Navigator.of(context).pushReplacement( // Use pushReplacement para ele não voltar para a tela de código
          MaterialPageRoute(
            builder: (context) => GroupDetailPage(
              groupId: groupId, // <--- AQUI ESTAVA O ERRO, AGORA PASSAMOS O ID
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao entrar no grupo: $e'),
            backgroundColor: Colors.redAccent,
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
                          'images/ratsgroupcoding.png',
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
