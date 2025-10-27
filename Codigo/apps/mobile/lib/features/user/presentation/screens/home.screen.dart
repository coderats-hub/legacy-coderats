/**
 * TELA INICIAL / SPLASH SCREEN
 * 
 * Esta é a primeira tela que o usuário vê ao abrir a aplicação.
 * Funciona como uma splash screen e tela de login inicial.
 * 
 * Onde é usada:
 * - Definida como 'home' no MaterialApp (main.dart)
 * - Primeira tela carregada na inicialização da app
 * 
 * Funcionalidades:
 * - Exibe o logo do Code Rats
 * - Botão "Entrar com GitHub" para autenticação
 * - Navegação para onboarding após login
 * - Design responsivo com espaçamentos proporcionais
 * - Rodapé "Powered by Code Rats"
 * 
 * Navegação:
 * - Vai para: OnboardingStartScreen (após login GitHub)
 */

import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'onboarding.screen.dart';

// Tela inicial da aplicação - splash/welcome screen com login GitHub
class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), // Margens laterais
          child: Column(
            children: [
              // Espaço superior proporcional
              const Spacer(flex: 2),
              
              // Logo principal do Code Rats
              Image.asset(
                'assets/images/logo.png',
                width: 350,
                height: 210,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.lg), // Espaçamento entre logo e botão
              // Botão de login com GitHub
              Container(
                width: double.infinity,  // Largura total
                height: 56,             // Altura fixa do botão
                child: OutlinedButton(
                  onPressed: () {
                    // Navega para onboarding removendo todas as telas anteriores
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const OnboardingStartScreen(),
                      ),
                      (route) => false, // Remove todas as rotas anteriores
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppCorners.sm),
                    ),
                    backgroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centraliza conteúdo
                    children: [
                      // Ícone do GitHub
                      Image.asset(
                        'assets/icons/github.png',
                        width: 32,
                        height: 32,
                        color: AppColors.textPrimary, // Cor do tema
                      ),
                      const SizedBox(width: 12), // Espaçamento entre ícone e texto
                      
                      // Texto do botão
                      const Text(
                        'Entrar com GitHub',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFD9D9D9), // Cor do texto
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',         // Fonte padrão
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Espaço inferior proporcional  
              const Spacer(flex: 2),
              
              // Rodapé com créditos
              Padding(
                padding: const EdgeInsets.only(bottom: 24), // Margem inferior
                child: Text(
                  'Powered by Code Rats',
                  style: AppTextStyles.inputHint.copyWith(
                    color: Colors.white, // Texto branco
                    fontSize: 12,       // Tamanho pequeno
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}