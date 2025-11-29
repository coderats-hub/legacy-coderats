// ==============================
// Arquivo: features/feed/data/feed.repository.dart
// ==============================
//
// Pasta 'data':
// Implementações de repositório / serviços que obtêm/armazenam dados (API, DB, local cache).

import '../domain/feed.dart';
import '../../../services/api_service.dart';
import '../../../services/local_database.dart';
import 'package:app/database/feed/feed.dao.dart';

class FeedRepository {
  final ApiService _apiService;
  final FeedDao? _local;

  FeedRepository(this._apiService, {FeedDao? local}) : _local = local;

  Future<List<FeedItem>> fetchFeedItems({int limit = 20, int offset = 0}) async {
    // Tenta cache imediato
    if (_local != null) {
      final cached = await _local!.getFeed(limit, offset);
      if (cached.isNotEmpty) return cached;
    }

    try {
      final response = await _apiService.getJson('/feed?limit=$limit&offset=$offset');
      
      if (response == null) {
        return [];
      }

      final List<dynamic> feedList = response as List<dynamic>;
      final items = feedList.map((json) => FeedItem.fromJson(json as Map<String, dynamic>)).toList();

      // Cachear
      if (_local != null) {
        await _local!.cacheFeed(items);
      }

      return items;
    } catch (e) {
      print('Erro ao buscar feed: $e');
      // Se erro, tentar cache
      if (_local != null) {
        final fallback = await _local!.getFeed(limit, offset);
        if (fallback.isNotEmpty) return fallback;
      }
      rethrow;
    }
  }

  Future<List<FeedItem>> fetchRecommended({int limit = 20, int offset = 0}) async {
    // Por enquanto retorna o mesmo feed, mas pode ser expandido no futuro
    // quando o backend implementar recomendações baseadas em grafos
    return fetchFeedItems(limit: limit, offset: offset);
  }

  Future<LikeResponse> likeCheckin(String checkinId) async {
    try {
      // Remove espaços e quebras de linha que podem estar no ID
      final cleanId = checkinId.trim().replaceAll(RegExp(r'\s+'), '');
      final url = '/checkins/$cleanId/like';
      
      print('Tentando curtir checkin. ID: "$cleanId", URL: "$url"');
      
      final response = await _apiService.postJson(url, {});
      
      if (response == null) {
        throw Exception('Resposta vazia do servidor');
      }

      print('Resposta do like: $response');
      return LikeResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Erro ao curtir checkin: $e');
      rethrow;
    }
  }

  Future<LikeResponse> unlikeCheckin(String checkinId) async {
    try {
      // Remove espaços e quebras de linha que podem estar no ID
      final cleanId = checkinId.trim().replaceAll(RegExp(r'\s+'), '');
      final url = '/checkins/$cleanId/like';
      
      print('Tentando remover curtida do checkin. ID: "$cleanId", URL: "$url"');
      
      final response = await _apiService.deleteJson(url);
      
      if (response == null) {
        throw Exception('Resposta vazia do servidor');
      }

      print('Resposta do unlike: $response');
      return LikeResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Erro ao remover curtida do checkin: $e');
      rethrow;
    }
  }
}
