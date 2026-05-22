import 'package:flutter_dotenv/flutter_dotenv.dart';

// Decide quais variáveis de ambiente usar com base no modo de compilação
class Env {
  Env._();

  static String get baseApiUrl {
    const fromBuild = String.fromEnvironment('BASE_API_URL');
    if (fromBuild.isNotEmpty) {
      return _trimTrailingSlash(fromBuild);
    }

    final fromEnv = dotenv.env['BASE_API_URL'];
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return _trimTrailingSlash(fromEnv);
    }

    return 'http://localhost:8080';
  }

  static bool get useMockApi {
    const fromBuild = String.fromEnvironment('USE_MOCK_API');
    if (fromBuild.isNotEmpty) {
      return _isTruthy(fromBuild);
    }

    final v = dotenv.env['USE_MOCK_API'];
    return _isTruthy(v);
  }

  static bool get devAuthBypass {
    const fromBuild = String.fromEnvironment('DEV_AUTH_BYPASS');
    if (fromBuild.isNotEmpty) {
      return _isTruthy(fromBuild);
    }

    final v = dotenv.env['DEV_AUTH_BYPASS'];
    return _isTruthy(v);
  }

  static String get mockApiBaseUrl =>
      'https://virtserver.swaggerhub.com/coderats/code-rats-api/1.2.0';

  static String _trimTrailingSlash(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  static bool _isTruthy(String? value) {
    final normalized = value?.trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }
}
