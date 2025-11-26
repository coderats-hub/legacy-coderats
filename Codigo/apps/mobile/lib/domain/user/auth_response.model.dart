import 'package:app/domain/user/user.model.dart';

class AuthResponse {
  final String token;
  final User? user;

  AuthResponse({
    required this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    if (token is! String) {
      throw const FormatException('Formato de resposta de token inválido.');
    }

    final userJson = json['user'];
    User? user;
    if (userJson is Map<String, dynamic>) {
      user = User.fromJson(userJson);
    }

    return AuthResponse(
      token: token,
      user: user,
    );
  }
}
