import 'dart:async';
import 'package:app/features/group/presentation/widgets/banner.group.dart';
import 'package:app/features/profile/presentation/screens/public.profile.screen.dart';
import 'package:app/features/profile/presentation/screens/private.profile.screen.dart';
import 'package:app/features/checkin/presentation/screens/checkin.details.screen.dart';
import 'package:app/features/checkin/presentation/screens/checkin.list.screen.dart';
import 'package:app/features/group/presentation/screens/group.edit.screen.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupName;
  final String? imageUrl; 
  final BannerStyle bannerStyle;

  const GroupDetailPage({
    super.key,
    required this.groupName,
    this.imageUrl,
    this.bannerStyle = BannerStyle.tertiary,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  bool _descOpen = false;

  final _scrollCtrl = ScrollController();
  final List<Checkin> _items = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loading || !_hasMore) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 600));

    const pageSize = 20;
    final newItems = _generateCheckins(_page, pageSize);
    _page++;

    if (mounted) {
      setState(() {
        _items.addAll(newItems);
        _hasMore = newItems.length == pageSize; 
        _loading = false;
      });
    }
  }

  List<Checkin> _generateCheckins(int page, int size) {
    // Base: hoje - offsetDias
    final List<Checkin> list = [];
    final startIndex = page * size;
    for (int i = 0; i < size; i++) {
      final idx = startIndex + i;
      final dayOffset = (idx ~/ 5); 
      final date = DateTime.now().subtract(Duration(days: dayOffset));
      list.add(
        Checkin(
          title: "Lorem ipsum dolor et siamet",
          author: (idx % 2 == 0) ? "Você" : "Alice",
          points: (idx % 5) + 1,
          date: DateTime(date.year, date.month, date.day), 
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
  // final cs = Theme.of(context).colorScheme;
  // final tt = Theme.of(context).textTheme;

    final grouped = _groupByDay(_items);

    final List<_Row> rows = [];
    for (final entry in grouped.entries) {
      rows.add(_Row.header(entry.key));
      for (final c in entry.value) {
        rows.add(_Row.item(c));
      }
    }
    if (_loading) rows.add(_Row.loader());

    return Scaffold(
      appBar: AppHeader(
        title: widget.groupName,
        onBack: () => Navigator.of(context).maybePop(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupEditScreen(initialName: widget.groupName, initialDescription: null, imageUrl: widget.imageUrl),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: AppColors.textPrimary, size: 20),
            tooltip: 'Editar',
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, color: AppColors.textPrimary),
            tooltip: 'Excluir',
          ),
          const SizedBox(width: AppSpacing.xs),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.copy_all_rounded, size: 18, color: AppColors.accent),
            label: Text(
              'Código: AWECVEW',
              style: AppTextStyles.subtitle.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),

      body: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: BannerHero(
              imageUrl: widget.imageUrl,
              style: widget.bannerStyle,
              height: 128,
              radius: AppCorners.lg,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          _DescriptionAccordion(
            open: _descOpen,
            onToggle: () => setState(() => _descOpen = !_descOpen),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                "Aqui vai a descrição do grupo. Você pode inserir "
                "orientações, links e qualquer detalhe relevante.",
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text("Ranking", style: AppTextStyles.title),
          ),
          const SizedBox(height: AppSpacing.md),
          _RankingTile(name: 'Alice', points: '49.5 pontos', pos: '1st'),
          _RankingTile(name: 'Felipe', points: '45.5 pontos', pos: '2st'),
          _RankingTile(name: 'Gustavo', points: '45.5 pontos', pos: '3st'),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _RankingChip(
                label: 'Todo Ranking',
                onTap: () {
                  Navigator.of(context).pushNamed('/group-ranking');
                },
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Check-ins", style: AppTextStyles.title),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CheckinScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Visualizar com detalhes',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Lista linear com cabeçalhos e itens
          ...rows.map((r) {
            if (r.type == _RowType.header) {
              return _DayHeader(date: r.date!);
            } else if (r.type == _RowType.item) {
              return _CheckinTile(c: r.item!);
            } else {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          }).toList(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
      floatingActionButton: AppFAB(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CommitCheckinScreen(),
            ),
          );
        },
        icon: Icons.add,
        tooltip: 'Novo check-in',
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
    );
  }

  Map<DateTime, List<Checkin>> _groupByDay(List<Checkin> items) {
    final map = <DateTime, List<Checkin>>{};
    for (final c in items) {
      map.putIfAbsent(c.date, () => []).add(c);
    }
    // Ordena por data desc
    final sortedKeys = map.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    final linked = <DateTime, List<Checkin>>{};
    for (final k in sortedKeys) {
      linked[k] = map[k]!;
    }
    return linked;
  }
}

class Checkin {
  final String title;
  final String author;
  final int points;
  final DateTime date;
  Checkin({
    required this.title,
    required this.author,
    required this.points,
    required this.date,
  });
}

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

class _DescriptionAccordion extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  const _DescriptionAccordion({
    required this.open,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
  // final cs = Theme.of(context).colorScheme;
  // final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppCorners.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Ver Descrição',
                    style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                Icon(
                  open ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: child,
            ),
            crossFadeState:
                open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  final String name;
  final String points;
  final String pos;
  const _RankingTile({
    required this.name,
    required this.points,
    required this.pos,
  });

  @override
  Widget build(BuildContext context) {
  // final cs = Theme.of(context).colorScheme;
  // final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.sm),
          const CircleAvatar(radius: 18, backgroundColor: AppColors.accentLight),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PublicProfileScreen(),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.none,
                    fontSize: 16,
                  )),
                  Text(points,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Text(pos, style: AppTextStyles.title.copyWith(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _RankingChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _RankingChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // final cs = Theme.of(context).colorScheme;
    // final tt = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface.withOpacity(.2),
      shape: StadiumBorder(side: BorderSide(color: AppColors.border, width: .6)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Text(
            label,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final DateTime date;
  const _DayHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    // final tt = Theme.of(context).textTheme;
    final formatted =
        "${_two(date.day)} de ${_monthName(date.month)}"; // ex.: 01 de Set
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xs),
      child: Text(formatted, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _monthName(int m) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[m - 1];
  }
}

class _CheckinTile extends StatelessWidget {
  final Checkin c;
  const _CheckinTile({required this.c});

  @override
  Widget build(BuildContext context) {
    // final cs = Theme.of(context).colorScheme;
    // final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface, // card dos check-ins
          borderRadius: BorderRadius.circular(AppCorners.md),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 18, backgroundColor: AppColors.border),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title, style: AppTextStyles.title.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(c.author,
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.textSecondary,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Text("${c.points} pnts", style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
