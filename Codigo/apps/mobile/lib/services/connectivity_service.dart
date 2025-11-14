import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Connectivity with real server probe (works better on emulators/BlueStacks).
class ConnectivityService {
  // Point the probe to your mock’s base (any lightweight endpoint is fine).
  final Uri probeUri;

  ConnectivityService({Uri? probe})
      : probeUri = probe ??
            Uri.parse(
              'https://virtserver.swaggerhub.com/pucminas-1a5/raquelCodeRats/1/users',
            );

  Future<bool> isOnline() async {
    final res = await Connectivity().checkConnectivity();

    // If there’s absolutely no transport, bail out early.
    final hasTransport = res != ConnectivityResult.none;
    if (!hasTransport) return false;

    // Prove we can actually reach the server (3s timeout).
    try {
      final r = await http
          .get(probeUri, headers: {'Connection': 'close'})
          .timeout(const Duration(seconds: 3));
      // Any HTTP response means “internet reachable”, even 404/500.
      return r.statusCode >= 200 && r.statusCode < 600;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // Optional: quick logger to see what BlueStacks reports.
  Future<void> debugLog() async {
    final res = await Connectivity().checkConnectivity();
    print('[Connectivity] transport: $res');
    try {
      final r = await http.get(probeUri).timeout(const Duration(seconds: 3));
      print('[Connectivity] probe status: ${r.statusCode}');
    } catch (e) {
      print('[Connectivity] probe error: $e');
    }
  }
}
