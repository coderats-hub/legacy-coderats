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
        _items.addAll(newItems);
        _hasMore = newItems.length == _pageSize; // simulation
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Home',
        actions: [
          IconButton(
            tooltip: 'Alternar recomendações',
            icon: Icon(_useRecommendations ? Icons.star : Icons.star_border),
            onPressed: () async {
              setState(() {
                _useRecommendations = !_useRecommendations;
                _items.clear();
                _page = 0;
                _hasMore = true;
              });
              await _loadMore();
            },
          )
        ],
      ),
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
      floatingActionButton: AppFAB(
        onPressed: () {
          // placeholder: abrir tela de novo check-in
        },
      ),
      bottomNavigationBar: AppNavbar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) {
            // already here
          } else if (i == 1) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const _GroupsPlaceholder()));
          } else if (i == 2) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PrivateProfileScreenPlaceholder()));
          }
        },
      ),
    );
  }
}

// Placeholders used for navigation targets to avoid importing heavy files here.
// They match the existing app routing in other screens which use pushReplacement.
class _GroupsPlaceholder extends StatelessWidget {
  const _GroupsPlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Grupos')));
}

class PrivateProfileScreenPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Perfil')));
}
