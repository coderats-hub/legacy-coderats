import 'dart:convert';

import 'package:coderats/domain/user/user.model.dart' as domain;
import 'package:coderats/shared/services/storage.service.dart';

class SessionState {
  final domain.User? user;
  final String? token;

  const SessionState({this.user, this.token});

  bool get isAuthenticated => user != null && token != null;

  String? get userId => user?.id;
}

class SessionManager {
  SessionManager._internal();

  static final SessionManager instance = SessionManager._internal();

  final StorageService _storage = StorageService();
  SessionState _state = const SessionState();

  SessionState get state => _state;

  String? get token => _state.token;
  String? get validToken => _isTokenExpired(_state.token) ? null : _state.token;
  domain.User? get currentUser => _state.user;
  String? get currentUserId => _state.user?.id;

  Future<void> loadFromStorage() async {
    final storedToken = await _storage.getToken();
    if (storedToken == null || _isTokenExpired(storedToken)) {
      await clearSession();
      return;
    }

    _state = SessionState(user: null, token: storedToken);
  }

  Future<void> setSession({
    required String token,
    domain.User? user,
  }) async {
    _state = SessionState(user: user, token: token);
    await _storage.saveToken(token);
  }

  void updateUser(domain.User user) {
    _state = SessionState(user: user, token: _state.token);
  }

  Future<void> clearSession() async {
    _state = const SessionState();
    await _storage.deleteToken();
  }

  bool _isTokenExpired(String? token) {
    if (token == null) return true;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payloadMap = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payloadMap['exp'];
      if (exp is int) {
        final expiry =
            DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
        // pequeno skew para evitar race condition de expiração
        return DateTime.now().toUtc().isAfter(expiry.subtract(const Duration(minutes: 1)));
      }
      return false;
    } catch (_) {
      // Se n��o der para decodificar, n��o invalidar automaticamente
      return false;
    }
  }
}
