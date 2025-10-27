/**
 * Tela de Lista de Grupos (GroupsPage)
 * 
 * NAVEGAÇÃO: Acessível via bottom navigation (índice 1) - principal hub de grupos
 * 
 * FUNÇÃO:
 * - Exibe lista principal de todos os grupos do usuário
 * - Interface central para navegação entre grupos ativos e concluídos  
 * - Permite acesso rápido a detalhes de cada grupo via cards expansíveis
 * - Fornece acesso para criação de novos grupos via FAB
 * 
 * COMPONENTES PRINCIPAIS:
 * - GroupCard: Cards expansíveis que mostram informações básicas + ranking quando expandidos
 * - _ExpandedGroupDemo: Mock de conteúdo expandido com ranking e estatísticas
 * - _AvatarStat: Widget para mostrar estatísticas de líder/usuário atual
 * - AppNavbar: Navegação inferior com grupos como tela ativa
 * - AppFAB: Botão flutuante para criar novos grupos
 * 
 * FLUXOS DE NAVEGAÇÃO:
 * - Para detalhes do grupo → group.details.screen.dart
 * - Para criar grupo → group.create.screen.dart  
 * - Para perfil privado → private.profile.screen.dart
 */

import 'package:app/features/profile/presentation/screens/private.profile.screen.dart';
import 'package:app/features/group/presentation/screens/group.details.screen.dart';
import 'package:app/features/group/presentation/widgets/card.group.dart';
import 'package:app/features/group/presentation/widgets/banner.group.dart' as banner;
import 'group.create.screen.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar simples com título "Grupos" - sem botão de voltar pois é tela principal
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: const Text(
            'Grupos', 
            style: AppTextStyles.headerTitle,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove botão de voltar
      ),
      // Lista principal de grupos - cada card é expansível e navega para detalhes
      body: ListView(
        children: [
          // Grupo ativo com estilo tertiary
          GroupCard(
            title: 'Code Rats',
            bannerStyle: BannerStyle.tertiary,
            status: GroupStatus.ativo,
            expanded: const _ExpandedGroupDemo(), // Mostra ranking quando expandido
            onBannerTap: () {
              // Navega para tela de detalhes do grupo específico
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GroupDetailPage(
                    groupName: 'Code Rats',
                    bannerStyle: banner.BannerStyle.tertiary,
                  ),
                ),
              );
            },
          ),
          // Grupo concluído com estilo secondary
          GroupCard(
            title: 'Ratitos 123',
            bannerStyle: BannerStyle.secondary,
            status: GroupStatus.concluido,
            expanded: const _ExpandedGroupDemo(), // Mesmo layout expandido
            onBannerTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GroupDetailPage(
                    groupName: 'Ratitos 123',
                    bannerStyle: banner.BannerStyle.secondary,
                  ),
                ),
              );
            },
          ),
          // Grupo com imagem personalizada (sobrescreve bannerStyle)
          GroupCard(
            title: 'Com Imagem',
            imageUrl: 'https://picsum.photos/800/300',
            bannerStyle: BannerStyle.primary, // ignorado se houver imagem
            expanded: const _ExpandedGroupDemo(),
            onBannerTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GroupDetailPage(
                    groupName: 'Com Imagem',
                    bannerStyle: banner.BannerStyle.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl), // Espaçamento final
        ],
      ),
      // Barra de navegação inferior - tela de grupos está ativa (índice 1)
      bottomNavigationBar: AppNavbar(
        currentIndex: 1, // Grupos é a aba ativa
        onTap: (i) {
          if (i == 0) {
            // Tela de início ainda não implementada
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tela de Início não implementada')),
            );
          } else if (i == 1) {
            // Já está na tela de grupos - não faz nada
          } else if (i == 2) {
            // Navega para perfil privado do usuário
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => PrivateProfileScreen()),
            );
          }
        },
      ),
      // Botão flutuante para criar novos grupos
      floatingActionButton: AppFAB(
        onPressed: () {
          // Navega para tela de criação de grupo
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateGroupScreen(),
            ),
          );
        },
        icon: Icons.add,
        tooltip: 'Criar grupo',
      ),
    );
  }
}

/**
 * Widget de conteúdo expandido dos cards de grupo
 * 
 * Mostra informações detalhadas quando o usuário expande um GroupCard:
 * - Estatísticas do líder e do usuário atual
 * - Ranking dos 3 primeiros membros
 * - Layout responsivo com avatares e pontuações
 */
class _ExpandedGroupDemo extends StatelessWidget {
  const _ExpandedGroupDemo();

  @override
  Widget build(BuildContext context) {
    // Mock data para demonstração do ranking
    final rankingMock = <Map<String, String>>[
      {'name': 'Alice', 'points': '49.5 pontos', 'pos': '1st'},
      {'name': 'Felipe', 'points': '45.5 pontos', 'pos': '2st'},
      {'name': 'Gustavo', 'points': '45.5 pontos', 'pos': '3st'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seção de estatísticas: líder vs usuário atual
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: const [
              _AvatarStat(label: 'Líder', subtitle: '42.8 pontos'),
              SizedBox(width: AppSpacing.md),
              _AvatarStat(label: 'Você', subtitle: '22.3 pontos'),
            ],
          ),
        ),
        // Título da seção de ranking
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 6),
          child: Text('Ranking', style: AppTextStyles.title.copyWith(fontSize: 18, color: Colors.white)),
        ),
        // Lista de membros do ranking (top 3)
        ...rankingMock.map((e) => Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(.3), // Fundo semi-transparente
                borderRadius: BorderRadius.circular(AppCorners.md),
              ),
              child: Row(
                children: [
                  // Avatar do membro
                  const CircleAvatar(radius: 18, backgroundColor: AppColors.accent),
                  const SizedBox(width: AppSpacing.md),
                  // Informações do membro (nome e pontos)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['name']!, style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(e['points']!,
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            )),
                      ],
                    ),
                  ),
                  // Posição no ranking
                  Text(e['pos']!, style: AppTextStyles.title.copyWith(fontSize: 16, color: Colors.white)),
                ],
              ),
            )),
        const SizedBox(height: AppSpacing.md), // Espaçamento final
      ],
    );
  }
}

/**
 * Widget para mostrar estatísticas com avatar
 * 
 * Usado nas seções de líder e usuário atual dentro do conteúdo expandido.
 * Combina avatar circular com labels e valores de pontuação.
 */
class _AvatarStat extends StatelessWidget {
  final String label; // Ex: 'Líder', 'Você'
  final String subtitle; // Ex: '42.8 pontos'
  const _AvatarStat({required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar circular com cor de destaque
        const CircleAvatar(radius: 18, backgroundColor: AppColors.accent),
        const SizedBox(width: AppSpacing.sm),
        // Informações textuais em coluna
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label (Líder/Você)
            Text(label, style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: Colors.white)),
            // Pontuação em destaque
            Text(subtitle, style: AppTextStyles.subtitle.copyWith(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
