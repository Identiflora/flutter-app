import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:identiflora/model.dart';
import 'package:identiflora/user_guess.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'package:identiflora/theme/neon_theme.dart';
import 'package:identiflora/user_data/cache_utils.dart';

/// Get camera info from phone
Future<CameraDescription> getCamera() async {
  final cameras = await availableCameras();
  return cameras.first;
}

/// Get the widget for the first available camera
FutureBuilder<CameraDescription> getAvailableCameraWidget() {
  return FutureBuilder<CameraDescription>(
    future: getCamera(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      } else if (snapshot.hasError) {
        return Text("Camera had error when loading: ${snapshot.error}");
      } else if (snapshot.hasData) {
        return CameraWidget(camera: snapshot.data!);
      } else {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "No camera found. Please ensure camera is available.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    },
  );
}

/// Explictly get camera permission
Future<bool> getCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isGranted) {
    return true;
  } else {
    return false;
  }
}

/// Get camera display widget after requesting permission to access camera
FutureBuilder<bool> getCameraWidget() {
  return FutureBuilder<bool>(
    future: getCameraPermission(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      } else if (snapshot.hasError) {
        return Text("Camera had error when loading: ${snapshot.error}");
      } else if (snapshot.hasData && snapshot.data!) {
        return getAvailableCameraWidget();
      } else {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Identiflora cannot access your camera! Please check that camera permission is allowed.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    },
  );
}

// Stable caller for the state of camera
class CameraWidget extends StatefulWidget {
  final CameraDescription camera;
  const CameraWidget({super.key, required this.camera});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

// Camera widget logic
class _CameraWidgetState extends State<CameraWidget> {
  late CameraController _controller;

  /// Await camera controller connection
  Future<void> controlCamera() async {
    return await _controller.initialize();
  }

  /// Logic to display camera
  Widget getCameraPreview(CameraController controller, Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height,
          height: controller.value.previewSize?.width,
          child: CameraPreview(controller)
        ),
      ),
    );
  }

  // Find appropriate controller upon init
  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
  }

  // Stop controlling camera when this widget is closed
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Display camera with button overlays
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: FutureBuilder<void>(
        future: controlCamera(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller.value.isInitialized) {
            return Stack(
              children: [
                Center(child: getCameraPreview(_controller, size)),
                getCameraButton(_controller, context),
              ],
            );
          }
          // Prevents null exception if user somehow gets through permissions without agreeing
          else if (snapshot.connectionState == ConnectionState.done &&
              !_controller.value.isInitialized) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Identiflora cannot access your camera! Please check that camera permission is allowed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
      ),
    );
  }
}

/// Get the picture taking button that is aligned correctly. This button takes a picture then passes it into a screen object to display the picture.
SafeArea getCameraButton(CameraController controller, BuildContext context) {
  return SafeArea(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () async {
          if (controller.value.isTakingPicture) return;

          final image = await controller.takePicture();

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => DisplayPictureScreen(imgPath: image.path),
              ),
            );
          }
        },
        child: Icon(
          Icons.lens_outlined,
          size: 100.0,
          color: Theme.of(context).colorScheme.surface,
          shadows: Theme.of(context).extension<NeonTheme>()?.homeIconShadow,
        ),
      ),
    ),
  );
}

// Display screen for picture that was taken
class DisplayPictureScreen extends StatelessWidget {
  final String imgPath;
  final OfflinePlantService _plantService = OfflinePlantService();

  DisplayPictureScreen({super.key, required this.imgPath});

  /// Get the appropriate text button for navigation
  TextButton getTextButton(
    BuildContext context,
    String label,
    bool identifyPage,
  ) {
    if (identifyPage) {
      return TextButton(
        onPressed: () async {
          List<Map<String, dynamic>> results = await _plantService.predict(
            File(imgPath),
          );
          
          double rawScore = results[0]['score'] as double;
          double calibratedConfidence = calculateAngularConfidence(rawScore);

          // Model threshold gate of 50%
          if (calibratedConfidence < 0.5) {
            if (context.mounted) {
              // Pause the app and ask the user what to do
              bool? shouldProceed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("⚠️ Low Model Confidence "),
                    content: const Text(
                      "We are having trouble identifying this plant clearly. "
                      "For best results, ensure the leaves or flowers are in focus, "
                      "well-lit, and try taking another photo."
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false), // User chose to Retake
                        child: const Text("Retake Photo"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true), // User chose to force proceed
                        child: const Text("View Guesses Anyway"),
                      ),
                    ],
                  );
                },
              );
              // If the user dismissed the dialog or clicked "Retake", abort navigation
              if (shouldProceed != true && context.mounted) {
                Navigator.pop(context);
                return;
              }
            }
          }
          
          // Check to see if top label was recently identified
          final topLabel = results[0]['label'] as String;
          final topCommonName = results[0]['common_name'] as String;
          final allowed = await checkIdentification(topLabel);
          if (!allowed) {
            if (context.mounted) showCooldownDialog(context, topCommonName);
            return;
          }

          // Navigate to next page
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute<void>(
              builder: (context) => UserChoiceScreen(predictions: results, capturedImagePath: imgPath),
            ),
          );
        },
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Identify",
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return TextButton(
      onPressed: () {
        // Return to last page
        Navigator.pop(context);
      },
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "Retry",
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Image.file(File(imgPath))),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    getTextButton(context, "Retry", false),
                    getTextButton(context, "Identify", true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
