// lib/features/user/presentation/screens/code_exchange.screen.dart

import 'package:app/features/user/data/services/auth.service.dart'; 
import 'package:app/shared/components/components.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CodeExchangeScreen extends StatefulWidget {
  const CodeExchangeScreen({super.key});

  @override
  State<CodeExchangeScreen> createState() => _CodeExchangeScreenState();
}

class _CodeExchangeScreenState extends State<CodeExchangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final AuthService _authService = AuthService(); 
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final String code = _codeController.text.trim();
      final bool success = await _authService.exchangeCodeForToken(code);

      if (success && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao verificar o código: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Quase lá!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Para finalizar seu cadastro, cole o código de verificação que você recebeu.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    SharedTextField(
                      placeholder: 'Insira seu código de verificação',
                      controller: _codeController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite o código';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    SizedBox(
                      height: 48, 
                      child: AppButton(
                        text: _isLoading ? 'Verificando...' : 'Verificar Código',
                        
                        // --- LINHA CORRIGIDA ---
                        onPressed: _isLoading ? () {} : () => _handleVerifyCode(),
                        // --- FIM DA CORREÇÃO ---
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}