import 'package:app/database/group/group.dao.dart';
import 'package:app/repositories/group.repository.dart';
import 'package:app/services/http_client.dart';
import 'package:app/services/local_database.dart';
import 'package:flutter/material.dart';

// --- IMPORTS DE DOMÍNIO ---
import 'package:app/domain/group/group.dart';
import 'package:app/domain/group/group_details.dart';

// --- IMPORTS DE INFRAESTRUTURA ---
import 'package:app/core/session_manager.dart';
import 'package:app/services/group/group_remote_service.dart';
import 'package:app/services/user/user_remote_service.dart';
import 'package:app/services/connectivity_service.dart';

// --- IMPORTS DE UI/TELAS ---
import 'package:app/views/group/screens/group.create.screen.dart';
import 'package:app/views/group/screens/group.details.screen.dart';
import 'package:app/views/group/widgets/card.group.dart';
import 'package:app/shared/utils/string_utils.dart';

// --- IMPORTS DO TEMA E COMPONENTES PADRÃO ---
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  Future<List<Group>>? _futureGroups;
  bool _online = true;
  
  // Dependências
  GroupRepository? _groupRepository;
  ConnectivityService? _connectivity;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _initDependenciesAndLoad();
  }

  Future<void> _initDependenciesAndLoad() async {
    try {
      final session = SessionManager.instance;
      
      final localDb = await LocalDatabase.maybeGetInstance();
      final GroupDao? groupDao = localDb?.groups;

      final connectivity = ConnectivityService();
      final httpClient = HttpClient(session);
      
      final remoteService = GroupRemoteService(httpClient);
      final userRemote = UserRemoteService(httpClient);
      
      final repository = GroupRepository(
        remote: remoteService,
        local: groupDao, 
        net: connectivity,
        session: session,
        userRemote: userRemote,
      );

      if (mounted) {
        setState(() {
          _groupRepository = repository;
          _connectivity = connectivity;
          _initializing = false;
        });
        _reload();
      }
    } catch (e) {
      debugPrint('Erro ao iniciar dependências: $e');
      if (mounted) setState(() => _initializing = false);
    }
  }
  Future<void> _reload() async {
    if (_groupRepository == null || _connectivity == null) return;

    final isOnline = await _connectivity!.isOnline();
    if (mounted) {
      setState(() => _online = isOnline);
    }

    final groupsFuture = _groupRepository!.getUserGroups();

    if (mounted) {
      setState(() {
        _futureGroups = groupsFuture;
      });
    }

    final groups = await groupsFuture;
    Future.microtask(() async {
      for (final g in groups) {
        if (_groupRepository != null) {
          try {
            await _groupRepository!.getGroupDetails(g.id);
          } catch (_) {}
        }
      }
    });
  }

  Future<void> _pullToRefresh() async {
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: AppLoading()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: 'Meus Grupos',
        showBackButton: false,
      ),
      body: Column(
        children: [
          if (!_online)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              color: AppColors.skip.withOpacity(0.15),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: AppColors.skip, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Sem conexão — exibindo cache (somente leitura)',
                      style: AppTextStyles.subtitle.copyWith(color: AppColors.skip, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: _pullToRefresh,
              child: _futureGroups == null
                  ? const Center(child: AppLoading())
                  : FutureBuilder<List<Group>>(
                      future: _futureGroups!,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: AppLoading());
                        }
                        if (snap.hasError) {
                           return Center(
                             child: Padding(
                               padding: const EdgeInsets.all(AppSpacing.xl),
                               child: Text(
                                 'Erro ao carregar: ${snap.error}',
                                 textAlign: TextAlign.center,
                                 style: AppTextStyles.subtitle.copyWith(color: AppColors.error),
                               ),
                             ),
                           );
                        }

                        final groups = snap.data ?? const <Group>[];

                        if (groups.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            children: [
                              const SizedBox(height: AppSpacing.xxl),
                              Icon(Icons.group_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                              const SizedBox(height: AppSpacing.lg),
                              Center(
                                child: Text(
                                  'Nenhum grupo no momento.\nCrie um novo para começar!',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
                          itemCount: groups.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, i) {
                            final g = groups[i];
                            return _GroupCard(
                              group: g,
                              groupRepository: _groupRepository!,
                              onGroupChanged: _reload, // Passa o callback de reload
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
        currentIndex: 1, // Grupos é o índice 1
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/feed');
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
          // Se index == 1, já está na tela de grupos
        },
      ),
    );
  }
}

class _GroupCard extends StatefulWidget {
  final Group group;
  final GroupRepository groupRepository;
  final VoidCallback onGroupChanged; // Callback para notificar mudanças

  const _GroupCard({
    required this.group,
    required this.groupRepository,
    required this.onGroupChanged,
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
    
    try {
      final d = await widget.groupRepository.getGroupDetails(widget.group.id);
      if (!mounted) return;
      setState(() {
        _details = d;
        _loading = false;
      });
    } catch(e) {
      if(mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? expanded;

    if (_loading) {
      expanded = Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
            const SizedBox(width: AppSpacing.sm),
            Text('Carregando ranking...', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    } else if (_details != null) {
      expanded = _RankingBlock(details: _details!);
    } else if ((widget.group.description ?? '').isNotEmpty) {
      expanded = Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(widget.group.description!, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
      );
    } else if (_openedOnce) {
      expanded = Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text('Sem cache de ranking.', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
      );
    }

    // Este widget vem do 'card.group.dart'
    return GroupCard(
      title: widget.group.name,
      imageUrl: widget.group.image,
      // Se necessário adapte status/bannerStyle aqui
      expanded: expanded,
      onBannerTap: () async {
        // --- NAVEGAÇÃO PARA A TELA COMPLETA ---
        final shouldRefresh = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => GroupDetailPage(
              groupId: widget.group.id,
              groupNamePreview: widget.group.name,
              imageUrlPreview: widget.group.image,
            ),
          ),
        );

        // Se o usuário saiu do grupo, notifica o parent para recarregar
        if (shouldRefresh == true && mounted) {
          widget.onGroupChanged();
        }
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
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final participants = [...details.participants]
      ..sort((a, b) => b.points.compareTo(a.points));

    final leader = participants.isNotEmpty ? participants.first : null;
    final top3 = participants.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leader != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
            child: _pill(
              context,
              labelLeft: 'Líder',
              name: StringUtils.truncateName(leader.name),
              points: leader.points,
              color: AppColors.skip,
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('Ranking', style: AppTextStyles.title.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(top3.length, (i) {
          final row = top3[i];
          final pos = i + 1;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppCorners.md),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: row.image != null ? NetworkImage(row.image!) : null,
                  backgroundColor: AppColors.border,
                  child: row.image == null 
                    ? Text(row.name[0], style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)) 
                    : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(StringUtils.truncateName(row.name), style: AppTextStyles.title.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${row.points.toStringAsFixed(1)} pontos', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2), 
                    borderRadius: BorderRadius.circular(AppCorners.sm),
                  ),
                  child: Text(_ordinal(pos), style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }

  Widget _pill(BuildContext context, {required String labelLeft, required String name, required double points, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.emoji_events, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(labelLeft, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(width: AppSpacing.sm),
        Text(name, style: AppTextStyles.title.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(width: AppSpacing.sm),
        Text('${points.toStringAsFixed(1)} pts', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
