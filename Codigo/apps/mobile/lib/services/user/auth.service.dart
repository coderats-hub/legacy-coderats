import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/user/domain/models/auth_response.model.dart';
import 'package:app/shared/services/storage.service.dart';

class AuthService {
  final StorageService _storageService = StorageService();

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

        await _storageService.saveToken(authResponse.token);
        
        return true;
      } else {
        throw Exception('Falha ao trocar o código: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no AuthService: $e');
      rethrow;
    }
  }
}