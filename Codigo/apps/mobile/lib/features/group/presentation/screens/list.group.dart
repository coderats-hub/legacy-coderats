import 'package:app/features/group/presentation/screens/details.group.dart';
import 'package:app/features/group/presentation/widgets/card.group.dart';
import 'create.group.dart';
import 'package:flutter/material.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupos')),
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
          const SizedBox(height: 48),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1, // esta é a página de Grupos
          onTap: (i) {
            const routeByIndex = ['/home', '/groups', '/profile'];
            final current = ModalRoute.of(context)?.settings.name;
            final target = routeByIndex[i];

            if (current != target) {
              Navigator.of(context).pushReplacementNamed(target);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Início'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_2_outlined), label: 'Grupos'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateGroupScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExpandedGroupDemo extends StatelessWidget {
  const _ExpandedGroupDemo();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final rankingMock = <Map<String, String>>[
      {'name': 'Alice', 'points': '49.5 pontos', 'pos': '1st'},
      {'name': 'Felipe', 'points': '45.5 pontos', 'pos': '2st'},
      {'name': 'Gustavo', 'points': '45.5 pontos', 'pos': '3st'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: const [
              _AvatarStat(label: 'Leader', subtitle: '42.8 pontos'),
              SizedBox(width: 16),
              _AvatarStat(label: 'Você', subtitle: '22.3 pontos'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Text('Ranking', style: tt.titleMedium),
        ),
        ...rankingMock.map((e) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: Colors.white24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['name']!, style: tt.bodyLarge),
                        Text(e['points']!,
                            style: tt.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            )),
                      ],
                    ),
                  ),
                  Text(e['pos']!, style: tt.titleMedium),
                ],
              ),
            )),
        const SizedBox(height: 12),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        const CircleAvatar(radius: 14, backgroundColor: Colors.white24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: tt.labelLarge),
            Text(subtitle, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
