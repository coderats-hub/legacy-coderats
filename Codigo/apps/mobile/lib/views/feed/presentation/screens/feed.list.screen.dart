import 'package:flutter/material.dart';
import 'package:app/shared/ads/ad_banner_footer.dart';
import 'package:app/shared/components/components.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/layout/web_max_width.dart';
import '../../domain/feed.dart';
import '../../data/feed.repository.dart';
import '../widgets/feed.card.dart';
import '../../../../services/api_service.dart';
import '../../../../services/http_client.dart';
import '../../../../core/env.dart';
import '../../../../core/session_manager.dart';
import 'package:app/services/local_database.dart';

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
  final Set<String> _likesLoading = {};

  @override
  void initState() {
    super.initState();
    _initRepo();
    _ctrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onScroll);
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _initRepo() async {
    final sessionManager = SessionManager.instance;
    final httpClient = HttpClient(sessionManager);
    final apiService = ApiService(httpClient);
    final db = await LocalDatabase.maybeGetInstance();
    _repo = FeedRepository(apiService, local: db?.feed);
    if (mounted) {
      _loadMore();
    }
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

  Future<void> _toggleLike(FeedItem item) async {
    if (_likesLoading.contains(item.id)) return;
    
    setState(() {
      _likesLoading.add(item.id);
    });
    
    try {
      LikeResponse response;
      if (item.userHasLiked) {
        response = await _repo.unlikeCheckin(item.id);
      } else {
        response = await _repo.likeCheckin(item.id);
      }
      
      if (mounted) {
        setState(() {
          // Atualizar o item na lista
          final index = _items.indexWhere((i) => i.id == item.id);
          if (index != -1) {
            _items[index] = item.copyWith(
              likesCount: response.likesCount,
              userHasLiked: response.userHasLiked,
            );
          }
          _likesLoading.remove(item.id);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _likesLoading.remove(item.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar curtida: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          showBackButton: false,
        ),
        body: const AppLoading(),
        bottomNavigationBar: _buildBottomBar(0),
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
        bottomNavigationBar: _buildBottomBar(0),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Feed',
        showBackButton: false,
      ),
      body: WebMaxWidth(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Column(
          children: [
            if (_loading)
              const LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.primary,
                backgroundColor: AppColors.border,
              ),
            Expanded(
              child: RefreshIndicator(
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
                    return FeedCard(
                      item: item,
                      onLike: () => _toggleLike(item),
                      isLikeLoading: _likesLoading.contains(item.id),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(0),
    );
  }

  Widget _buildBottomBar(int currentIndex) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AdBannerFooter(
          padding: EdgeInsets.only(top: AppSpacing.xs),
        ),
        AppNavbar(
          currentIndex: currentIndex,
          onTap: (i) => _onNavbarTap(context, i),
        ),
      ],
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
