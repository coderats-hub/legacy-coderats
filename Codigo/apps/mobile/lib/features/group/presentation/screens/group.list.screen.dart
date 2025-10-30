import 'package:flutter/material.dart';
import 'package:app/services/group_repository.dart';
import 'package:app/services/local_database.dart';
import 'package:app/services/connectivity_service.dart';
import 'package:app/features/group/presentation/widgets/card.group.dart';

/// Groups listing page wired to Online‑first + SQLite cache.

/// How to use:
///
/// Example:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => GroupListScreen(currentUserId: 'a1b2c3d4-e5f6-7890-1234-56789abcdef0'),
/// ));

class GroupListScreen extends StatefulWidget {
  final String currentUserId;
  const GroupListScreen({super.key, required this.currentUserId});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final _repo = GroupRepository();
  final _net = ConnectivityService();

  String? _overrideUserId;

  late Future<List<Group>> _futureGroups;
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final isOnline = await _net.isOnline();
    setState(() => _online = isOnline);
    setState(() {
      final userId = _overrideUserId ?? widget.currentUserId;
      _futureGroups = _repo.getUserGroups(userId);
    });
  }

  Future<void> _showUserSwitchDialog() async {
    final controller = TextEditingController(text: _overrideUserId ?? widget.currentUserId);
    final res = await showDialog<String?>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Switch User ID (debug)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'User ID (UUID)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: const Text('Switch')),
        ],
      );
    });
    if (res != null) {
      setState(() => _overrideUserId = res.isEmpty ? null : res);
      await _reload();
    }
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
        actions: [
          IconButton(
            tooltip: 'Switch user id (debug)',
            icon: const Icon(Icons.switch_account),
            onPressed: _showUserSwitchDialog,
          ),
        ],
      ),
      floatingActionButton: _online
          ? FloatingActionButton(
              onPressed: () {
                // TODO: navegue para a tela de criação de grupo (somente online)
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
        child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
          'Sem conexão — exibindo dados do cache (somente leitura)'.toUpperCase(),
                      style: TextStyle(color: Colors.amber, fontSize: 12, letterSpacing: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _pullToRefresh,
              child: FutureBuilder<List<Group>>(
                future: _futureGroups,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final g = groups[i];
                      return _GroupCard(
                        group: g,
                        onTap: () async {
                          final details = await _repo.getGroupDetails(g.id);
                          if (!mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _GroupDetailsPage(details: details),
                            ),
                          );
                        },
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

/// Adapter that maps our `Group` model into your custom Card widget API.
/// If parameter names differ in your CardGroup implementation, adjust them here only.
class _GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Map our Group model to the shared GroupCard widget.
    return GroupCard(
      title: group.name,
      imageUrl: group.image,
      bannerStyle: group.status ? BannerStyle.primary : BannerStyle.tertiary,
      status: group.status ? GroupStatus.ativo : GroupStatus.concluido,
      expanded: (group.description ?? '').isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Text(group.description!, style: const TextStyle(color: Colors.white70)),
            )
          : null,
      onBannerTap: onTap,
      onExpandChanged: (_) {},
    );
  }
}

/// Minimal details page (read‑only offline). Replace by your real screen.
class _GroupDetailsPage extends StatelessWidget {
  final GroupDetails? details;
  const _GroupDetailsPage({required this.details});

  @override
  Widget build(BuildContext context) {
    if (details == null) {
      return const Scaffold(
        body: Center(child: Text('Sem cache disponível para este grupo.')),
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
              title: Text(row.user.name, style: const TextStyle(color: Colors.white)),
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

/// Backwards-compatible wrapper so callers can use `const GroupsPage()`.
/// Uses a mocked user id from the API docs so the app can run without login.
class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  static const _mockUserId = 'a1b2c3d4-e5f6-7890-1234-56789abcdef0';

  @override
  Widget build(BuildContext context) {
    return GroupListScreen(currentUserId: _mockUserId);
  }
}
