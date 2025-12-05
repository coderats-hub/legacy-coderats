import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {
  AdHelper._();

  static bool get isMobileSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool get isProdBranch {
    final branch = dotenv.env['GIT_BRANCH'] ?? dotenv.env['BRANCH'] ?? '';
    final env = dotenv.env['ADS_ENV'] ?? '';
    return branch.toLowerCase() == 'main' || env.toLowerCase() == 'prod';
  }

  static String get bannerAdUnitId {
    if (!isMobileSupported) return '';

    final envKey =
        Platform.isAndroid ? 'ADMOB_BANNER_ANDROID' : 'ADMOB_BANNER_IOS';
    final fromEnv = dotenv.env[envKey];
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return isProdBranch ? fromEnv : _testBannerId;
    }

    return _testBannerId;
  }

  static String get _testBannerId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    return '';
  }
}
