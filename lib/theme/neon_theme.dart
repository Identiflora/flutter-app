import 'package:flutter/material.dart';

class NeonTheme extends ThemeExtension<NeonTheme> {
  final List<BoxShadow>? iconGlow;
  final List<BoxShadow>? containerGlow;
  final int? containerPadding;
  final List<BoxShadow>? buttonGlow;
  final List<BoxShadow>? dropdownGlow;
  final List<BoxShadow>? popupGlow;
  final List<BoxShadow>? homeIconShadow;

  const NeonTheme({
    this.iconGlow,
    this.containerGlow,
    this.containerPadding,
    this.buttonGlow,
    this.dropdownGlow,
    this.popupGlow,
    this.homeIconShadow,
  });

  @override
  NeonTheme copyWith({
    List<BoxShadow>? iconGlow,
    List<BoxShadow>? containerGlow,
    int? containerPadding,
    List<BoxShadow>? buttonGlow,
    List<BoxShadow>? dropdownGlow,
    List<BoxShadow>? popupGlow,
    List<BoxShadow>? homeIconShadow,
  }) {
    return NeonTheme(
      iconGlow: iconGlow ?? this.iconGlow,
      containerGlow: containerGlow ?? this.containerGlow,
      containerPadding: containerPadding ?? this.containerPadding,
      buttonGlow: buttonGlow ?? this.buttonGlow,
      dropdownGlow: dropdownGlow ?? this.dropdownGlow,
      popupGlow: popupGlow ?? this.popupGlow,
      homeIconShadow: homeIconShadow ?? this.homeIconShadow,
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
      popupGlow: BoxShadow.lerpList(popupGlow, other.popupGlow, t),
      homeIconShadow: BoxShadow.lerpList(homeIconShadow, other.homeIconShadow, t)
    );
  }
}
