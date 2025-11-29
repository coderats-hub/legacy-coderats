import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Decide quais variáveis de ambiente usar com base no modo de compilação
class Env {
  Env._();

  static String get baseApiUrl {
    final fromEnv = dotenv.env['BASE_API_URL'];
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv;
    }

    return 'http://localhost:8080';
  }

  static bool get useMockApi {
    final v = dotenv.env['USE_MOCK_API'];
    return v == '1' || v == 'true' || v == 'yes';
  }

  static String get mockApiBaseUrl =>
      'https://virtserver.swaggerhub.com/coderats/code-rats-api/1.2.0';
}
