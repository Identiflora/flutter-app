import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:identiflora/main.dart'; // This import should also be replaced with the file the model code is implemented in

/// Get camera info from phone
Future<CameraDescription> getCamera() async {
  final cameras = await availableCameras();
  return cameras.first;
}

/// Get camera display widget
FutureBuilder<CameraDescription> getCameraWidget() {
  return FutureBuilder<CameraDescription>(
            future: getCamera(), 
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: const CircularProgressIndicator(color: Color.fromRGBO(145, 187, 32, 1)));
              }
              else if(snapshot.hasError) {
                return Text("Camera had error when loading: ${snapshot.error}");
              }
              else if(snapshot.hasData) {
                return CameraWidget(camera: snapshot.data!);
              }
              else {
                return Text("No camera found.");
              }
            }
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
  OverflowBox getCameraPreview(CameraController controller, Size size) {
    return OverflowBox(
          minHeight: size.height,
          minWidth: size.width,
          maxHeight: size.height * controller.value.aspectRatio,
          maxWidth: size.width * controller.value.aspectRatio,
          child: CameraPreview(controller)
        );
  }

  // Find appropriate controller upon init
  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.max, enableAudio: false);
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
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: controlCamera(), 
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done && _controller.value.isInitialized) {
            return Stack(children: [
              Center(child: getCameraPreview(_controller, size)),
              getCameraButton(_controller, context)
            ]);
          }
          else if(snapshot.connectionState == ConnectionState.done && !_controller.value.isInitialized) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                  "Identiflora cannot access your camera! Please check that camera permission is allowed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Color.fromRGBO(145, 187, 32, 1), fontWeight: FontWeight.bold)
                ),
            ));
          }
          else {
            return Center(child: const CircularProgressIndicator(color: Color.fromRGBO(145, 187, 32, 1)));
          }
        },
      )
    );
  }}

/// Get the picture taking button that is aligned correctly. This button takes a picture then passes it into a screen object to display the picture.
SafeArea getCameraButton(CameraController controller, BuildContext pastContext) {
  return SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter, 
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () async {
                    if(controller.value.isTakingPicture) return;
                    
                    final image = await controller.takePicture();

                    if(pastContext.mounted) {
                      Navigator.push(
                        pastContext, 
                        MaterialPageRoute<void>(
                          builder: (context) => DisplayPictureScreen(imgPath: image.path)
                        )
                      );
                    }
                  }, 
                  child: Image.asset('assets/homepage/camera-circle-icon.png', width: 80, height: 80)
                ),
              )
            )
          );
}

// Display screen for picture that was taken
class DisplayPictureScreen extends StatelessWidget {
  final String imgPath;

  const DisplayPictureScreen({super.key, required this.imgPath});

  /// Get the appropriate text button for navigation
  TextButton getTextButton(BuildContext context, String label, bool identifyPage) {
    if(identifyPage) {
      return TextButton(
        onPressed: () {
          // Navigate to next page
          Navigator.push(
            context, 
            MaterialPageRoute<void>(
              // REMINDER: Replace with actual model functionality or move loading screen to proper utils.
              // This is also the location to pass the taken photo to the model and will require rescalling or cropping before this point
              builder: (context) => const ModelLoadingScreen()
            )
          );
        }, 
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text("Identify", style: TextStyle(fontSize: 20, color: Color.fromRGBO(145, 187, 32, 1)))
        )
      );
    }

    return TextButton(
      onPressed: () {
        // Return to last page
        Navigator.pop(context);
      }, 
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: const Text("Retry", style: TextStyle(fontSize: 20, color: Color.fromRGBO(145, 187, 32, 1)))
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.file(File(imgPath)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  getTextButton(context, "Retry", false),
                  getTextButton(context, "Identify", true)
                ],
              )
            ]
          ),
        )
      )
    );
  }
}