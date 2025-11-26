import 'package:app/domain/user/user.model.dart';

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final userJson = json['user'];
    if (token is! String || userJson is! Map<String, dynamic>) {
      throw const FormatException('Formato de resposta de token inválido.');
    }
    return AuthResponse(
      token: token,
      user: User.fromJson(userJson),
    );
  }
}
