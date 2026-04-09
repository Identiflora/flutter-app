import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get fileName {
    if (kReleaseMode) {
      return '.env.production';
    }
    return '.env.development';
  }

  static String get apiUrl {
    return dotenv.env['API_URL'] ?? 'API_URL not found';
  }

  static String get googleClientID {
    return dotenv.env['GOOGLE_CLIENT_ID'] ?? 'GOOGLE_CLIENT_ID not found';
  }

  static String get googleClientIDIOS {
    return dotenv.env['GOOGLE_CLIENT_ID_IOS'] ?? 'GOOGLE_CLIENT_ID not found';
  }

  static String get googleServerID {
    return dotenv.env['GOOGLE_SERVER_ID'] ?? 'GOOGLE_SERVER_ID not found';
  }

  static String get mapsApiKey {
  return dotenv.env['MAPS_API_KEY'] ?? 'MAPS_API_KEY not found';
}
}