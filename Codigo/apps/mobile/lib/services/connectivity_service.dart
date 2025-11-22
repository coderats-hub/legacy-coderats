import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../core/env.dart';

class ConnectivityService {
  Future<bool> isOnline() async {
    final conn = await Connectivity().checkConnectivity();
    if (conn == ConnectivityResult.none) return false;

    try {
      final r = await http
          .get(Uri.parse(Env.baseUrl))
          .timeout(const Duration(seconds: 5));
      return r.statusCode >= 200;
    } catch (_) {
      return false;
    }
  }
}
