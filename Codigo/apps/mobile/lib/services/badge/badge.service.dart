/// Serviço HTTP para consumir endpoints de badges
/// Segue padrão do user.service.dart (StorageService, dotenv, http, timeouts)
import 'dart:convert';
import 'package:coderats/domain/badge/badge.model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:coderats/shared/services/storage.service.dart';

class BadgeService {
  final StorageService _storageService = StorageService();
  final String _baseUrl = dotenv.env['BASE_API_URL'] ?? 'http://localhost:8080';

  /// Busca todos os badges do sistema
  Future<List<Badge>> getAllBadges() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('Token não encontrado');

      final response = await http.get(
        Uri.parse('$_baseUrl/badges'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        return list.map((e) => Badge.fromJson(Map<String, dynamic>.from(e))).toList();
      } else if (response.statusCode == 401) {
        await _storageService.deleteToken();
        throw Exception('Token inválido');
      } else {
        throw Exception('Erro ao buscar badges: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no BadgeService.getAllBadges: $e');
      rethrow;
    }
  }

  /// Busca um badge específico por ID
  Future<Badge?> getBadgeById(String badgeId) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('Token não encontrado');

      final response = await http.get(
        Uri.parse('$_baseUrl/badges/$badgeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return Badge.fromJson(Map<String, dynamic>.from(jsonMap));
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        await _storageService.deleteToken();
        throw Exception('Token inválido');
      } else {
        throw Exception('Erro ao buscar badge: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no BadgeService.getBadgeById: $e');
      rethrow;
    }
  }

  /// Busca badges conquistados pelo usuário atual
  /// Endpoint esperado: GET /users/me/badges (ajuste se sua API usa outro path)
  Future<List<UserBadge>> getBadgesForCurrentUser() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('Token não encontrado');

      final response = await http.get(
        Uri.parse('$_baseUrl/users/me/badges'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        return list.map((e) => UserBadge.fromJson(Map<String, dynamic>.from(e))).toList();
      } else if (response.statusCode == 401) {
        await _storageService.deleteToken();
        throw Exception('Token inválido');
      } else {
        throw Exception('Erro ao buscar badges do usuário: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no BadgeService.getBadgesForCurrentUser: $e');
      rethrow;
    }
  }

  /// Busca badges de um usuário por id (GET /users/{id}/badges)
  Future<List<UserBadge>> getBadgesByUserId(String userId) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('Token não encontrado');

      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/badges'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        return list.map((e) => UserBadge.fromJson(Map<String, dynamic>.from(e))).toList();
      } else if (response.statusCode == 401) {
        await _storageService.deleteToken();
        throw Exception('Token inválido');
      } else {
        throw Exception('Erro ao buscar badges do usuário: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no BadgeService.getBadgesByUserId: $e');
      rethrow;
    }
  }

  /// Exemplo de endpoint para resgatar / marcar badge manualmente (POST /users/me/badges)
  Future<UserBadge> awardBadgeToCurrentUser(String badgeId, {int? points}) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('Token não encontrado');

      final body = <String, dynamic>{
        'badge_id': badgeId,
        if (points != null) 'points': points,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/users/me/badges'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return UserBadge.fromJson(Map<String, dynamic>.from(jsonMap));
      } else if (response.statusCode == 401) {
        await _storageService.deleteToken();
        throw Exception('Token inválido');
      } else {
        throw Exception('Erro ao premiar badge: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no BadgeService.awardBadgeToCurrentUser: $e');
      rethrow;
    }
  }
}
