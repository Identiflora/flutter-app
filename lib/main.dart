import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:identiflora/gallery_utils.dart';
import 'package:identiflora/history.dart';
import 'package:identiflora/leaderboard_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:identiflora/view_account/view_account_utils.dart';
import 'package:provider/provider.dart';
import 'camera_utils.dart';
import 'user_credentials/account_utils.dart';
import 'environment.dart';
import 'package:identiflora/theme/theme.dart';
import 'package:identiflora/theme/theme_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: Environment.fileName);
  debugPrint('Using environment file: ${Environment.fileName}');
  
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
          AccountWidget(),
          GalleryWidget(),
          LeaderboardWidget(),
          HistoryWidget()
        ],
      ),
    );
  }
}