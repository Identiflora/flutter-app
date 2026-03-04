// Don't know where to put this but during refactoring/optimization we should create some default
// styles for things like colors, buttons, text formatting etc. I believe it goes in the main app
// build function in main like how the theme is, but lmk what y'all think

// ^ especially for default padding

import 'package:flutter/material.dart';
import 'package:identiflora/gallery_utils.dart';
import 'package:identiflora/leaderboard_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:identiflora/view_account/view_account_utils.dart';
import 'package:provider/provider.dart';
import 'camera_utils.dart';
import 'account_utils.dart';
import 'environment.dart';
import 'package:identiflora/theme/theme.dart';
import 'package:identiflora/theme/theme_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: Environment.fileName);
  debugPrint('Using environment file: ${Environment.fileName}');
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const AppSetup(),
    ),
  );
}

// Camera startup logic
class AppSetup extends StatelessWidget {
  const AppSetup({super.key});

  // Determine if camera is accessible
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: "Identiflora",
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {'/view_account_screen': (context) => ViewAccountScreen()},
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          getCameraWidget(),
          LoginWidget(),
          GalleryWidget(),
          LeaderboardWidget(),
        ],
      ),
    );
  }
}

// Temporary loading screen for the model. This should be moved to a new utils file or replaced with the appropriate code when created

// We can probably delete this now --Mark
class ModelLoadingScreen extends StatelessWidget {
  const ModelLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Please wait...\nIdentifying your plant!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
