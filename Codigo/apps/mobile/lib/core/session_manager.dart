import 'package:app/domain/user/user.model.dart' as domain;
import 'package:app/shared/services/storage.service.dart';

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
  domain.User? get currentUser => _state.user;
  String? get currentUserId => _state.user?.id;

  Future<void> loadFromStorage() async {
    final storedToken = await _storage.getToken();
    if (storedToken == null) {
      _state = const SessionState();
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
}
