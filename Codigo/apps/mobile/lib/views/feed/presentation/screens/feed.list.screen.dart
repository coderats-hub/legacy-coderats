import 'package:flutter/material.dart';
import 'package:app/shared/components/components.dart';
import 'package:app/shared/theme/app_theme.dart';
import '../../domain/feed.dart';
import '../../data/feed.repository.dart';
import '../widgets/feed.card.dart';
import '../../../../services/api_service.dart';
import '../../../../services/http_client.dart';
import '../../../../core/env.dart';
import '../../../../core/session_manager.dart';

class FeedListScreen extends StatefulWidget {
  const FeedListScreen({Key? key}) : super(key: key);

  @override
  State<FeedListScreen> createState() => _FeedListScreenState();
}

class _FeedListScreenState extends State<FeedListScreen> {
  late final FeedRepository _repo;
  final ScrollController _ctrl = ScrollController();
  final List<FeedItem> _items = [];
  bool _loading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;
  bool _useRecommendations = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final sessionManager = SessionManager.instance;
    final httpClient = HttpClient(sessionManager);
    final apiService = ApiService(httpClient);
    _repo = FeedRepository(apiService);
    _loadMore();
    _ctrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loading || !_hasMore) return;
    if (_ctrl.position.pixels >= _ctrl.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    
    try {
      final newItems = _useRecommendations
          ? await _repo.fetchRecommended(limit: _limit, offset: _offset)
          : await _repo.fetchFeedItems(limit: _limit, offset: _offset);
      
      if (mounted) {
        setState(() {
          // deduplicate by id to avoid repeating same items
          final existingIds = _items.map((e) => e.id).toSet();
          final uniqueNew = newItems.where((it) => !existingIds.contains(it.id)).toList();
          _items.addAll(uniqueNew);
          _offset += uniqueNew.length;
          _hasMore = newItems.length == _limit;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Erro ao carregar feed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se está carregando inicial e não tem itens, mostra loading centralizado
    if (_loading && _items.isEmpty && _errorMessage == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(
          title: 'Feed',
          onBack: () => Navigator.pushReplacementNamed(context, '/onboarding'),
        ),
        body: const AppLoading(),
        bottomNavigationBar: AppNavbar(
          currentIndex: 0,
          onTap: (i) => _onNavbarTap(context, i),
        ),
      );
    }

    // Se tem erro e não tem itens, mostra mensagem de erro
    if (_errorMessage != null && _items.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(
          title: 'Feed',
          onBack: () => Navigator.pushReplacementNamed(context, '/onboarding'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _offset = 0;
                      _hasMore = true;
                    });
                    _loadMore();
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppNavbar(
          currentIndex: 0,
          onTap: (i) => _onNavbarTap(context, i),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Feed',
        onBack: () => Navigator.pushReplacementNamed(context, '/onboarding'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          setState(() {
            _items.clear();
            _offset = 0;
            _hasMore = true;
            _errorMessage = null;
          });
          await _loadMore();
        },
        child: ListView.builder(
          controller: _ctrl,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          itemCount: _items.length + (_loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              return const SizedBox(
                height: 80,
                child: AppLoading(),
              );
            }
            final item = _items[index];
            return FeedCard(item: item);
          },
        ),
      ),
      bottomNavigationBar: AppNavbar(
        currentIndex: 0,
        onTap: (i) => _onNavbarTap(context, i),
      ),
    );
  }

  void _onNavbarTap(BuildContext context, int index) {
    if (index == 0) return; // Já está no feed
    if (index == 1) {
      Navigator.of(context).pushNamed('/groups');
    } else if (index == 2) {
      Navigator.of(context).pushNamed('/profile');
    }
  }
}
