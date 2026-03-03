import 'package:flutter/material.dart';
import 'glowing_text_theme.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Colors.green.shade900,
    secondary: Colors.green,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade800,
    primary: const Color.fromARGB(255, 0, 177, 9),
    secondary: const Color.fromARGB(255, 128, 255, 134),
    onSurface: Colors.grey.shade300,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey.shade300,
    displayColor: Colors.grey.shade300,
  ),
  extensions: <ThemeExtension<dynamic>>[
    const GlowingTextTheme(
      glowingText: TextStyle(
        color: Color.fromARGB(255, 128, 255, 134), // secondary color
        shadows: [
          Shadow(
            color: Color.fromARGB(255, 0, 177, 9), // primary color
            blurRadius: 5.0,
          ),
          Shadow(
            color: Color.fromARGB(255, 0, 177, 9), // primary color
            blurRadius: 10.0,
          ),
        ],
      ),
    ),
  ],
);

// ThemeData darkMode = ThemeData(
//   brightness: Brightness.dark,
//   colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 1, 46, 4)),
// );
