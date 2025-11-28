import 'dart:convert';
import 'package:app/domain/user/auth_response.model.dart';
import 'package:app/domain/user/user.model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/core/session_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app/services/http_client.dart';
import 'package:app/services/local_database.dart';
import 'package:app/services/user/user_remote_service.dart';

class AuthService {
  Future<bool> exchangeCodeForToken(String code) async {
    final String baseUrl = dotenv.env['BASE_API_URL'] ?? 'http://localhost:8080';
    final Uri uri = Uri.parse('$baseUrl/auth/exchange');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'login_code': code,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        
        final authResponse = AuthResponse.fromJson(responseBody);
        
        // Salva o token primeiro
        await SessionManager.instance.setSession(
          token: authResponse.token,
          user: null, // Ainda não temos o user
        );
        
        // Agora busca os dados do usuário usando o token
        await _fetchAndUpdateCurrentUser(authResponse.token, baseUrl);
        await _refreshLocalUsersCache();
        
        return true;
      } else {
        throw Exception('Falha ao trocar o código: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no AuthService: $e');
      rethrow;
    }
  }

  Future<void> _fetchAndUpdateCurrentUser(String token, String baseUrl) async {
    final Uri uri = Uri.parse('$baseUrl/users/me');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        final user = User.fromJson(userData);
        
        // Atualiza o SessionManager com os dados do usuário
        SessionManager.instance.updateUser(user);
      }
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    }
  }
  Future<void> _refreshLocalUsersCache() async {
    if (kIsWeb) return;
    try {
      final localDb = await LocalDatabase.maybeGetInstance();
      if (localDb == null) return;
      final httpClient = HttpClient(SessionManager.instance);
      final userRemote = UserRemoteService(httpClient);
      final users = await userRemote.getAllUsers();
      await localDb.groups.cacheUsers(users);
    } catch (e) {
      print('Erro ao sincronizar usu�rios locais: ');
    }
  }
}
