# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run                  # Debug mode (loads .env.development)
flutter run --release        # Release mode (loads .env.production)
flutter build apk            # Build Android APK
flutter analyze              # Lint / static analysis
flutter test                 # Run all tests
flutter test test/foo_test.dart  # Run a single test file
```

Environment setup: copy `.env.example` to `.env.development` and `.env.production`, filling in `API_URL`, `GOOGLE_CLIENT_ID`, and `GOOGLE_SERVER_ID`.

## Architecture

**Identiflora** is a plant identification app. Users capture or upload a plant photo, the app runs on-device ML inference, shows the top 5 species predictions, and lets users compete on leaderboards.

### Key Technology Choices
- **ML inference**: TFLite (`tflite_flutter`) runs fully offline — model at `assets/model/plantnet.tflite`, labels at `assets/model/labels.txt`, 1081 species classes, 224×224 input normalized to PlantNet mean/std. The model dataset is in flux; the label set may not perfectly match the bundled plant images.
- **Plant images**: Species reference images are bundled as local WebP assets at `assets/plant_images/identiflora_one_image_per_plant/`. Use `localPlantAssetPath(scientificName)` from `lib/theme/general_utils.dart` to resolve a name to its asset path. Always use `Image.asset()` with an `errorBuilder` fallback for species images.
- **State management**: `Provider` (only for theme toggling via `ThemeProvider`); all other state is local `StatefulWidget`
- **Backend**: REST API (FastAPI on Koyeb), Bearer token auth stored in `flutter_secure_storage`
- **Auth**: Email/password (SHA-256 hashed) + Google Sign-In

### Identification Flow
Camera/gallery → `DisplayPictureScreen` (confirm photo) → `OfflinePlantService.predict()` (ML inference) → `UserChoiceScreen` (user picks from 5 options) → `ResultsWidget` (correct answer + plant image). If user disputes the result: `TopMatchesWidget` (grid of alternatives) → `DisplayBigPlantScreen` (confirm selection) → `submitIncorrectIdentification()`.

### Navigation & Home Screen
`main.dart` contains `AppSetup` (initializes `ConnService`, builds `MaterialApp` with theme) and `HomeScreen` (a `Stack` with a camera preview and five floating icon buttons: camera center-bottom, leaderboard top-left, account top-right, gallery bottom-left, history bottom-right). All major screens push via `MaterialPageRoute`. One named route exists: `/view_account_screen`.

### Offline Support
`ConnService` (`lib/user_data/offline_utils.dart`) is a singleton initialized in `AppSetup`. It listens to `connectivity_plus` and confirms real connectivity by pinging the production server. When offline, submissions and points are queued to local storage. On reconnect, `_sendDataQueue()` flushes them to the API. Always check `await ConnService().getIsOffline` before making API calls where offline behavior differs.

### Core Code Locations
| Area | Files |
|------|-------|
| ML inference & image preprocessing | `lib/model.dart` (`OfflinePlantService`) |
| All HTTP API calls | `lib/database_utils.dart` |
| Auth token model & custom exceptions | `lib/user_credentials/auth_objects.dart` |
| Theme system (neon extension) | `lib/theme/` |
| Shared utility functions & `LoadingScreen` widget | `lib/theme/general_utils.dart` |
| Badge unlock logic | `lib/user_data/badge_utils.dart` |
| Level/points calculation | `lib/user_data/point_utils.dart` |
| Offline queue & `ConnService` | `lib/user_data/offline_utils.dart` |
| Offline history storage model | `lib/user_data/history_utils.dart` |
| Camera flow | `lib/camera_utils.dart` |
| Identification result & feedback | `lib/guess_result.dart`, `lib/user_guess.dart` |
| Incorrect ID correction flow | `lib/model_incorrect.dart` |
| User profile / alternate profiles | `lib/view_account/` |
| Reusable UI components | `lib/widgets/neon_widgets.dart`, `lib/widgets/button_widgets.dart` |

### Theme
The app uses a custom `NeonTheme` `ThemeExtension`. Access neon colors/shadows via `Theme.of(context).extension<NeonTheme>()`. Light, dark, and system modes are all supported; the toggle lives in `ThemeProvider`. All visuals such as colors and fonts should be drawn from the theme — no hardcoded values.

### API Error Handling
`database_utils.dart` throws `AuthException` (401), `RateLimitException` (429), and `HttpException` for other failures. Callers are expected to catch these specifically.

### Environment Config
`lib/environment.dart` is the single source for runtime config — reads the correct `.env` file based on `kDebugMode` and exposes static getters (`Environment.apiUrl`, etc.).
