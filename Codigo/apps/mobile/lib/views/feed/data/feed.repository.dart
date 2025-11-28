// ==============================
// Arquivo: features/feed/data/feed.repository.dart
// ==============================
//
// Pasta 'data':
// Implementações de repositório / serviços que obtêm/armazenam dados (API, DB, local cache).

import '../domain/feed.dart';
import '../../../services/api_service.dart';
import '../../../core/env.dart';

class FeedRepository {
  final ApiService _apiService;

  FeedRepository(this._apiService);

  Future<List<FeedItem>> fetchFeedItems({int limit = 20, int offset = 0}) async {
    try {
      final response = await _apiService.getJson('/feed?limit=$limit&offset=$offset');
      
      if (response == null) {
        return [];
      }

      final List<dynamic> feedList = response as List<dynamic>;
      return feedList.map((json) => FeedItem.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Erro ao buscar feed: $e');
      rethrow;
    }
  }

  Future<List<FeedItem>> fetchRecommended({int limit = 20, int offset = 0}) async {
    // Por enquanto retorna o mesmo feed, mas pode ser expandido no futuro
    // quando o backend implementar recomendações baseadas em grafos
    return fetchFeedItems(limit: limit, offset: offset);
  }
}
