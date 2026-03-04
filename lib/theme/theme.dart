import 'package:flutter/material.dart';
import 'glowing_text_theme.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: const Color.fromARGB(255, 0, 153, 10),
    secondary: const Color.fromARGB(255, 0, 119, 4),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade800,
    surfaceBright: Colors.grey.shade700,
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

  actionIconTheme: ActionIconThemeData(
    // Back button icons in all appbars
    backButtonIconBuilder: (BuildContext context) {
      return Icon(
        // Use Icons.arrow_back for Android style, or Icons.arrow_back_ios_new for Apple style, once IOS is implemented
        Icons.arrow_back,
        size: 35.0,
        color: Theme.of(context).colorScheme.secondary,

        // Neon glow
        shadows: [
          Shadow(color: Theme.of(context).colorScheme.primary, blurRadius: 8.0),
          Shadow(
            color: Theme.of(context).colorScheme.primary,
            blurRadius: 16.0,
          ),
        ],
      );
    },
  ),
);
