import 'package:flutter/material.dart';
import 'package:coderats/shared/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'onboarding.screen.dart';
import 'code_exchange.screen.dart';
import 'package:coderats/core/session_manager.dart';

// Tela inicial da aplicação - splash/welcome screen com login GitHub
class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key});

  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> {

  @override
  void initState() {
    super.initState();
    _redirectIfAuthenticated();
  }

  void _redirectIfAuthenticated() {
    final token = SessionManager.instance.validToken;
    if (token != null) {
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/feed');
        }
      });
    }
  }
  
  Future<void> _launchGitHubLogin() async {
    final String baseUrl = dotenv.env['BASE_API_URL'] ?? 'http://localhost:8080';
    final String githubLoginUrl = '$baseUrl/auth/github/login';
    final Uri uri = Uri.parse(githubLoginUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CodeExchangeScreen(),
            ),
          );
        }
      } else {
        _showErrorSnackBar('Não foi possível abrir o link.');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao tentar abrir o link: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), 
          child: Column(
            children: [
              const Spacer(flex: 2),
              
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
                    // Executa o login com GitHub
                    _launchGitHubLogin();
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
                        'Login via GitHub',
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
