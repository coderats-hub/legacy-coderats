import 'dart:convert';
import 'package:coderats/core/env.dart';
import 'package:coderats/domain/user/user.model.dart';
import 'package:http/http.dart' as http;
import 'package:coderats/shared/services/storage.service.dart';

class UserService {
  final StorageService _storageService = StorageService();
  final String _baseUrl = Env.baseApiUrl;

  /// Busca os dados do usuário logado atual
  Future<User?> getCurrentUser() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json', 
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
      } else if (response.statusCode == 401) {
        // Token inválido - remove do storage
        await _storageService.deleteToken();
        throw Exception('Token inválido');
      } else if (response.statusCode == 404) {
        throw Exception('Usuário não encontrado');
      } else {
        throw Exception('Erro ao buscar dados do usuário: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no UserService.getCurrentUser: $e');
      rethrow; // Re-throw todos os erros para tratamento na UI
    }
  }

  /// Busca usuário por ID específico
  Future<User?> getUserById(String userId) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
      } else if (response.statusCode == 404) {
        return null; // Usuário não encontrado
      } else {
        throw Exception('Erro ao buscar usuário: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no UserService.getUserById: $e');
      rethrow;
    }
  }

  /// Busca lista de todos os usuários (se necessário)
  Future<List<User>> getAllUsers() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersData = json.decode(response.body);
        return usersData.map((userData) => User.fromJson(userData)).toList();
      } else {
        throw Exception('Erro ao buscar usuários: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no UserService.getAllUsers: $e');
      rethrow;
    }
  }

  /// Atualiza dados do usuário atual
  Future<User?> updateCurrentUser({
    String? name,
    String? email,
    String? image,
  }) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (image != null) updateData['image'] = image;

      if (updateData.isEmpty) {
        throw Exception('Nenhum dado para atualizar');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        throw Exception('Erro ao atualizar usuário: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no UserService.updateCurrentUser: $e');
      rethrow;
    }
  }
}
