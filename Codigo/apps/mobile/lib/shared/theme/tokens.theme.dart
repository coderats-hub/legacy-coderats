import 'dart:ui';
import 'package:flutter/material.dart';

@immutable
class Spacing extends ThemeExtension<Spacing> {
  final double xs, sm, md, lg, xl, xxl;
  const Spacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
  });

  @override
  Spacing copyWith({double? xs, double? sm, double? md, double? lg, double? xl, double? xxl}) {
    return Spacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  Spacing lerp(ThemeExtension<Spacing>? other, double t) {
    if (other is! Spacing) return this;
    return Spacing(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
    );
  }
}

@immutable
class Corners extends ThemeExtension<Corners> {
  final double sm, md, lg, pill;
  const Corners({this.sm = 6, this.md = 10, this.lg = 16, this.pill = 999});

  @override
  Corners copyWith({double? sm, double? md, double? lg, double? pill}) {
    return Corners(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      pill: pill ?? this.pill,
    );
  }

  @override
  Corners lerp(ThemeExtension<Corners>? other, double t) {
    if (other is! Corners) return this;
    return Corners(
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      pill: lerpDouble(pill, other.pill, t)!,
    );
  }
}

class AppPalette {
  static const primary   = Color(0xFFD283FF);
  static const secondary = Color(0xFF25A18E);
  static const tertiary  = Color(0xFFEB8462);

  static const background      = Color(0xFF222222);
  static const surface         = Color(0xFF2F2F2F);
  static const surfaceVariant  = Color(0xFF2A2A2A);
  static const divider         = Color(0xFF3A3A3A);

  static const success = Color(0xFF2EB872);
  static const warning = Color(0xFFF2A900);
  static const danger   = Color(0xFFB43232);

  static const textPrimary   = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textDisabled  = Color(0xFF777777);
}
