import 'package:flutter/material.dart';
import 'package:app/services/group_repository.dart';
import 'package:app/services/local_database.dart';
import 'package:app/services/connectivity_service.dart';
import 'package:app/shared/components/components.dart';
import 'package:app/shared/theme/app_theme.dart';
import '../widgets/card.group.dart';
import '../widgets/banner.group.dart' as banner;

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

  Future<List<Group>>? _futureGroups;
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    // 1) Detect connectivity and update the offline banner
    final isOnline = await _net.isOnline();
    setState(() => _online = isOnline);

    // 2) Get the current user id (keeps your debug “switch user”)
    final userId = _overrideUserId ?? widget.currentUserId;

    // 3) Fetch the groups (online-first w/ cache fallback)
    final groups = await _repo.getUserGroups(userId);

    // 4) Show the list immediately
    setState(() {
      _futureGroups = Future.value(groups);
    });

    // 5) NEW: warm up each group's details (participants/ranking) in the cache.
    //    This calls the API when online and writes to SQLite; offline it’s a no-op.
    Future.microtask(() async {
      for (final g in groups) {
        await _repo.getGroupDetails(g.id);
      }
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
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Grupos',
        actions: [
          IconButton(
            tooltip: 'Switch user id (debug)',
            icon: const Icon(Icons.switch_account, color: AppColors.textPrimary),
            onPressed: _showUserSwitchDialog,
          ),
        ],
      ),
      floatingActionButton: _online
          ? AppFAB(
              onPressed: () {
                Navigator.of(context).pushNamed('/create-group');
              },
            )
          : null,
      body: Column(
        children: [
          if (!_online)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              color: AppColors.error.withOpacity(0.15),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: AppColors.error, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Sem conexão — exibindo dados do cache (somente leitura)'.toUpperCase(),
                      style: AppTextStyles.inputHint.copyWith(
                        color: AppColors.error,
                        letterSpacing: 0.5,
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
                  ? const AppLoading()
                  : FutureBuilder<List<Group>>(
                      future: _futureGroups!,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const AppLoading();
                        }
                        final groups = snap.data ?? const <Group>[];
                        if (groups.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            children: [
                              const SizedBox(height: AppSpacing.xxl),
                              Center(
                                child: Text(
                                  'Nenhum grupo no momento.\nPuxe para atualizar ou crie um novo quando estiver online.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            96,
                          ),
                          itemCount: groups.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, i) {
                            final g = groups[i];
                            final currentUserId = _overrideUserId ?? widget.currentUserId;
                            return _GroupCard(
                              group: g,
                              currentUserId: currentUserId,
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppNavbar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pushNamed('/feed');
          } else if (i == 2) {
            Navigator.of(context).pushNamed('/profile');
          }
        },
      ),
    );
  }
}

class _GroupCard extends StatefulWidget {
  final Group group;
  final String currentUserId;
  const _GroupCard({required this.group, required this.currentUserId});

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  final _repo = GroupRepository();
  GroupDetails? _details;
  bool _loading = false;
  bool _openedOnce = false;

  Future<void> _onExpandChanged(bool open) async {
    _openedOnce = open || _openedOnce;
    if (!open) return;
    if (_details != null || _loading) return;

    setState(() => _loading = true);
    final d = await _repo.getGroupDetails(widget.group.id);
    if (!mounted) return;
    setState(() {
      _details = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Expanded area content
    Widget? expanded;
    if (_loading) {
      expanded = Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const AppLoading(size: 18, strokeWidth: 2),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Carregando ranking...',
              style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    } else if (_details != null) {
      expanded = _RankingBlock(details: _details!, currentUserId: widget.currentUserId);
    } else if ((widget.group.description ?? '').isNotEmpty) {
      // Before first load, show the description as a placeholder
      expanded = Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          widget.group.description!,
          style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
        ),
      );
    } else if (_openedOnce) {
      expanded = Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'Sem cache de ranking para este grupo (abra online pelo menos uma vez).',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return GroupCard(
      title: widget.group.name,
      imageUrl: widget.group.image,
      bannerStyle: widget.group.status ? BannerStyle.primary : BannerStyle.tertiary,
      status: widget.group.status ? GroupStatus.ativo : GroupStatus.concluido,
      expanded: expanded,
      onBannerTap: () async {
        // Optional: open full screen details on banner tap
        final d = _details ?? await _repo.getGroupDetails(widget.group.id);
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _GroupDetailsPage(details: d)),
        );
      },
      onExpandChanged: _onExpandChanged,
    );
  }
}

// Pretty ranking block (Leader + Você + Top 3)
class _RankingBlock extends StatelessWidget {
  final GroupDetails details;
  final String currentUserId;
  const _RankingBlock({required this.details, required this.currentUserId});

  String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure sorted by points desc
    final participants = [...details.participants]
      ..sort((a, b) => b.participant.points.compareTo(a.participant.points));

    final leader = participants.isNotEmpty ? participants.first : null;
    final me = participants.where((x) => x.user.id == currentUserId).cast<GroupParticipantWithUser?>().firstWhere(
      (e) => e != null,
      orElse: () => null,
    );
    final top3 = participants.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row: Leader & Você
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
          child: Row(
            children: [
              if (leader != null) _pill(
                labelLeft: 'Leader',
                name: leader.user.name,
                points: leader.participant.points,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              if (me != null) _pill(
                labelLeft: 'Você',
                name: me.user.name,
                points: me.participant.points,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Title: Ranking
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('Ranking', style: AppTextStyles.title),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Top 3
        ...List.generate(top3.length, (i) {
          final row = top3[i];
          final pos = i + 1;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppCorners.md),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: AppColors.textPrimary, size: 20),
              ),
              title: Text(row.user.name, style: AppTextStyles.inputLabel),
              subtitle: Text(
                '${row.participant.points.toStringAsFixed(1)} pontos',
                style: AppTextStyles.inputHint.copyWith(color: AppColors.textSecondary),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppCorners.sm),
                ),
                child: Text(_ordinal(pos), style: AppTextStyles.inputHint.copyWith(color: AppColors.textPrimary)),
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }

  Widget _pill({required String labelLeft, required String name, required double points, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(labelLeft, style: AppTextStyles.inputHint.copyWith(color: AppColors.textSecondary)),
        const SizedBox(width: AppSpacing.sm),
        Text(name, style: AppTextStyles.button.copyWith(fontSize: 13)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${points.toStringAsFixed(1)} pts',
          style: AppTextStyles.inputHint.copyWith(color: AppColors.textSecondary),
        ),
      ],
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
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppHeader(title: 'Detalhes do Grupo'),
        body: Center(
          child: Text(
            'Sem cache disponível para este grupo.',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    final g = details!.group;
    final p = details!.participants;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: g.name,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: p.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final row = p[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppCorners.md),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  '${i + 1}',
                  style: AppTextStyles.button.copyWith(color: AppColors.textPrimary, fontSize: 16),
                ),
              ),
              title: Text(row.user.name, style: AppTextStyles.inputLabel),
              subtitle: Text(
                '${row.participant.points.toStringAsFixed(1)} pontos',
                style: AppTextStyles.inputHint.copyWith(color: AppColors.textSecondary),
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

