import 'package:app/features/profile/presentation/screens/private.profile.dart';
import 'package:app/features/group/presentation/screens/details.group.dart';
import 'package:app/features/group/presentation/widgets/card.group.dart';
import 'create.group.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos', style: AppTextStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          GroupCard(
            title: 'Code Rats',
            bannerStyle: BannerStyle.tertiary,
            status: GroupStatus.ativo,
            expanded: const _ExpandedGroupDemo(),
            onBannerTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GroupDetailPage(groupName: 'Code Rats'),
                ),
              );
            },
          ),
          GroupCard(
            title: 'Ratitos 123',
            bannerStyle: BannerStyle.secondary,
            status: GroupStatus.concluido,
            expanded: const _ExpandedGroupDemo(),
            onBannerTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GroupDetailPage(groupName: 'Ratitos 123'),
                ),
              );
            },
          ),
          GroupCard(
            title: 'Com Imagem',
            imageUrl: 'https://picsum.photos/800/300',
            bannerStyle: BannerStyle.primary, // ignorado se houver imagem
            expanded: const _ExpandedGroupDemo(),
            onBannerTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GroupDetailPage(groupName: 'Com Imagem'),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
      bottomNavigationBar: AppNavbar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tela de Início não implementada')),
            );
          } else if (i == 1) {
            // já está na tela de grupos
          } else if (i == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => PrivateProfileScreen()),
            );
          }
        },
      ),
      floatingActionButton: AppFAB(
        onPressed: () {
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

class _ExpandedGroupDemo extends StatelessWidget {
  const _ExpandedGroupDemo();

  @override
  Widget build(BuildContext context) {
    final rankingMock = <Map<String, String>>[
      {'name': 'Alice', 'points': '49.5 pontos', 'pos': '1st'},
      {'name': 'Felipe', 'points': '45.5 pontos', 'pos': '2st'},
      {'name': 'Gustavo', 'points': '45.5 pontos', 'pos': '3st'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: const [
              _AvatarStat(label: 'Leader', subtitle: '42.8 pontos'),
              SizedBox(width: AppSpacing.md),
              _AvatarStat(label: 'Você', subtitle: '22.3 pontos'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 6),
          child: Text('Ranking', style: AppTextStyles.title),
        ),
        ...rankingMock.map((e) => Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(.3),
                borderRadius: BorderRadius.circular(AppCorners.md),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: AppColors.accent),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['name']!, style: AppTextStyles.title.copyWith(fontSize: 16)),
                        Text(e['points']!,
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  Text(e['pos']!, style: AppTextStyles.title.copyWith(fontSize: 16)),
                ],
              ),
            )),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _AvatarStat extends StatelessWidget {
  final String label;
  final String subtitle;
  const _AvatarStat({required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 14, backgroundColor: AppColors.accent),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
            Text(subtitle, style: AppTextStyles.inputHint),
          ],
        ),
      ],
    );
  }
}
