import 'dart:async';
import 'package:coderats/views/group/widgets/group_widgets.dart';
import 'package:flutter/material.dart';

import 'package:coderats/core/session_manager.dart';
import 'package:coderats/domain/checkin/checkin.dart';
import 'package:coderats/domain/group/group.dart';
import 'package:coderats/domain/group/group_participant.dart';

import 'package:coderats/repositories/checkin.repository.dart';
import 'package:coderats/repositories/group.repository.dart';
import 'package:coderats/services/checkin/checkin_remote_service.dart';
import 'package:coderats/services/connectivity_service.dart';
import 'package:coderats/services/group/group_remote_service.dart';
import 'package:coderats/services/http_client.dart';
import 'package:coderats/services/local_database.dart';
import 'package:coderats/services/user/user_remote_service.dart';

import 'package:coderats/shared/components/components.dart';
import 'package:coderats/shared/theme/app_theme.dart';
import 'package:coderats/shared/utils/string_utils.dart';
import 'package:coderats/shared/ads/ad_banner_footer.dart';

import 'package:coderats/views/group/widgets/banner.group.dart';

import 'package:coderats/views/checkin/screens/checkin.details.screen.dart';
import 'package:coderats/views/checkin/screens/checkin.list.screen.dart';
import 'package:coderats/views/group/screens/group.edit.screen.dart';
import 'package:coderats/views/group/screens/group.ranking.screen.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupId;
  final String? groupNamePreview;
  final String? imageUrlPreview;
  final String? descriptionPreview;
  final BannerStyle bannerStyle;

  const GroupDetailPage({
    super.key,
    required this.groupId,
    this.groupNamePreview,
    this.imageUrlPreview,
    this.descriptionPreview,
    this.bannerStyle = BannerStyle.tertiary,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  // Dependencies
  GroupRepository? _groupRepository;
  CheckinRepository? _checkinRepository;

  // Data
  List<Checkin> _items = [];
  List<GroupParticipant> _ranking = [];
  Group? _group;

  // UI State
  bool _isLoading = true;
  bool _descOpen = false;
  String? _currentUserRole;

  // Pagination
  final _scrollCtrl = ScrollController();
  static const _checkinsPageSize = 15;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _initDependencies();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _initDependencies() async {
    final session = SessionManager.instance;
    final localDb = await LocalDatabase.maybeGetInstance();
    final connectivity = ConnectivityService();
    final httpClient = HttpClient(session);

    final groupRepo = GroupRepository(
      remote: GroupRemoteService(httpClient),
      local: localDb?.groups,
      net: connectivity,
      session: session,
      userRemote: UserRemoteService(httpClient),
    );

    final checkinRepo = CheckinRepository();

    if (mounted) {
      setState(() {
        _groupRepository = groupRepo;
        _checkinRepository = checkinRepo;
      });
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_checkinRepository == null || _groupRepository == null) return;
    setState(() => _isLoading = true);

    try {
      final details = await _groupRepository!.getGroupDetails(widget.groupId);
      final participantsFromDetails = details.participants;

      final checkins = await _checkinRepository!.fetchGroupCheckins(
        widget.groupId,
        limit: _checkinsPageSize,
        offset: 0,
      );

      final rankingProcessed = participantsFromDetails.isNotEmpty
          ? participantsFromDetails
          : _extractRankingFromCheckins(checkins);

      // Simple role detection
      final myId = SessionManager.instance.currentUserId;
      String? role = 'member';
      if (myId != null && rankingProcessed.isNotEmpty) {
        try {
          final myData = rankingProcessed.firstWhere((p) => p.id == myId);
          role = myData.role ?? role;
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _items = checkins;
          _ranking = rankingProcessed;
          _currentUserRole = role;
          _group = details.group;
          _page = 1;
          _hasMore = checkins.length >= _checkinsPageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<GroupParticipant> _extractRankingFromCheckins(List<Checkin> list) {
    final Map<String, GroupParticipant> uniqueAuthors = {};
    for (var c in list) {
      final participant = GroupParticipant(
        id: c.author.id,
        name: c.author.name,
        image: c.author.image,
        githubUser: c.author.githubUser,
        points: c.author.points,
        role: c.author.role,
      );
      uniqueAuthors[c.author.id] = participant;
    }
    final sorted = uniqueAuthors.values.toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    return sorted;
  }

  Future<void> _loadMoreCheckins() async {
    if (_isLoadingMore || !_hasMore || _checkinRepository == null) return;
    setState(() => _isLoadingMore = true);

    try {
      final offset = _page * _checkinsPageSize;
      final newItems = await _checkinRepository!.fetchGroupCheckins(
        widget.groupId,
        limit: _checkinsPageSize,
        offset: offset,
      );

      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _page++;
          _hasMore = newItems.length >= _checkinsPageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMoreCheckins();
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay(_items);
    final List<_Row> rows = [];
    for (final entry in grouped.entries) {
      rows.add(_Row.header(entry.key));
      for (final c in entry.value) {
        rows.add(_Row.item(c));
      }
    }
    if (_isLoadingMore) rows.add(_Row.loader());

    final displayName = _group?.name ?? widget.groupNamePreview ?? 'Grupo';
    final displayImage = _group?.image ?? widget.imageUrlPreview;
    final displayDesc = _group?.description ??
        widget.descriptionPreview ??
        'Sem descrição disponível.';
    final displayCode = _group?.code;
    final displayRepo = _group?.repository;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: displayName,
        onBack: () => Navigator.of(context).maybePop(),
        actions: _buildAppBarActions(),
      ),
      body: _isLoading
          ? const Center(child: AppLoading())
          : ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                // Banner
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: BannerHero(
                    imageUrl: displayImage,
                    style: widget.bannerStyle,
                    height: 128,
                    radius: AppCorners.lg,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                if (displayRepo != null && displayRepo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: _RepositoryInfo(repo: displayRepo),
                  ),
                if (displayRepo != null && displayRepo.isNotEmpty)
                  const SizedBox(height: AppSpacing.sm),

                if (displayCode != null && displayCode.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: GroupCodeWidget(code: displayCode),
                  ),
                if (displayCode != null && displayCode.isNotEmpty)
                  const SizedBox(height: AppSpacing.lg),

                // Código (Exemplo fixo ou vazio já que API não retorna)
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                //   child: GroupCodeWidget(code: '...'),
                // ),

                const SizedBox(height: AppSpacing.lg),

                // Descrição
                DescriptionAccordion(
                  open: _descOpen,
                  onToggle: () => setState(() => _descOpen = !_descOpen),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      displayDesc,
                      style: AppTextStyles.subtitle
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Ranking
                if (_ranking.isNotEmpty) ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text("Ranking",
                        style: AppTextStyles.title
                            .copyWith(fontSize: 18, color: Colors.white)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Column(
                    children:
                        _ranking.take(3).toList().asMap().entries.map((entry) {
                      final member = entry.value;
                      final pointsFormatted = member.points % 1 == 0
                          ? member.points.toInt().toString()
                          : member.points.toString();

                      return RankingTile(
                        name: StringUtils.truncateName(member.name),
                        points: '$pointsFormatted pontos',
                        pos: '${entry.key + 1}º',
                        imageUrl: member.image,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        RankingChip(
                          label: 'Ver Todo Ranking',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GroupRankingScreen(
                                  participants: _ranking,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Material(
                          color: AppColors.accent,
                          shape: const StadiumBorder(),
                          child: InkWell(
                            customBorder: const StadiumBorder(),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CheckinScreen(
                                    groupId: widget.groupId,
                                    groupName: displayName,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Text(
                                'Ver checkins',
                                style: AppTextStyles.subtitle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // Lista Check-ins
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text("Check-ins",
                      style: AppTextStyles.title.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: AppSpacing.xs),

                if (_items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                        child: Text("Nenhum check-in registrado.",
                            style: TextStyle(color: Colors.white38))),
                  ),

                ...rows.map((r) {
                  if (r.type == _RowType.header)
                    return DayHeader(date: r.date!);
                  if (r.type == _RowType.item) return CheckinTile(c: r.item!);
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: AppLoading(),
                  );
                }).toList(),

                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: AppFAB(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => CommitCheckinScreen(
                    groupId: widget.groupId,
                  ),
                ),
              )
              .then((_) => _loadData());
        },
        icon: Icons.add,
        tooltip: 'Novo check-in',
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerFooter(
            padding: EdgeInsets.only(top: AppSpacing.xs),
          ),
          AppNavbar(
            currentIndex: 1,
            onTap: (i) {
              if (i == 0) {
                Navigator.of(context).pushNamed('/feed');
              } else if (i == 2) {
                Navigator.of(context).pushNamed('/profile');
              }
            },
          ),
        ],
      ),
    );
  }

  // --- Lógica Interna ---

  Map<DateTime, List<Checkin>> _groupByDay(List<Checkin> items) {
    final map = <DateTime, List<Checkin>>{};
    for (final c in items) {
      final dateKey =
          DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
      map.putIfAbsent(dateKey, () => []).add(c);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    final linked = <DateTime, List<Checkin>>{};
    for (final k in sortedKeys) linked[k] = map[k]!;
    return linked;
  }

  List<Widget> _buildAppBarActions() {
    if (_currentUserRole == 'admin') {
      return [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onSelected: (val) {
            if (val == 'edit') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => GroupEditScreen(
                  groupId: widget.groupId,
                  initialName: _group?.name ?? widget.groupNamePreview ?? '',
                  initialDescription: _group?.description ?? widget.descriptionPreview,
                  imageUrl: _group?.image ?? widget.imageUrlPreview,
                  participants: _ranking,
                ),
              )).then((refresh) {
                if (refresh == true) {
                  _loadData();
                }
              });
            } else if (val == 'delete') {
              _showDeleteGroupDialog(context);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar')
                ])),
            const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: AppColors.error))
                ])),
          ],
        )
      ];
    } else if (_currentUserRole == 'member') {
      return [
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: AppColors.textPrimary),
          onPressed: () => _showLeaveGroupDialog(context),
        ),
      ];
    }
    return [];
  }

  void _showLeaveGroupDialog(BuildContext context) {
    showConfirmationDialog(
      context: context,
      title: 'Sair do grupo?',
      icon: Icons.exit_to_app,
      iconColor: AppColors.primary,
      description: 'Você pode entrar novamente depois.',
      details: 'Seus pontos serão mantidos.',
      confirmText: 'Sair',
      confirmColor: AppColors.error,
      onConfirm: _leaveGroup,
    );
  }

  Future<void> _leaveGroup() async {
    if (_groupRepository == null) return;
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)));
      await _groupRepository!.leaveGroup(widget.groupId);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erro ao sair do grupo")));
    }
  }

  void _showDeleteGroupDialog(BuildContext context) {
    showConfirmationDialog(
      context: context,
      title: 'Excluir grupo?',
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.error,
      description: 'Ação irreversível.',
      details: 'O grupo será inativado.',
      confirmText: 'Excluir',
      confirmColor: AppColors.error,
      onConfirm: _deleteGroup,
    );
  }

  Future<void> _deleteGroup() async {
    if (_groupRepository == null) return;
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)));
      await _groupRepository!.deleteGroup(widget.groupId);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erro ao excluir grupo")));
    }
  }
}

