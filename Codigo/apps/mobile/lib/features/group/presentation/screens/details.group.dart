import 'dart:async';
import 'package:app/features/group/presentation/widgets/banner.group.dart';
import 'package:app/features/profile/presentation/screens/public.profile.dart';
import 'package:app/features/checkin/presentation/screens/details.checkin.dart';
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
      appBar: AppBar(
        title: Text(widget.groupName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir',
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.copy_all_rounded, size: 18),
            label: Text(
              'Código: AWECVEW',
              style: tt.labelLarge?.copyWith(color: cs.secondary),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BannerHero(
              imageUrl: widget.imageUrl,
              style: widget.bannerStyle,
              height: 128,
              radius: 16,
            ),
          ),
          const SizedBox(height: 8),

          _DescriptionAccordion(
            open: _descOpen,
            onToggle: () => setState(() => _descOpen = !_descOpen),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Aqui vai a descrição do grupo. Você pode inserir "
                "orientações, links e qualquer detalhe relevante.",
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Ranking", style: tt.titleLarge),
          ),
          const SizedBox(height: 12),
          _RankingTile(name: 'Alice', points: '49.5 pontos', pos: '1st'),
          _RankingTile(name: 'Felipe', points: '45.5 pontos', pos: '2st'),
          _RankingTile(name: 'Gustavo', points: '45.5 pontos', pos: '3st'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Check-ins", style: tt.titleLarge),
          ),
          const SizedBox(height: 8),

          // Lista linear com cabeçalhos e itens
          ...rows.map((r) {
            if (r.type == _RowType.header) {
              return _DayHeader(date: r.date!);
            } else if (r.type == _RowType.item) {
              return _CheckinTile(c: r.item!);
            } else {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          }).toList(),
          const SizedBox(height: 24),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CommitCheckinScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // “Grupos”
        onTap: (i) {},
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.groups_2_outlined), label: 'Grupos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Ver Descrição',
                    style:
                        tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                Icon(
                  open ? Icons.expand_less : Icons.expand_more,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 10),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const CircleAvatar(radius: 18, backgroundColor: Colors.white24),
          const SizedBox(width: 10),
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
                  Text(name, style: tt.bodyLarge?.copyWith(
                    color: Color(0xFF9A24DD), // Roxo padrão
                    decoration: TextDecoration.none,
                  )),
                  Text(points,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(pos, style: tt.titleMedium),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: cs.secondaryContainer.withOpacity(.2),
      shape: StadiumBorder(side: BorderSide(color: cs.outline, width: .6)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: tt.labelMedium?.copyWith(color: cs.onSurface),
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
    final tt = Theme.of(context).textTheme;
    final formatted =
        "${_two(date.day)} de ${_monthName(date.month)}"; // ex.: 01 de Set
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Text(formatted, style: tt.labelLarge),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface, // card dos check-ins
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 18, backgroundColor: Colors.white24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title, style: tt.bodyLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cs.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(c.author,
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Text("${c.points} pnts", style: tt.labelLarge),
          ],
        ),
      ),
    );
  }
}
