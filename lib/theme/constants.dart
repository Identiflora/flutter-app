import 'package:flutter/material.dart';

const primaryNeonGreen = Color.fromARGB(255, 0, 177, 9);
const primaryNeonGreenA100 = Color.fromARGB(150, 0, 177, 9);
const secondaryNeonGreen = Color.fromARGB(255, 128, 255, 134);
const secondaryNeonGreenA100 = Color.fromARGB(100, 128, 255, 134);

// --- BORDERS ---
const BorderRadius identifloraBorderRadius = BorderRadius.all(
  Radius.circular(4.0),
);

const OutlineInputBorder identifloraEnabledBorder = OutlineInputBorder(
  borderRadius: identifloraBorderRadius,
  borderSide: BorderSide(color: secondaryNeonGreen, width: 1.5),
);

const OutlineInputBorder identifloraFocusedBorder = OutlineInputBorder(
  borderRadius: identifloraBorderRadius,
  borderSide: BorderSide(color: primaryNeonGreen, width: 2.0),
);

const OutlineInputBorder identifloraDefaultBorder = OutlineInputBorder(
  borderRadius: identifloraBorderRadius,
);

// --- NEON GLOWS (THEME EXTENSION) ---
const List<BoxShadow> identifloraIconGlow = [
  BoxShadow(color: secondaryNeonGreenA100, blurRadius: 1.0, spreadRadius: 1.0),
  BoxShadow(color: primaryNeonGreenA100, blurRadius: 2.0, spreadRadius: 1.0),
];

const List<BoxShadow> identifloraContainerGlow = [
  BoxShadow(color: secondaryNeonGreenA100, blurRadius: 1.0, spreadRadius: 1.0),
  BoxShadow(color: primaryNeonGreenA100, blurRadius: 2.0, spreadRadius: 1.0),
];

// --- APPBAR GLOW ---
const List<Shadow> identifloraBackButtonGlow = [
  BoxShadow(color: secondaryNeonGreenA100, blurRadius: 4.0, spreadRadius: 1.0),
  BoxShadow(color: primaryNeonGreenA100, blurRadius: 8.0, spreadRadius: 2.0),
];

// --- BUTTON CONSTANTS ---
const BorderRadius identifloraButtonRadius = BorderRadius.all(
  Radius.circular(20.0),
);

const List<BoxShadow> identifloraButtonGlow = [
  BoxShadow(color: secondaryNeonGreenA100, blurRadius: 1.0, spreadRadius: 1.0),
  BoxShadow(color: primaryNeonGreenA100, blurRadius: 2.0, spreadRadius: 1.0),
];

// --- DROPDOWN CONSTANTS ---
const List<BoxShadow> identifloraDropdownGlow = [
  BoxShadow(color: secondaryNeonGreenA100, blurRadius: 1.0, spreadRadius: 1.0),
  BoxShadow(color: primaryNeonGreenA100, blurRadius: 2.0, spreadRadius: 1.0),
];

const List<BoxShadow> identifloraDarkHomebuttonShadow = [
  BoxShadow(color: Colors.black, blurRadius: 12),
];

const List<BoxShadow> identifloraLightHomebuttonShadow = [
  BoxShadow(color: Colors.white, blurRadius: 12),
];
