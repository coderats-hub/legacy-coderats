import 'dart:convert';
import 'package:app/domain/checkin/checkin.dart';
import 'package:app/services/http_client.dart';

class CheckinRemoteService {
  final HttpClient http;

  CheckinRemoteService(this.http);

  Future<List<Checkin>> getFeed({int page = 0, int limit = 20}) async {
    final offset = page * limit;
    
    final resp = await http.get('/feed?limit=$limit&offset=$offset');

    if (resp.statusCode != 200) {
      throw Exception('Erro ao carregar feed: ${resp.statusCode}');
    }

    final list = jsonDecode(resp.body) as List;
    return list.map((e) => Checkin.fromJson(e)).toList();
  }

  Future<Checkin> createCheckin({
    required String groupId,
    required String title,
    String? description,
    String? image, 
  }) async {
    final body = {
      'title': title,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
    };

    final resp = await http.post('/groups/$groupId/checkins', body);

    if (resp.statusCode != 201) {
      throw Exception('Erro ao criar check-in: ${resp.statusCode}');
    }

    return Checkin.fromJson(jsonDecode(resp.body));
  }

  Future<void> likeCheckin(String checkinId) async {
    final resp = await http.post('/checkins/$checkinId/like', {});
    if (resp.statusCode != 201 && resp.statusCode != 409) {
      throw Exception('Erro ao curtir: ${resp.statusCode}');
    }
  }

  Future<void> unlikeCheckin(String checkinId) async {
    final resp = await http.delete('/checkins/$checkinId/like');
    if (resp.statusCode != 204) {
      throw Exception('Erro ao descurtir: ${resp.statusCode}');
    }
  }
}