import 'package:flutter/material.dart';

const primaryNeonGreen = Color.fromARGB(255, 0, 177, 9);
const secondaryNeonGreen = Color.fromARGB(255, 128, 255, 134);

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
  BoxShadow(color: secondaryNeonGreen, blurRadius: 4.0, spreadRadius: 1.0),
  BoxShadow(color: primaryNeonGreen, blurRadius: 10.0, spreadRadius: 1.0),
];

const List<BoxShadow> identifloraContainerGlow = [
  BoxShadow(color: secondaryNeonGreen, blurRadius: 4.0, spreadRadius: 1.0),
  BoxShadow(color: primaryNeonGreen, blurRadius: 10.0, spreadRadius: 1.0),
];

// --- APPBAR GLOW ---
const List<Shadow> identifloraBackButtonGlow = [
  Shadow(color: primaryNeonGreen, blurRadius: 8.0),
  Shadow(color: primaryNeonGreen, blurRadius: 16.0),
];

// --- BUTTON CONSTANTS ---
const BorderRadius identifloraButtonRadius = BorderRadius.all(
  Radius.circular(20.0),
);

const List<BoxShadow> identifloraButtonGlow = [
  BoxShadow(color: secondaryNeonGreen, blurRadius: 4.0, spreadRadius: 1.0),
  BoxShadow(color: primaryNeonGreen, blurRadius: 10.0, spreadRadius: 1.0),
];

// --- DROPDOWN CONSTANTS ---
const List<BoxShadow> identifloraDropdownGlow = [
  BoxShadow(color: secondaryNeonGreen, blurRadius: 4.0, spreadRadius: 1.0),
  BoxShadow(color: primaryNeonGreen, blurRadius: 10.0, spreadRadius: 1.0),
];
