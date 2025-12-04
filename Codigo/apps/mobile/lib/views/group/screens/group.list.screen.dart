import 'package:app/database/group/group.dao.dart';
import 'package:app/repositories/group.repository.dart';
import 'package:app/services/http_client.dart';
import 'package:app/services/local_database.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/ads/ad_banner_footer.dart';

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
import 'package:app/views/group/widgets/group_list_by_role.dart';
import 'package:app/views/group/widgets/card.group.dart';

// --- IMPORTS DE UTILS ---
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
        actions: [LogoutButton()],
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
                        // Ordenar grupos por nome em ordem alfabética
                        groups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

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

                        return GroupListByRole(
                          groups: groups,
                          groupRepository: _groupRepository!,
                          onGroupChanged: _reload,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerFooter(
            padding: EdgeInsets.only(top: AppSpacing.xs),
          ),
          AppNavbar(
            currentIndex: 1, // Grupos = index 1
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacementNamed('/feed');
              } else if (index == 2) {
                Navigator.of(context).pushReplacementNamed('/profile');
              }
              // Se index == 1, ja esta na tela de grupos
            },
          ),
        ],
      ),
    );
  }
}
