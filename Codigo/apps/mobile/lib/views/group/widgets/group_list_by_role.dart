import 'package:flutter/material.dart';
import 'package:coderats/core/session_manager.dart';
import 'package:coderats/domain/group/group.dart';
import 'package:coderats/domain/group/group_details.dart';
import 'package:coderats/repositories/group.repository.dart';
import 'package:coderats/shared/theme/app_theme.dart';
import 'package:coderats/shared/components/components.dart';
import 'package:coderats/shared/utils/string_utils.dart';
import 'package:coderats/views/group/widgets/card.group.dart';
import 'package:coderats/views/group/screens/group.details.screen.dart';

/// Widget que separa e exibe grupos por role (admin vs member)
/// Carrega os detalhes de cada grupo para determinar o role do usuário atual
class GroupListByRole extends StatefulWidget {
  final List<Group> groups;
  final GroupRepository groupRepository;
  final VoidCallback onGroupChanged;

  const GroupListByRole({
    super.key,
    required this.groups,
    required this.groupRepository,
    required this.onGroupChanged,
  });

  @override
  State<GroupListByRole> createState() => _GroupListByRoleState();
}

class _GroupListByRoleState extends State<GroupListByRole> {
  final Map<String, String?> _groupRoles = {}; // groupId -> role
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroupRoles();
  }

  Future<void> _loadGroupRoles() async {
    final roles = <String, String?>{};
    
    // Busca role de cada grupo
    for (final group in widget.groups) {
      try {
        final details = await widget.groupRepository.getGroupDetails(group.id);
        final currentUserId = SessionManager.instance.currentUserId;
        
        if (details.participants.isEmpty) {
          roles[group.id] = null;
        } else {
          // Encontra o participante atual
          final currentParticipant = details.participants.firstWhere(
            (p) => p.id == currentUserId,
            orElse: () => details.participants.first,
          );
          roles[group.id] = currentParticipant.role;
        }
      } catch (e) {
        roles[group.id] = null;
      }
    }

    if (mounted) {
      setState(() {
        _groupRoles.addAll(roles);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: AppLoading());
    }

    // Separa grupos por role
    final adminGroups = <Group>[];
    final memberGroups = <Group>[];

    for (final group in widget.groups) {
      final role = _groupRoles[group.id];
      if (role == 'admin') {
        adminGroups.add(group);
      } else {
        memberGroups.add(group);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
      children: [
        // Seção: Grupos que você lidera
        if (adminGroups.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.primary, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Grupos que você lidera',
                  style: AppTextStyles.title.copyWith(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...adminGroups.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _GroupCard(
              group: g,
              groupRepository: widget.groupRepository,
              onGroupChanged: widget.onGroupChanged,
            ),
          )),
          if (memberGroups.isNotEmpty) const SizedBox(height: AppSpacing.lg),
        ],

        // Seção: Grupos que você participa
        if (memberGroups.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.group, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Grupos que você participa',
                  style: AppTextStyles.title.copyWith(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...memberGroups.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _GroupCard(
              group: g,
              groupRepository: widget.groupRepository,
              onGroupChanged: widget.onGroupChanged,
            ),
          )),
        ],
      ],
    );
  }
}

/// Widget interno para cada card de grupo
class _GroupCard extends StatefulWidget {
  final Group group;
  final GroupRepository groupRepository;
  final VoidCallback onGroupChanged;

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

    return GroupCard(
      title: widget.group.name,
      imageUrl: widget.group.image,
      expanded: expanded,
      onBannerTap: () async {
        final shouldRefresh = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => GroupDetailPage(
              groupId: widget.group.id,
              groupNamePreview: widget.group.name,
              imageUrlPreview: widget.group.image,
            ),
          ),
        );

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
