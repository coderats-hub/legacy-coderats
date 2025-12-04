import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {
  AdHelper._();

  static bool get isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static String get bannerAdUnitId {
    if (!isSupportedPlatform) return '';

    final envKey =
        Platform.isAndroid ? 'ADMOB_BANNER_ANDROID' : 'ADMOB_BANNER_IOS';
    final fromEnv = dotenv.env[envKey];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';

    return '';
  }
}
