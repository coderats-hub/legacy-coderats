/**
 * Tela de Detalhes do Grupo (GroupDetailPage)
 * 
 * NAVEGAÇÃO: Acessível via tap nos cards da lista de grupos
 * 
 * FUNÇÃO:
 * - Exibe informações completas de um grupo específico
 * - Mostra banner customizável, descrição expansível e ranking de membros
 * - Lista check-ins do grupo com paginação infinita por data
 * - Permite criação de novos check-ins e navegação para ranking completo
 * 
 * COMPONENTES PRINCIPAIS:
 * - BannerHero: Banner do grupo com imagem ou style personalizado
 * - _DescriptionAccordion: Descrição expansível do grupo
 * - _RankingTile: Membros do top 3 ranking
 * - _CheckinTile: Cards de check-ins agrupados por dia
 * - AppFAB: Botão para criar novo check-in
 * 
 * RECURSOS:
 * - Scroll infinito para carregar mais check-ins
 * - Agrupamento de check-ins por data
 * - Código do grupo copiável
 * - Navegação contextual para ranking e detalhes de check-in
 * 
 * FLUXOS DE NAVEGAÇÃO:
 * - Para ranking completo → group.ranking.screen.dart
 * - Para lista de check-ins → checkin.list.screen.dart  
 * - Para criar check-in → checkin.details.screen.dart
 * - Para perfil de membro → public.profile.screen.dart
 */

import 'dart:async';
import 'package:app/features/group/presentation/widgets/banner.group.dart';
import 'package:app/features/profile/presentation/screens/public.profile.screen.dart';
import 'package:app/features/checkin/presentation/screens/checkin.details.screen.dart';
import 'package:app/features/checkin/presentation/screens/checkin.list.screen.dart';
import 'package:app/features/group/presentation/screens/group.edit.screen.dart';
import 'package:app/features/group/presentation/screens/group.ranking.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';

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
  bool _descOpen = false; // Controla se a descrição está expandida

  // Controladores para paginação infinita de check-ins
  final _scrollCtrl = ScrollController();
  final List<Checkin> _items = []; // Lista de check-ins carregados
  bool _loading = false; // Estado de carregamento
  bool _hasMore = true; // Controla se há mais dados para carregar
  int _page = 0; // Página atual para paginação

  @override
  void initState() {
    super.initState();
    _loadMore(); // Carrega primeira página de check-ins
    _scrollCtrl.addListener(_onScroll); // Detecta scroll para paginação
  }

  @override
  void dispose() {
    _scrollCtrl.dispose(); // Remove listeners para evitar memory leaks
    super.dispose();
  }

  // Detecta quando o usuário se aproxima do final da lista
  void _onScroll() {
    if (_loading || !_hasMore) return;
    // Carrega mais quando está 300px do final
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  // Carrega mais check-ins (simulação de API com delay)
  Future<void> _loadMore() async {
    setState(() => _loading = true);

    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 600));

    const pageSize = 20;
    final newItems = _generateCheckins(_page, pageSize);
    _page++;

    if (mounted) {
      setState(() {
        _items.addAll(newItems); // Adiciona novos itens à lista
        _hasMore = newItems.length == pageSize; // Para se retornar menos que pageSize
        _loading = false;
      });
    }
  }

  // Gera check-ins mock para demonstração (substituto de API)
  List<Checkin> _generateCheckins(int page, int size) {
    final List<Checkin> list = [];
    final startIndex = page * size;
    for (int i = 0; i < size; i++) {
      final idx = startIndex + i;
      final dayOffset = (idx ~/ 5); // Agrupa 5 check-ins por dia
      final date = DateTime.now().subtract(Duration(days: dayOffset));
      list.add(
        Checkin(
          title: "Lorem ipsum dolor et siamet",
          author: (idx % 2 == 0) ? "Você" : "Alice", // Alterna autor
          points: (idx % 5) + 1, // Pontos de 1 a 5
          date: DateTime(date.year, date.month, date.day), 
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // Agrupa check-ins por data para exibição organizada
    final grouped = _groupByDay(_items);

    // Constrói lista linear de cabeçalhos e itens para ListView
    final List<_Row> rows = [];
    for (final entry in grouped.entries) {
      rows.add(_Row.header(entry.key)); // Cabeçalho da data
      for (final c in entry.value) {
        rows.add(_Row.item(c)); // Check-ins dessa data
      }
    }
    if (_loading) rows.add(_Row.loader()); // Loader no final se carregando

    return Scaffold(
      // Header com nome do grupo e menu de opções
      appBar: AppHeader(
        title: widget.groupName,
        onBack: () => Navigator.of(context).pop(),
        actions: [
          // Menu de 3 pontos com opções
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupEditScreen(
                        initialName: widget.groupName, 
                        initialDescription: null, 
                        imageUrl: widget.imageUrl
                      ),
                    ),
                  );
                  break;
                case 'delete':
                  // TODO: Implementar exclusão de grupo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidade de exclusão será implementada')),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Editar grupo'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Excluir grupo'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),

      // Scroll principal com banner, descrição, ranking e check-ins
      body: ListView(
        controller: _scrollCtrl, // Para paginação infinita
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          // Banner do grupo (imagem ou estilo colorido)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: BannerHero(
              imageUrl: widget.imageUrl,
              style: widget.bannerStyle,
              height: 128,
              radius: AppCorners.lg,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Código do grupo (clicável para copiar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _GroupCodeWidget(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Descrição expansível do grupo
          _DescriptionAccordion(
            open: _descOpen,
            onToggle: () => setState(() => _descOpen = !_descOpen),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                "Aqui vai a descrição do grupo. Você pode inserir "
                "orientações, links e qualquer detalhe relevante.", // TODO: Usar descrição dinâmica
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Seção de ranking (top 3 membros)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text("Ranking", style: AppTextStyles.title.copyWith(fontSize: 18, color: Colors.white)),
          ),
          const SizedBox(height: AppSpacing.md),
          // Top 3 membros do ranking
          _RankingTile(name: 'Alice', points: '49.5 pontos', pos: '1st'),
          _RankingTile(name: 'Felipe', points: '45.5 pontos', pos: '2st'),
          _RankingTile(name: 'Gustavo', points: '45.5 pontos', pos: '3st'),
          const SizedBox(height: AppSpacing.xs),
          // Chip para ver ranking completo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _RankingChip(
                label: 'Todo Ranking',
                onTap: () {
                  // Navega para tela de ranking completo
                  Navigator.of(context).pushNamed('/group-ranking');
                },
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Seção de check-ins com header e link para visualização detalhada
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Check-ins", style: AppTextStyles.title.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    // Navega para lista completa de check-ins
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CheckinScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Visualizar com detalhes',
                    style: TextStyle(
                      color: Color(0xFF7DCDC1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Lista de check-ins agrupados por data com paginação infinita
          ...rows.map((r) {
            if (r.type == _RowType.header) {
              return _DayHeader(date: r.date!); // Cabeçalho da data
            } else if (r.type == _RowType.item) {
              return _CheckinTile(c: r.item!); // Card do check-in
            } else {
              // Loader no final quando carregando mais itens
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: AppLoading(),
              );
            }
          }).toList(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
      // Botão flutuante para criar novo check-in neste grupo
      floatingActionButton: AppFAB(
        onPressed: () {
          // Navega para tela de criação de check-in
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CommitCheckinScreen(),
            ),
          );
        },
        icon: Icons.add,
        tooltip: 'Novo check-in',
      ),
      // Barra de navegação inferior - grupos permanece ativo
      bottomNavigationBar: AppNavbar(
        currentIndex: 1, // Mantém grupos como aba ativa
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pushNamed('/feed');
          } else if (i == 2) {
            Navigator.of(context).pushNamed('/profile');
          }
          // i == 1 é grupos, já está nessa tela
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.3),
        borderRadius: BorderRadius.circular(AppCorners.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: UserAvatarInfo(
              label: name,
              subtitle: points,
              avatarRadius: 18,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PublicProfileScreen(),
                  ),
                );
              },
            ),
          ),
          Text(pos, style: AppTextStyles.title.copyWith(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}

/**
 * Chip clicável para ações relacionadas ao ranking
 * 
 * Usado principalmente para navegar para a tela de ranking completo.
 * Design oval com cor primária e feedback visual de toque.
 */
class _RankingChip extends StatelessWidget {
  final String label; // Ex: 'Todo Ranking'
  final VoidCallback onTap; // Ação ao clicar
  const _RankingChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withOpacity(0.2), // Fundo semi-transparente
      shape: const StadiumBorder(), // Formato oval
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            label,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 11),
          ),
        ),
      ),
    );
  }
}

