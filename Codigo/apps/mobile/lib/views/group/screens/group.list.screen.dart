import 'package:app/domain/group/group.dart';
import 'package:app/domain/group/group_details.dart';
import 'package:app/repositories/group.repository.dart';
import 'package:app/services/http_client.dart';
import 'package:app/services/local_database.dart';
import 'package:app/views/group/screens/group.create.screen.dart';
import 'package:flutter/material.dart';

import 'package:app/core/session_manager.dart';
import 'package:app/services/group/group_remote_service.dart';
import 'package:app/services/connectivity_service.dart';

import 'package:app/views/group/widgets/card.group.dart';

class GroupListScreen extends StatefulWidget {
  // Removemos os parâmetros obrigatórios do construtor
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  Future<List<Group>>? _futureGroups;
  bool _online = true;
  
  // Dependências que vamos instanciar aqui dentro
  GroupRepository? _groupRepository;
  ConnectivityService? _connectivity;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _initDependenciesAndLoad();
  }

  // Monta as dependências (Injeção de dependência manual)
  Future<void> _initDependenciesAndLoad() async {
    try {
      final session = SessionManager.instance;
      final localDb = await LocalDatabase.getInstance();
      final connectivity = ConnectivityService();
      final httpClient = HttpClient(session);
      final remoteService = GroupRemoteService(httpClient);
      
      final repository = GroupRepository(
        remote: remoteService,
        local: localDb.groups,
        net: connectivity,
        session: session,
      );

      if (mounted) {
        setState(() {
          _groupRepository = repository;
          _connectivity = connectivity;
          _initializing = false;
        });
        // Agora que temos o repositório, carregamos os dados
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

    // Carrega grupos
    final groupsFuture = _groupRepository!.getUserGroups();

    if (mounted) {
      setState(() {
        _futureGroups = groupsFuture;
      });
    }

    // Carrega detalhes em background
    final groups = await groupsFuture;
    Future.microtask(() async {
      for (final g in groups) {
        if (_groupRepository != null) {
          await _groupRepository!.getGroupDetails(g.id);
        }
      }
    });
  }

  Future<void> _pullToRefresh() async {
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    // Se estiver inicializando as dependências, mostra loading
    if (_initializing) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Meus Grupos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: _online
          ? FloatingActionButton(
              backgroundColor: Colors.blue, // Ajuste para sua cor primária
              onPressed: () {
                // Navega para criar grupo e recarrega ao voltar
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                ).then((_) => _reload());
              },
              child: const Icon(Icons.add, color: Colors.white),
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
                  Icon(Icons.wifi_off, color: Colors.amber, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sem conexão — exibindo cache (somente leitura)',
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

                        if (snap.hasError) {
                           return Center(
                             child: Text(
                               'Erro ao carregar: ${snap.error}',
                               style: const TextStyle(color: Colors.red),
                             ),
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
                                  'Nenhum grupo no momento.\nCrie um novo para começar!',
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
                            // Passamos o repositório que instanciamos para o card
                            return _GroupCard(
                              group: g,
                              groupRepository: _groupRepository!,
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
          'Sem cache de ranking (abra online uma vez).',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Supondo que você tem o widget CardGroup ou GroupCard importado
    return GroupCard(
      title: widget.group.name,
      imageUrl: widget.group.image,
      // Se não tiver BannerStyle no seu projeto, remova ou adapte
      // bannerStyle: widget.group.status ? BannerStyle.primary : BannerStyle.tertiary,
      // status: widget.group.status ? GroupStatus.ativo : GroupStatus.concluido,
      expanded: expanded,
      onBannerTap: () async {
        try {
          // Se ainda não carregou detalhes, carrega agora ao clicar
          final d = _details ?? await widget.groupRepository.getGroupDetails(widget.group.id);
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _GroupDetailsPage(details: d),
            ),
          );
        } catch (_) {
           // Tratar erro ou apenas não navegar
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
    // Ordena participantes
    final participants = [...details.participants]
      ..sort((a, b) => b.points.compareTo(a.points));

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
              name: leader.name,
              points: leader.points,
              color: Colors.amber, // Usando cor fixa se não tiver theme
            ),
          ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Ranking',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(top3.length, (i) {
          final row = top3[i];
          final pos = i + 1;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                 backgroundImage: row.image != null ? NetworkImage(row.image!) : null,
                 child: row.image == null ? Text(row.name[0]) : null,
              ),
              title: Text(
                row.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${row.points.toStringAsFixed(1)} pontos',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.emoji_events, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          labelLeft,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(
          '${points.toStringAsFixed(1)} pts',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes')),
        body: const Center(
          child: Text('Sem detalhes disponíveis.'),
        ),
      );
    }

    final g = details!.group;
    final p = details!.participants;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(g.name, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: p.length,
        itemBuilder: (context, i) {
          final row = p[i];
          return Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: row.image != null ? NetworkImage(row.image!) : null,
                child: row.image == null ? Text('${i + 1}') : null,
              ),
              title: Text(
                row.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${row.points.toStringAsFixed(1)} pontos',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}