import 'package:flutter/material.dart';
import 'package:app/shared/components/components.dart';
import 'package:app/shared/theme/app_theme.dart';
import '../../domain/feed.dart';
import '../../data/feed.repository.dart';
import '../widgets/feed.card.dart';

class FeedListScreen extends StatefulWidget {
  const FeedListScreen({Key? key}) : super(key: key);

  @override
  State<FeedListScreen> createState() => _FeedListScreenState();
}

class _FeedListScreenState extends State<FeedListScreen> {
  final FeedRepository _repo = FeedRepository();
  final ScrollController _ctrl = ScrollController();
  final List<FeedItem> _items = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _pageSize = 10;
  bool _useRecommendations = false; // toggle to request recommended feed (graph) if available

  @override
  void initState() {
    super.initState();
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
    setState(() => _loading = true);
    final newItems = _useRecommendations
        ? await _repo.fetchRecommended(page: _page, pageSize: _pageSize)
        : await _repo.fetchFeedItems(page: _page, pageSize: _pageSize);
    _page++;
    if (mounted) {
      setState(() {
        // deduplicate by id to avoid repeating same items
        final existingIds = _items.map((e) => e.id).toSet();
        final uniqueNew = newItems.where((it) => !existingIds.contains(it.id)).toList();
        _items.addAll(uniqueNew);
        _hasMore = newItems.length == _pageSize;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se está carregando inicial e não tem itens, mostra loading centralizado
    if (_loading && _items.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(
          title: 'Feed',
          showBackButton: false,
        ),
        body: const AppLoading(),
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
        showBackButton: false,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          setState(() {
            _items.clear();
            _page = 0;
            _hasMore = true;
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
