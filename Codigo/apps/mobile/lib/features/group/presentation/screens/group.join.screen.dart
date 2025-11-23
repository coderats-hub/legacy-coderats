/**
 * TELA DE ENTRAR EM GRUPO VIA CÓDIGO
 * 
 * Permite ao usuário entrar em um grupo existente usando
 * um código de convite fornecido pelo administrador do grupo.
 * 
 * Onde é usada:
 * - Navegação do perfil privado (botão "Entrar via código")
 * - Navegação do onboarding (ação "Entrar em grupo via código")
 * - Rota '/join-group' no main.dart
 * 
 * Funcionalidades:
 * - Campo de entrada para código do grupo
 * - Validação de formulário
 * - Ilustração dos mascotes programando
 * - Botão de confirmação para entrar no grupo
 * - Layout responsivo com scroll
 * - Feedback de sucesso/erro
 * 
 * Navegação:
 * - Vem de: PrivateProfileScreen, OnboardingScreen
 * - Volta para: tela anterior após sucesso/erro
 */

import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'package:app/features/group/presentation/screens/group.details.screen.dart';

// Tela para entrar em grupo usando código de convite
class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

// Estado da tela de entrada em grupo
class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();        // Chave para validação do formulário
  final _codeController = TextEditingController(); // Controlador do campo de código

  @override
  void dispose() {
    _codeController.dispose(); // Limpa o controlador para evitar memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Header padrão com título e botão voltar
      appBar: const AppHeader(
        title: 'Entrar em um grupo',
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView( // Permite scroll se necessário
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight), // Altura mínima da tela
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), // Margens laterais
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      
                      // Ilustração dos mascotes programando em grupo
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
                        child: Text(
                          'Código',
                          style: AppTextStyles.inputLabel,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _codeController,
                          style: AppTextStyles.inputLabel,
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // TODO: Integrar com API para validar código e obter dados do grupo
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const GroupDetailPage(groupName: 'Grupo Teste'),
                                ),
                              );
                            }
                          },
                          child: const Text(
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
