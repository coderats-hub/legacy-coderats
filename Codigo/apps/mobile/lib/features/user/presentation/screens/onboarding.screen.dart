/**
 * TELA DE ONBOARDING/BOAS-VINDAS
 * 
 * Tela exibida após o login inicial para dar boas-vindas ao usuário
 * e apresentar as principais ações que pode realizar.
 * 
 * Onde é usada:
 * - Navegação da TelaInicio após login GitHub
 * - Rota '/started' no main.dart
 * 
 * Funcionalidades:
 * - Mensagem de boas-vindas personalizada
 * - Ilustração do mascote Code Rats
 * - Card com duas ações principais:
 *   1. Criar grupo novo
 *   2. Entrar em grupo via código
 * - Design responsivo com scroll
 * - Feedback visual com snackbars
 * 
 * Navegação:
 * - Vai para: CreateGroupScreen (criar grupo)
 * - Vai para: GroupsPage (entrar via código - funcionalidade futura)
 */

import 'package:app/features/group/presentation/screens/group.create.screen.dart';
import 'package:app/features/group/presentation/screens/group.list.screen.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/theme/app_theme_extended.dart';
import 'package:app/shared/components/app_components.dart';

// Tela de onboarding com boas-vindas e ações principais
class OnboardingStartScreen extends StatelessWidget {
  const OnboardingStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                const SizedBox(height: 40),
                
                // Título de boas-vindas
                Text(
                  'Vamos começar?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleBlack, // Estilo título principal
                ),
                const SizedBox(height: 6),
                
                // Subtítulo explicativo
                Text(
                  'Nós estamos muito felizes de vê-lo aqui!',
                  textAlign: TextAlign.center,
                  style: AppTextStylesExtended.subtitleWhite.copyWith(
                    fontWeight: FontWeight.w400, 
                    fontSize: 14
                  ),
                ),

                // Ilustração do mascote Code Rats
                const SizedBox(height: 40),
                Semantics(
                  label: 'Ilustração de um ratinho programando em um notebook', // Acessibilidade
                  child: Image.asset(
                    'assets/images/onboardingMouse.png',
                    width: 260,
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 48),

                // ---------- Cartão de ações ----------
                _ActionsCard(
                  onCreateGroup: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreateGroupScreen(),
                      ),
                    );
                  },
                  onJoinWithCode: () {
                    Navigator.of(context).pushNamed('/join-group');
                  },
                ),

                // ---------- Pular por enquanto ---------- 
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GroupsPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Pular por enquanto',
                    style: AppTextStyles.skipBold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary, // mesmo verde usado no app
        content: Text(
          message,
          style: AppTextStyles.subtitle,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Cartão com duas ações (criar grupo / entrar via código), visual idêntico ao mock:
/// - Container #333333 com cantos arredondados
/// - Itens com ícone à esquerda, título, subtítulo e chevron à direita
/// - Divider central #444444
class _ActionsCard extends StatelessWidget {
  final VoidCallback onCreateGroup;
  final VoidCallback onJoinWithCode;

  const _ActionsCard({
    required this.onCreateGroup,
    required this.onJoinWithCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _ActionRow(
            icon: Icons.add_circle_outline,
            title: 'Criar um grupo',
            subtitle: 'Iniciar algo novo e convidar outros amigos para se juntar.',
            onTap: onCreateGroup,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Divider(
              color: Color(0xFFACACAC),
              thickness: 2,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          _ActionRow(
            icon: Icons.groups_outlined,
            title: 'Entrar via código',
            subtitle:
                'Se juntar a um grupo privado que você foi convidado.',
            onTap: onJoinWithCode,
          ),
        ],
      ),
    );
  }
}

/// Linha de ação reutilizável para manter o código limpo.
/// Observações de acessibilidade:
/// - Toda a linha é "clicável" via InkWell, com Semantics label.
/// - Tamanhos e espaçamentos replicam o estilo do app.
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            // Ícone à esquerda
            Icon(icon, size: 32, color: AppColorsExtended.white),
            const SizedBox(width: 12),
            // Título e subtítulo (ocupam o espaço restante)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.actionBoldWhite,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.descriptionWhite,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Chevron à direita
            const Icon(Icons.chevron_right, color: AppColorsExtended.white),
          ],
        ),
      ),
    );
  }
}

/// Paleta/constantes locais (mantém a identidade do app).
/// Sugestão: mover para um tema global/shared caso ainda não exista.

