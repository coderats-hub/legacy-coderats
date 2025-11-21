import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupService {
  final String baseUrl = 'https://virtserver.swaggerhub.com/coderats/code-rats-api/1.3.0';
  final String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJhMWIyYzNkNC1lNWY2LTc4OTAtMTIzNC01Njc4OTBhYmNkZWYifQ.token";

  Future<List<Map<String, dynamic>>> fetchGroups() async {
    final url = Uri.parse('$baseUrl/users/me/groups');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado: token inválido ou expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('Acesso proibido: você não tem permissão para ver os grupos.');
      } else if (response.statusCode == 500) {
        throw Exception('Erro interno no servidor. Tente novamente mais tarde.');
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erro ao buscar grupos: $e');
      throw Exception('Erro ao buscar grupos: $e');
    }
  }
}