// Helpers para a lógica da Lista
enum _RowType { header, item, loader }

class _Row {
  final _RowType type;
  final DateTime? date;
  final Checkin? item;
  _Row.header(this.date)
      : type = _RowType.header,
        item = null;
  _Row.item(this.item)
      : type = _RowType.item,
        date = null;
  _Row.loader()
      : type = _RowType.loader,
        date = null,
        item = null;
}


class _RepositoryInfo extends StatelessWidget {
  final String repo;
  const _RepositoryInfo({required this.repo});

  @override
  Widget build(BuildContext context) {
    final parsed = _parseRepo(repo);
    final owner = parsed.$1;
    final name = parsed.$2;

    if (owner == null || name == null) {
      return Text(
        'Repositorio associado ao grupo: $repo',
        style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repositorio associado ao grupo: $name',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'De $owner',
          style: AppTextStyles.inputHint.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  (String?, String?) _parseRepo(String raw) {
    try {
      final normalized = raw.trim();
      final cleaned = normalized.endsWith('.git')
          ? normalized.substring(0, normalized.length - 4)
          : normalized;

      Uri? uri;
      if (cleaned.startsWith('http')) {
        uri = Uri.tryParse(cleaned);
      } else if (cleaned.contains('/')) {
        uri = Uri.tryParse('https://$cleaned');
      }
      if (uri == null) return (null, null);

      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.length >= 2) {
        final name = segments.last;
        final owner = segments[segments.length - 2];
        return (owner, name);
      }
      return (null, null);
    } catch (_) {
      return (null, null);
    }
  }
}
