import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:coderats/core/session_manager.dart';
import 'package:coderats/services/connectivity_service.dart';

class DataEnvironment {
  final bool isWeb;
  final bool isOnline;
  final bool hasLocalDb;
  final String? currentUserId;

  const DataEnvironment({
    required this.isWeb,
    required this.isOnline,
    required this.hasLocalDb,
    required this.currentUserId,
  });

  bool get remoteOnly => isWeb || !hasLocalDb;

  bool get isOfflineOnMobile => !isWeb && !isOnline && hasLocalDb;

  @override
  String toString() {
    return 'DataEnvironment('
        'isWeb: $isWeb, '
        'isOnline: $isOnline, '
        'hasLocalDb: $hasLocalDb, '
        'currentUserId: $currentUserId'
        ')';
  }
}

class DataEnvironmentProvider {
  final ConnectivityService _connectivity;

  DataEnvironmentProvider(this._connectivity);

  Future<DataEnvironment> detect() async {
    final online = await _connectivity.isOnline();
    final isWeb = kIsWeb;

    final hasLocalDb = !isWeb;

    final session = SessionManager.instance.state;

    return DataEnvironment(
      isWeb: isWeb,
      isOnline: online,
      hasLocalDb: hasLocalDb,
      currentUserId: session.userId,
    );
  }
}
