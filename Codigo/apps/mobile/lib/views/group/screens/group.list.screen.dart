import 'package:flutter/material.dart';

import 'package:app/domain/models/group/group.dart';
import 'package:app/domain/models/group/group_with_details.dart';
import 'package:app/repositories/group.repository.dart';
import 'package:app/services/connectivity_service.dart';
import 'package:app/views/group/widgets/card.group.dart';

class GroupListScreen extends StatefulWidget {
  final GroupRepository groupRepository;
  final ConnectivityService connectivity;

  const GroupListScreen({
    super.key,
    required this.groupRepository,
    required this.connectivity,
  });

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  Future<List<Group>>? _futureGroups;
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final isOnline = await widget.connectivity.isOnline();
    if (mounted) {
      setState(() => _online = isOnline);
    }

    final groups = await widget.groupRepository.getUserGroups();

    if (mounted) {
      setState(() {
        _futureGroups = Future.value(groups);
      });
    }

    Future.microtask(() async {
      for (final g in groups) {
        await widget.groupRepository.getGroupDetails(g.id);
      }
    });
  }

  Future<void> _pullToRefresh() async {
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Grupos'),
      ),
      floatingActionButton: _online
          ? FloatingActionButton(
              onPressed: () {
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          if (!_online)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.amber.withOpacity(0.15),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sem conexão — exibindo dados do cache (somente leitura)',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _pullToRefresh,
              child: _futureGroups == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<Group>>(
                      future: _futureGroups!,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final groups = snap.data ?? const <Group>[];

                        if (groups.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.all(24),
                            children: const [
                              SizedBox(height: 48),
                              Center(
                                child: Text(
                                  'Nenhum grupo no momento.\nPuxe para atualizar ou crie um novo quando estiver online.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          itemCount: groups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final g = groups[i];
                            return _GroupCard(
                              group: g,
                              groupRepository: widget.groupRepository,
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatefulWidget {
  final Group group;
  final GroupRepository groupRepository;

  const _GroupCard({
    required this.group,
    required this.groupRepository,
  });

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  GroupDetails? _details;
  bool _loading = false;
  bool _openedOnce = false;

  Future<void> _onExpandChanged(bool open) async {
    _openedOnce = open || _openedOnce;
    if (!open) return;
    if (_details != null || _loading) return;

    setState(() => _loading = true);
    final d = await widget.groupRepository.getGroupDetails(widget.group.id);
    if (!mounted) return;
    setState(() {
      _details = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? expanded;

    if (_loading) {
      expanded = const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'Carregando ranking...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    } else if (_details != null) {
      expanded = _RankingBlock(details: _details!);
    } else if ((widget.group.description ?? '').isNotEmpty) {
      expanded = Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          widget.group.description!,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    } else if (_openedOnce) {
      expanded = const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'Sem cache de ranking para este grupo (abra online pelo menos uma vez).',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return GroupCard(
      title: widget.group.name,
      imageUrl: widget.group.image,
      bannerStyle: widget.group.status
          ? BannerStyle.primary
          : BannerStyle.tertiary,
      status: widget.group.status
          ? GroupStatus.ativo
          : GroupStatus.concluido,
      expanded: expanded,
      onBannerTap: () async {
        final d =
            _details ?? await widget.groupRepository.getGroupDetails(widget.group.id);
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _GroupDetailsPage(details: d),
          ),
        );
      },
      onExpandChanged: _onExpandChanged,
    );
  }
}

class _RankingBlock extends StatelessWidget {
  final GroupDetails details;
  const _RankingBlock({required this.details});

  String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final participants = [...details.participants]
      ..sort((a, b) =>
          b.participant.points.compareTo(a.participant.points));

    final leader = participants.isNotEmpty ? participants.first : null;
    final top3 = participants.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leader != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: _pill(
              context,
              labelLeft: 'Leader',
              name: leader.user.name,
              points: leader.participant.points,
              color: cs.primary,
            ),
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Ranking',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(top3.length, (i) {
          final row = top3[i];
          final pos = i + 1;
          return Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(),
              title: Text(
                row.user.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${row.participant.points.toStringAsFixed(1)} pontos',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _ordinal(pos),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _pill(
    BuildContext context, {
    required String labelLeft,
    required String name,
    required double points,
    required Color color,
  }) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: 6),
        Text(
          labelLeft,
          style: tt.labelMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(width: 8),
        Text(name, style: tt.labelLarge),
        const SizedBox(width: 8),
        Text(
          '${points.toStringAsFixed(1)} pontos',
          style: tt.labelMedium?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _GroupDetailsPage extends StatelessWidget {
  final GroupDetails? details;
  const _GroupDetailsPage({required this.details});

  @override
  Widget build(BuildContext context) {
    if (details == null) {
      return const Scaffold(
        body: Center(
          child: Text('Sem cache disponível para este grupo.'),
        ),
      );
    }

    final g = details!.group;
    final p = details!.participants;

    return Scaffold(
      appBar: AppBar(title: Text(g.name)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: p.length,
        itemBuilder: (context, i) {
          final row = p[i];
          return Card(
            color: const Color(0xFF1E1E1E),
            child: ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(
                row.user.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${row.participant.points.toStringAsFixed(1)} pontos',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
