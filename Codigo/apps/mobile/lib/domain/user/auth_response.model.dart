class AuthResponse {
  final String token;

  AuthResponse({required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('token')) {
      return AuthResponse(
        token: json['token'] as String,
      );
    } else {
      throw FormatException('Formato de resposta de token inválido.');
    }
  }
}