import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:identiflora/gallery_utils.dart';
import 'package:identiflora/history.dart';
import 'package:identiflora/friends_utils.dart';
import 'package:identiflora/leaderboard_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'package:identiflora/user_data/offline_utils.dart';
import 'package:identiflora/user_data/user_data_service.dart';
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

  LicenseRegistry.addLicense(() async* {
    List<String> licenses = getLicenses();

    yield LicenseEntryWithLineBreaks(
      ['GBIF Pl@ntNet Observations Dataset'],
      'This data was used to train the AI model.\nAFFOUARD A, JOLY A, LOMBARDO J, CHAMP J, GOEAU H, CHOUET M, GRESSE H, BONNET P (2025). Pl@ntNet observations. Version 1.9. Pl@ntNet. Occurrence dataset https://doi.org/10.15468/gtebaa accessed via GBIF.org on 2026-04-16. Licensed under CC BY 4.0.',
    );
    yield LicenseEntryWithLineBreaks(
      ['MobileNet V2 (PyTorch)'],
      'Used for AI model training.\nCopyright (c) Soumith Chintala 2016. Licensed under BSD 3-Clause.\n\n${licenses[0]}',
    );
    yield LicenseEntryWithLineBreaks(
      ['LiteRT'],
      'Used for AI model mobile conversion.\nCopyright 2024 The LiteRT Authors. Licensed under Apache 2.0.\n\n${licenses[1]}',
    );
  });

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const AppSetup(),
    ),
  );
}

// Camera startup logic

class AppSetup extends StatefulWidget {
  const AppSetup({super.key});

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<AppSetup> {
  final ConnService _connService = ConnService();

  @override
  void initState() {
    _connService.init();
    UserDataService().init();
    super.initState();
  }

  @override
  void dispose() {
    _connService.dispose();
    super.dispose();
  }

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
          FriendsHomescreenButton()
        ],
      ),
    );
  }
}