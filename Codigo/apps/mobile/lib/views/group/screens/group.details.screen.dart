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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core & Database
import 'package:app/core/session_manager.dart';
import 'package:app/database/checkin/checkin.dao.dart';

// Domain Models
import 'package:app/domain/checkin/checkin.dart';
import 'package:app/domain/checkin/checkin_author.dart';
import 'package:app/domain/group/group.dart';
import 'package:app/domain/group/group_details.dart';

// Repositories
import 'package:app/repositories/checkin.repository.dart';
import 'package:app/repositories/group.repository.dart';

// Services
import 'package:app/services/checkin/checkin_remote_service.dart';
import 'package:app/services/connectivity_service.dart';
import 'package:app/services/group/group_remote_service.dart';
import 'package:app/services/http_client.dart';
import 'package:app/services/local_database.dart';

// Shared Components & Theme
import 'package:app/shared/components/components.dart';
import 'package:app/shared/theme/app_theme.dart';

// Views - Widgets & Screens
import 'package:app/views/checkin/screens/checkin.details.screen.dart';
import 'package:app/views/checkin/screens/checkin.list.screen.dart';
import 'package:app/views/group/screens/group.edit.screen.dart';
import 'package:app/views/group/screens/group.ranking.screen.dart';
import 'package:app/views/group/widgets/banner.group.dart';
import 'package:app/views/profile/screens/public.profile.screen.dart';


class GroupDetailPage extends StatefulWidget {
  // Agora recebemos o ID do grupo para buscar os dados frescos
  final String groupId; 
  // Opcionais: Dados "pré-carregados" para exibir enquanto carrega o resto
  final String? groupNamePreview;
  final String? imageUrlPreview; 
  final BannerStyle bannerStyle;

