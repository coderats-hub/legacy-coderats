import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Constrains width on web to avoid ultra-wide layouts while leaving mobile intact.
class WebMaxWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const WebMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = 1100,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
