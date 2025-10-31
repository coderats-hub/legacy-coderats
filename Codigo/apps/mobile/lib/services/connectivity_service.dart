import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Checagem de conectividade com verificação de internet real.
/// - Primeiro: verifica se há algum tipo de rede (wifi, dados, etc.)
/// - Depois: faz um GET rápido para uma URL de prova.
///   Use uma URL do SEU back/mock, para garantir roteamento até o destino real.
class ConnectivityService {
  /// Use o seu mock do SwaggerHub (HTTPS) para a prova de vida.
  /// Você pode trocar para algum endpoint curtinho e estável do seu mock.
  final Uri probeUri;

  ConnectivityService({
    Uri? probeUri,
  }) : probeUri = probeUri ??
            Uri.parse('https://virtserver.swaggerhub.com/pucminas-1a5/raquelCodeRats/1/users');

  Future<bool> isOnline() async {
    final res = await Connectivity().checkConnectivity();

    final hasNetwork = res == ConnectivityResult.mobile ||
        res == ConnectivityResult.wifi ||
        res == ConnectivityResult.ethernet ||
        res == ConnectivityResult.vpn;

    if (!hasNetwork) return false;

    // Prova de acesso real à internet/servidor (timeout curto).
    try {
      final r = await http
          .get(probeUri, headers: {'Connection': 'close'})
          .timeout(const Duration(seconds: 3));
      // Qualquer 2xx/3xx/4xx indica que chegamos no servidor (internet OK).
      // 5xx geralmente é servidor ruim, mas ainda assim há internet.
      return r.statusCode >= 200 && r.statusCode < 600;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
