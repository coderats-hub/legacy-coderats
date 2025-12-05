// Simple AdSense banner embed for Flutter Web.
// Requires env vars:
//  ADSENSE_CLIENT (ex: ca-pub-XXXXXXXX)
//  ADSENSE_SLOT (ad unit/slot id)

import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebAdBanner extends StatefulWidget {
  final EdgeInsetsGeometry? padding;

  const WebAdBanner({super.key, this.padding});

  @override
  State<WebAdBanner> createState() => _WebAdBannerState();
}

class _WebAdBannerState extends State<WebAdBanner> {
  late final String _viewType;
  static bool _scriptLoaded = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'web-ad-banner-${DateTime.now().millisecondsSinceEpoch}-${UniqueKey()}';
    _setupAd();
  }

  bool get _isProd {
    final branch = dotenv.env['GIT_BRANCH'] ?? dotenv.env['BRANCH'] ?? '';
    final env = dotenv.env['ADS_ENV'] ?? '';
    return branch.toLowerCase() == 'main' || env.toLowerCase() == 'prod';
  }

  void _setupAd() {
    if (!kIsWeb) return;

    final client = _isProd
        ? (dotenv.env['ADSENSE_CLIENT'] ?? '')
        : (dotenv.env['ADSENSE_CLIENT_TEST'] ?? dotenv.env['ADSENSE_CLIENT'] ?? '');
    final slot = _isProd
        ? (dotenv.env['ADSENSE_SLOT'] ?? '')
        : (dotenv.env['ADSENSE_SLOT_TEST'] ?? dotenv.env['ADSENSE_SLOT'] ?? '');

    if (client.isEmpty || slot.isEmpty) {
      // No config: register a placeholder factory
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) => html.DivElement()
          ..style.width = '320px'
          ..style.height = '50px'
          ..style.display = 'flex'
          ..style.alignItems = 'center'
          ..style.justifyContent = 'center'
          ..style.color = '#888'
          ..style.backgroundColor = '#1E1E1E'
          ..text = 'Ad (configurar ADSENSE_CLIENT/ADSENSE_SLOT)',
      );
      return;
    }

    if (!_scriptLoaded) {
      final script = html.ScriptElement()
        ..async = true
        ..src = 'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=$client'
        ..setAttribute('crossorigin', 'anonymous');
      html.document.head?.append(script);
      _scriptLoaded = true;
    }

    final container = html.DivElement()
      ..style.width = '100%'
      ..style.display = 'flex'
      ..style.justifyContent = 'center';

    final ins = html.Element.tag('ins')
      ..classes.add('adsbygoogle')
      ..style.display = 'inline-block'
      ..style.width = '320px'
      ..style.height = '50px'
      ..setAttribute('data-ad-client', client)
      ..setAttribute('data-ad-slot', slot);
    container.append(ins);

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) => container);

    try {
      // ignore: avoid_dynamic_calls
      (html.window as dynamic).adsbygoogle ??= [];
      // ignore: avoid_dynamic_calls
      (html.window as dynamic).adsbygoogle.push({});
    } catch (_) {
      // Ignore if ads script not ready yet; AdSense will retry.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: SizedBox(
        height: 50,
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}
