// ==============================
// Arquivo: features/feed/presentation/screens/feed.list.screen.dart
// ==============================
// Tela template para listar itens do feed.

import 'package:flutter/material.dart';
import 'package:app/shared/components/app_components.dart';
import 'package:app/shared/theme/app_theme.dart';
import '../../domain/feed.dart';
import '../../data/feed.repository.dart';
import '../widgets/feed.card.dart';
import 'package:app/features/group/presentation/screens/group.list.screen.dart';
import 'package:app/features/profile/presentation/screens/private.profile.screen.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.lg, AppSpacing.sm, AppSpacing.sm),
          itemCount: _items.length + (_loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final item = _items[index];
            return FeedCard(item: item);
          },
        ),
      ),
      // FAB removed as requested
      bottomNavigationBar: AppNavbar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) {
            // already here
          } else if (i == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const GroupsPage()),
            );
          } else if (i == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => PrivateProfileScreen()),
            );
          }
        },
      ),
    );
  }
}
