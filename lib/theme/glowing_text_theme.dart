import 'package:flutter/material.dart';

class GlowingTextTheme extends ThemeExtension<GlowingTextTheme> {
  final TextStyle? glowingText;

  const GlowingTextTheme({this.glowingText});

  @override
  ThemeExtension<GlowingTextTheme> copyWith({TextStyle? glowingText}) {
    return GlowingTextTheme(
      glowingText: glowingText ?? this.glowingText,
    );
  }

  @override
  ThemeExtension<GlowingTextTheme> lerp(ThemeExtension<GlowingTextTheme>? other, double t) {
    if (other is! GlowingTextTheme) return this;
    return GlowingTextTheme(
      // lerp allows the style to animate smoothly if you switch themes
      glowingText: TextStyle.lerp(glowingText, other.glowingText, t),
    );
  }
}