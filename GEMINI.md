# Identiflora - Gemini CLI Context

Identiflora is a specialized plant identification application built with Flutter, designed for enthusiasts and botanists. It leverages on-device machine learning for offline plant identification and features a distinctive neon-themed user interface.

## Project Overview

*   **Main Technology:** Flutter (Dart)
*   **Machine Learning:** TFLite (`tflite_flutter`) for offline plant species identification.
*   **Authentication:** Dual-mode authentication via Google Sign-In and custom Email/Password (SHA-256 hashed).
*   **State Management:** `provider` for theme and state handling.
*   **Backend Integration:** Communicates with the Identiflora API and Database (separate repositories).
*   **Architecture:**
    *   `lib/main.dart`: Application entry point and high-level routing.
    *   `lib/model.dart`: Core ML logic, handling image preprocessing and TFLite inference.
    *   `lib/environment.dart`: Manages environment-specific configurations via `.env` files.
    *   `lib/camera_utils.dart`: Custom camera implementation and image capture workflows.
    *   `lib/theme/`: Custom "Neon" theme implementation using `ThemeExtension`.
    *   `Model/`: Python-based data pipeline for formatting GBIF/Pl@ntNet datasets.

## Building and Running

### Prerequisites

*   **Flutter SDK:** Ensure you are on a compatible version (check `pubspec.yaml`).
*   **Python:** Version 3.10+ for data formatting scripts in the `Model/` directory.
*   **Environment Files:** Create `.env.development` and `.env.production` based on `.env.example`.

### Key Commands

*   **Run Development:** `flutter run` (Automatically selects `.env.development`)
*   **Run Release:** `flutter run --release` (Automatically selects `.env.production`)
*   **Build Android:** `flutter build apk` (Requires keystore setup, see `README.md`)
*   **Install Python Dependencies:** `pip install -r requirements.txt` (within the `.venv` or global environment)
*   **Data Formatting:**
    ```bash
    python .\Model\data_formatting\format_gbif_data.py --dwca_dir <path> --output_dir <path> --max_images 500
    ```

## Development Conventions

### Environment Management
*   The project uses `flutter_dotenv`.
*   Environment variables are accessed via the `Environment` class in `lib/environment.dart`.
*   **Important:** Never commit `.env` files or Android keystores (`.jks`).

### UI & Styling
*   **Theme:** The app uses a custom `NeonTheme` extension. UI components should respect the glowing aesthetic defined in `lib/theme/neon_theme.dart` and `lib/widgets/neon_widgets.dart`.
*   **Icons:** Managed via `flutter_launcher_icons`.

### Plant Identification Pipeline
*   **Input Size:** 224x224 pixels.
*   **Normalization:** PlantNet standard (Mean: `[0.485, 0.456, 0.406]`, Std: `[0.229, 0.224, 0.225]`).
*   **Model:** Assets are located in `assets/model/plantnet.tflite` with labels in `labels.txt`.

### Testing
*   Dart tests are located in `test/`.
*   Python-based data tests are in `Model/data_formatting/data_testing.py`.
*   Use `flutter test` for unit and widget tests.

## Key Files

*   `pubspec.yaml`: Project dependencies and asset declarations.
*   `lib/main.dart`: Root widget and initialization logic.
*   `lib/model.dart`: TFLite inference implementation.
*   `lib/environment.dart`: Environment variable mapping.
*   `README.md`: Detailed setup instructions for Google Cloud and Keystores.