/**
 * Cabeçalho de data para agrupar check-ins
 * 
 * Exibe a data formatada (ex: "01 de Set") para separar
 * visualmente os check-ins por dia na lista.
 */
class _DayHeader extends StatelessWidget {
  final DateTime date;
  const _DayHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    // Formata data como "01 de Set"
    final formatted =
        "${_two(date.day)} de ${_monthName(date.month)}";
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xs),
      child: Text(formatted, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
    );
  }

  // Helper para formatar dia com 2 dígitos
  String _two(int n) => n.toString().padLeft(2, '0');
  
  // Helper para converter mês numérico em abreviação
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
                  Text(c.title, style: AppTextStyles.title.copyWith(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
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

/// Widget para exibir o código do grupo com efeito de toque
class _GroupCodeWidget extends StatefulWidget {
  @override
  State<_GroupCodeWidget> createState() => _GroupCodeWidgetState();
}

class _GroupCodeWidgetState extends State<_GroupCodeWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () async {
        await Clipboard.setData(const ClipboardData(text: 'AWECVEW'));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código copiado para área de transferência!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isPressed 
              ? const Color(0xFF7DCDC1).withOpacity(0.1) 
              : Colors.transparent,
            borderRadius: BorderRadius.circular(AppCorners.sm),
            border: Border.all(
              color: _isPressed 
                ? const Color(0xFF7DCDC1).withOpacity(0.8)
                : const Color(0xFF7DCDC1)
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.copy_all_rounded, 
                size: 18, 
                color: _isPressed 
                  ? const Color(0xFF7DCDC1).withOpacity(0.8)
                  : const Color(0xFF7DCDC1)
              ),
              const SizedBox(width: 8),
              Text(
                'Código: AWECVEW', // TODO: Usar código dinâmico do grupo
                style: AppTextStyles.subtitle.copyWith(
                  color: _isPressed 
                    ? const Color(0xFF7DCDC1).withOpacity(0.8)
                    : const Color(0xFF7DCDC1),
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
