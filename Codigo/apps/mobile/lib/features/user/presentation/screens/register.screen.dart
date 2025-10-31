import 'package:flutter/material.dart';
import 'package:app/shared/components/app_components.dart';
import 'package:app/shared/theme/app_theme.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import 'code_exchange.screen.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  @override
  void dispose() {
    super.dispose();
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
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 180,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: OutlinedButton(
                      onPressed: _launchGitHubLogin,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: AppSpacing.sm),
                            child: Image.asset(
                              'assets/icons/github.png',
                              width: 32,
                              height: 32,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'Cadastrar com GitHub',
                            style: AppTextStyles.button,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
