// ==============================
// Arquivo: features/feed/data/feed.repository.dart
// ==============================
//
// Pasta 'data':
// Implementações de repositório / serviços que obtêm/armazenam dados (API, DB, local cache).
// Este arquivo contém um repositório template com métodos simulados.

import '../domain/feed.dart';

class FeedRepository {
  // Simula paginação infinita: forneça page e pageSize
  Future<List<FeedItem>> fetchFeedItems({required int page, required int pageSize}) async {
    // Simula latência
    await Future.delayed(const Duration(milliseconds: 400));

    final start = page * pageSize;
    final List<FeedItem> list = [];
    for (int i = 0; i < pageSize; i++) {
      final idx = start + i;
      final now = DateTime.now().subtract(Duration(days: idx ~/ 3));
      final bool hasGithub = idx % 3 == 0; // every 3rd item has github (for example)

      list.add(FeedItem(
        id: 'feed_$idx',
  title: hasGithub ? 'titulo atividade Github' : 'Título da Atividade',
        description: hasGithub
            ? 'Descrição curta da atividade integrada com Github.'
            : 'Descrição da atividade aqui. Lorem ipsum dolor sit amet, consectetur.',
        createdAt: now,
        groupName: (idx % 2 == 0) ? 'Code Rats' : 'Outro Usuário',
        userName: 'Nome',
        likes: (idx * 7) % 100,
        comments: (idx * 3) % 20,
        points: (idx % 5) + 1,
        hasGithub: hasGithub,
        githubUrl: hasGithub ? 'https://github.com/example/repo/commit/$idx' : null,
        graphMeta: {'method': 'no-tags', 'nodeId': 'n_$idx'},
      ));
    }

    return list;
  }

  /// Método simulado para retornar recomendações (quando o backend prover
  /// recomendações via grafos). Aqui priorizamos itens que trazem `graphMeta`
  /// com método 'no-tags' para simular um feed recomendado.
  Future<List<FeedItem>> fetchRecommended({required int page, required int pageSize}) async {
    final items = await fetchFeedItems(page: page, pageSize: pageSize);
    // Coloca primeiro itens com graphMeta.method == 'no-tags' (simulação)
    items.sort((a, b) {
      final aHas = a.graphMeta != null && a.graphMeta!['method'] == 'no-tags';
      final bHas = b.graphMeta != null && b.graphMeta!['method'] == 'no-tags';
      return (bHas ? 1 : 0).compareTo(aHas ? 1 : 0);
    });
    return items;
  }
}
