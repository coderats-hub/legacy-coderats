import 'package:flutter/material.dart';
import 'login.screen.dart';
import 'package:app/shared/components/app_components.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'onboarding.screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                  // Logo do ratinho codando
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cadastro com GitHub em desenvolvimento',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: AppColors.accent,
                          ),
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
                  // Formulário
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome Completo
                        RichText(
                          text: TextSpan(
                            text: 'Nome Completo',
                            style: AppTextStyles.inputLabel,
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SharedTextField(
                          placeholder: 'Insira seu nome',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // E-mail
                        RichText(
                          text: TextSpan(
                            text: 'E-mail',
                            style: AppTextStyles.inputLabel,
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SharedTextField(
                          placeholder: 'Insira seu melhor e-mail',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu email';
                            }
                            if (!value.contains('@')) {
                              return 'Digite um email válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Senha
                        RichText(
                          text: TextSpan(
                            text: 'Senha',
                            style: AppTextStyles.inputLabel,
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SharedTextField(
                          placeholder: 'Insira sua senha',
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite sua senha';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Confirmar Senha
                        RichText(
                          text: TextSpan(
                            text: 'Confirmar Senha',
                            style: AppTextStyles.inputLabel,
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SharedTextField(
                          placeholder: 'Confirme sua senha',
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, confirme sua senha';
                            }
                            if (value != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        // Botão Cadastrar
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: AppButton(
                            text: 'Cadastrar',
                            expanded: false,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const OnboardingStartScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Texto "Já possui conta? Entrar!"
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Já possui conta? ',
                              style: AppTextStyles.inputHint,
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) => const LoginScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    },
                                    child: Text(
                                      'Entrar!',
                                      style: AppTextStyles.inputHint.copyWith(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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