  const GroupDetailPage({
    super.key,
    required this.groupId,
    this.groupNamePreview,
    this.imageUrlPreview,
    this.bannerStyle = BannerStyle.tertiary,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  // --- DEPENDÊNCIAS ---
  GroupRepository? _groupRepository;
  CheckinRepository? _checkinRepository;
  
  // --- ESTADO DA TELA ---
  GroupDetails? _details; // Dados completos do grupo + participantes
  bool _isLoadingDetails = true;
  bool _descOpen = false;

  // --- ESTADO DOS CHECK-INS (PAGINAÇÃO) ---
  final _scrollCtrl = ScrollController();
  final List<Checkin> _items = [];
  bool _loadingCheckins = false;
  bool _hasMoreCheckins = true;
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

  // 1. Inicializa Repositórios
  Future<void> _initDependencies() async {
    final session = SessionManager.instance;
    final localDb = await LocalDatabase.maybeGetInstance();
    final connectivity = ConnectivityService();
    final httpClient = HttpClient(session);
    
    // Configura Group Repo
    final groupRemote = GroupRemoteService(httpClient);
    final groupRepo = GroupRepository(
      remote: groupRemote,
      local: localDb?.groups,
      net: connectivity,
      session: session,
    );

    // Configura Checkin Repo (Usando o que criamos nos passos anteriores)
    final checkinRemote = CheckinRemoteService(httpClient);
    // Nota: Precisamos instanciar o CheckinDao. 
    // Assumindo que localDb expõe o database raw ou criamos um getter lá.
    final checkinDao = localDb != null ? CheckinDao(localDb.raw) : null; 
    
    final checkinRepo = CheckinRepository(
      remote: checkinRemote,
      local: checkinDao,
      net: connectivity,
    );

    if (mounted) {
      setState(() {
        _groupRepository = groupRepo;
        _checkinRepository = checkinRepo;
      });
      // Inicia carregamento dos dados
      _loadGroupDetails();
      _loadCheckins();
    }
  }

  // 2. Carrega Detalhes do Grupo (Header + Ranking)
  Future<void> _loadGroupDetails() async {
    try {
      final details = await _groupRepository!.getGroupDetails(widget.groupId);
      if (mounted) {
        setState(() {
          _details = details;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar grupo: $e');
      if (mounted) setState(() => _isLoadingDetails = false);
    }
  }

  // 3. Carrega Check-ins (Simulando feed do grupo)
  // Nota: A API Docs mostrava POST /groups/{id}/checkins, mas não um GET específico paginado.
  // Aqui vamos assumir que existe um método ou usaremos o feed geral filtrado (simulação).
  Future<void> _loadCheckins() async {
    if (_loadingCheckins || !_hasMoreCheckins || _checkinRepository == null) return;
    
    setState(() => _loadingCheckins = true);

    try {
      // TODO: Substituir por chamada real: await _checkinRepository!.getGroupCheckins(widget.groupId, page: _page);
      // Como ainda não implementamos filtro por grupo no Repo, vou simular um delay e retornar lista vazia ou mock
      // para não quebrar a UI que você quer ver.
      
      await Future.delayed(const Duration(seconds: 1)); // Simula rede
      
      // Se fosse real:
      // final newItems = await _checkinRepository!.getCheckinsByGroup(widget.groupId, offset: _page * 20);
      
      // Mock temporário usando a Classe REAL de domínio
      final newItems = _page < 2 ? _generateMockCheckinsDomain(_page) : <Checkin>[];

      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _page++;
          _hasMoreCheckins = newItems.length >= 5; // Exemplo de limite
          _loadingCheckins = false;
        });
      }
    } catch (e) {
      debugPrint('Erro checkins: $e');
      if (mounted) setState(() => _loadingCheckins = false);
    }
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      _loadCheckins();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Agrupa check-ins reais por data
    final grouped = _groupByDay(_items);

    final List<_Row> rows = [];
    for (final entry in grouped.entries) {
      rows.add(_Row.header(entry.key));
      for (final c in entry.value) {
        rows.add(_Row.item(c));
      }
    }
    if (_loadingCheckins) rows.add(_Row.loader());

    // Dados para exibição (Prioriza dados carregados da API, senão usa preview)
    final displayName = _details?.group.name ?? widget.groupNamePreview ?? 'Carregando...';
    final displayImage = _details?.group.image ?? widget.imageUrlPreview;
    final displayDesc = _details?.group.description ?? 'Sem descrição disponível.';
    final displayCode = _details?.group.code ?? '---';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: displayName,
        onBack: () => Navigator.of(context).maybePop(),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (value) {
              if (value == 'edit' && _details != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GroupEditScreen(
                      initialName: displayName, 
                      initialDescription: displayDesc, 
                      imageUrl: displayImage
                    ),
                  ),
                );
              } else if(value == 'delete' && _details != null) {
                  // TODO: Implementar exclusão de grupo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidade de exclusão será implementada')),
                  );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Editar grupo')]),
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

      body: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          // Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: BannerHero(
              imageUrl: displayImage,
              style: widget.bannerStyle,
              height: 128,
              radius: AppCorners.lg,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Código
          if (!_isLoadingDetails)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _GroupCodeWidget(code: displayCode),
            ),
          const SizedBox(height: AppSpacing.lg),

          // Descrição
          _DescriptionAccordion(
            open: _descOpen,
            onToggle: () => setState(() => _descOpen = !_descOpen),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                displayDesc,
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Ranking (Dados Reais)
          if (!_isLoadingDetails && _details != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text("Ranking", style: AppTextStyles.title.copyWith(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Lógica de Ranking: Ordenar participantes por pontos
            Builder(builder: (context) {
              final participants = List.of(_details!.participants);
              participants.sort((a, b) => b.points.compareTo(a.points)); // Maior para menor
              final top3 = participants.take(3).toList();

              if (top3.isEmpty) {
                 return const Padding(
                   padding: EdgeInsets.all(16.0),
                   child: Text("Nenhum participante pontuou ainda.", style: TextStyle(color: Colors.white54)),
                 );
              }

              return Column(
                children: top3.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  return _RankingTile(
                    name: member.name,
                    points: '${member.points.toStringAsFixed(0)} pontos', // Arredonda
                    pos: '${index + 1}º',
                    imageUrl: member.image,
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _RankingChip(
                  label: 'Ver Todo Ranking',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GroupRankingScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

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
          if (_items.isEmpty && !_loadingCheckins)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text("Nenhum check-in registrado.", style: TextStyle(color: Colors.white38))),
            ),

          ...rows.map((r) {
            if (r.type == _RowType.header) {
              return _DayHeader(date: r.date!);
            } else if (r.type == _RowType.item) {
              return _CheckinTile(c: r.item!);
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

  // Helper para gerar dados falsos porem usando a classe de Dominio real
  List<Checkin> _generateMockCheckinsDomain(int page) {
    return List.generate(5, (i) {
      final date = DateTime.now().subtract(Duration(days: page));
      return Checkin(
        id: "mock-$page-$i",
        title: "Check-in simulado #$i",
        description: "Descrição do checkin de teste",
        points: (i + 1) * 10,
        createdAt: date,
        author: CheckinAuthor(id: "u$i", name: i % 2 == 0 ? "Você" : "Alice", image: null),
        likesCount: i,
      );
    });
  }

  Map<DateTime, List<Checkin>> _groupByDay(List<Checkin> items) {
    final map = <DateTime, List<Checkin>>{};
    for (final c in items) {
      // Normaliza data para remover horas/minutos
      final dateKey = DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
      map.putIfAbsent(dateKey, () => []).add(c);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    final linked = <DateTime, List<Checkin>>{};
    for (final k in sortedKeys) {
      linked[k] = map[k]!;
    }
    return linked;
  }
}

// --- WIDGETS AUXILIARES (Ajustados para o Domínio Real) ---

enum _RowType { header, item, loader }
class _Row {
  final _RowType type;
  final DateTime? date;
  final Checkin? item;
  _Row.header(this.date) : type = _RowType.header, item = null;
  _Row.item(this.item) : type = _RowType.item, date = null;
  _Row.loader() : type = _RowType.loader, date = null, item = null;
}

class _CheckinTile extends StatelessWidget {
  final Checkin c;
  const _CheckinTile({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: GestureDetector(
        onTap: () {
          // Navegar para detalhes do checkin
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppCorners.md),
          ),
          child: Row(
            children: [
              // Avatar do Autor do Check-in
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
                child: c.author.image != null 
                    ? ClipOval(child: Image.network(c.author.image!, fit: BoxFit.cover))
                    : Center(child: Text(c.author.name[0], style: const TextStyle(color: Colors.white))),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, 
                        style: AppTextStyles.title.copyWith(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle)),
                        const SizedBox(width: AppSpacing.xs),
                        Text(c.author.name, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("+${c.points}", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 12, color: Colors.redAccent),
                      const SizedBox(width: 2),
                      Text("${c.likesCount}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCodeWidget extends StatefulWidget {
  final String code;
  const _GroupCodeWidget({required this.code});

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
        await Clipboard.setData(ClipboardData(text: widget.code));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código copiado!'), duration: Duration(seconds: 1)),
          );
        }
      },
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFF7DCDC1).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppCorners.sm),
            border: Border.all(color: const Color(0xFF7DCDC1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.copy_all_rounded, size: 18, color: Color(0xFF7DCDC1)),
              const SizedBox(width: 8),
              Text(
                'Código: ${widget.code}', 
                style: AppTextStyles.subtitle.copyWith(color: const Color(0xFF7DCDC1), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Mantivemos os outros widgets auxiliares (_DescriptionAccordion, _RankingTile, etc)
// apenas atualizados para aceitar imagens reais se necessário.
class _DescriptionAccordion extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;
  final Widget child;
  const _DescriptionAccordion({required this.open, required this.onToggle, required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppCorners.sm),
            child: Row(
              children: [
                Expanded(child: Text('Ver Descrição', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary))),
                Icon(open ? Icons.expand_less : Icons.expand_more, color: AppColors.textSecondary),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: child),
            crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
  final String? imageUrl;
  const _RankingTile({required this.name, required this.points, required this.pos, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface.withOpacity(.3), borderRadius: BorderRadius.circular(AppCorners.md)),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18, 
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                  child: imageUrl == null ? Text(name[0]) : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(points, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          Text(pos, style: AppTextStyles.title.copyWith(fontSize: 16, color: Colors.white)),
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
    return Material(
      color: AppColors.primary.withOpacity(0.2),
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(label, style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 11)),
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
    final formatted = "${date.day.toString().padLeft(2, '0')} de ${_monthName(date.month)}";
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xs),
      child: Text(formatted, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
    );
  }
  String _monthName(int m) => ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'][m - 1];
}
