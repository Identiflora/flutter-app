import 'package:flutter/material.dart';
import 'neon_theme.dart';
import 'constants.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    surfaceBright: Colors.grey.shade300,
    primary: const Color.fromARGB(255, 0, 153, 10),
    secondary: const Color.fromARGB(255, 0, 119, 4),
  ),
);

const primaryNeonGreen = Color.fromARGB(255, 0, 177, 9);
const secondaryNeonGreen = Color.fromARGB(255, 128, 255, 134);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,

  // Color pallete used across application
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade800,
    surfaceBright: Colors.grey.shade700,
    primary: primaryNeonGreen,
    secondary: secondaryNeonGreen,
    onSurface: Colors.grey.shade300,
  ),

  // Defines text color for all text
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey.shade300,
    displayColor: Colors.grey.shade300,
  ),

  // Automatically applied to all TextFields and Dropdowns
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade800,
    enabledBorder: identifloraEnabledBorder,
    focusedBorder: identifloraFocusedBorder,
    border: identifloraDefaultBorder,
  ),

  iconTheme: IconThemeData(
    color: secondaryNeonGreen,
    shadows: identifloraBackButtonGlow, //reusing same glow for back button
  ),

  // Automatically applied to all outlined buttons
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.grey.shade800, // surface color
      foregroundColor: Colors.grey.shade300, // onSurface color
      side: const BorderSide(color: secondaryNeonGreen, width: 1.5),
      shape: const RoundedRectangleBorder(
        borderRadius: identifloraButtonRadius,
      ),
    ),
  ),

  // Custom shadows for neon effects
  extensions: const <ThemeExtension<dynamic>>[
    NeonTheme(
      iconGlow: identifloraIconGlow,
      containerGlow: identifloraContainerGlow,
      buttonGlow: identifloraButtonGlow,
      dropdownGlow: identifloraDropdownGlow,
      popupGlow: identifloraIconGlow,
    ),
  ],

  actionIconTheme: ActionIconThemeData(
    // Makes all back buttons neon
    backButtonIconBuilder: (BuildContext context) {
      return Icon(
        Icons.arrow_back,
        size: 35.0,
        color: Theme.of(context).colorScheme.secondary,
        shadows: identifloraBackButtonGlow,
      );
    },
  ),
);
