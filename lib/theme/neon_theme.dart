import 'package:flutter/material.dart';

class NeonTheme extends ThemeExtension<NeonTheme> {
  final List<BoxShadow>? iconGlow;
  final List<BoxShadow>? containerGlow;
  final List<BoxShadow>? buttonGlow;
  final List<BoxShadow>? dropdownGlow;

  const NeonTheme({
    this.iconGlow,
    this.containerGlow,
    this.buttonGlow,
    this.dropdownGlow,
  });

  @override
  NeonTheme copyWith({
    List<BoxShadow>? iconGlow,
    List<BoxShadow>? containerGlow,
    List<BoxShadow>? buttonGlow,
    List<BoxShadow>? dropdownGlow,
  }) {
    return NeonTheme(
      iconGlow: iconGlow ?? this.iconGlow,
      containerGlow: containerGlow ?? this.containerGlow,
      buttonGlow: buttonGlow ?? this.buttonGlow,
      dropdownGlow: dropdownGlow ?? this.dropdownGlow,
    );
  }

  @override
  NeonTheme lerp(ThemeExtension<NeonTheme>? other, double t) {
    if (other is! NeonTheme) return this;
    return NeonTheme(
      iconGlow: BoxShadow.lerpList(iconGlow, other.iconGlow, t),
      containerGlow: BoxShadow.lerpList(containerGlow, other.containerGlow, t),
      buttonGlow: BoxShadow.lerpList(buttonGlow, other.buttonGlow, t),
      dropdownGlow: BoxShadow.lerpList(dropdownGlow, other.dropdownGlow, t),
    );
  }
}
