import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Get camera info from phone
Future<CameraDescription> getCamera() async {
  final cameras = await availableCameras();
  return cameras.first;
}

/// Get display widget for camera with photo button and pass picture data, when taken
FutureBuilder<CameraDescription> getCameraWidget() {
  return FutureBuilder<CameraDescription>(
            future: getCamera(), 
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(color: Colors.black);
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

  // Await camera controller connection
  Future<void> controlCamera() async {
    return await _controller.initialize();
  }

  // Find appropriate controller upon init
  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
  }

  // Stop controlling camera when this widget is closed
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // Display camera with icon overlays
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: FutureBuilder<void>(
        future: controlCamera(), 
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return Stack(children: [
              Center(child: CameraPreviewWidget(size: size, controller: _controller)),
              getCameraButton(_controller)
            ]);
          }
          else {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
        },
      )
    );
  }}

// Logic to preview camera
class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key, required this.size, required this.controller,});

  final Size size;
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
        minHeight: size.height,
        minWidth: size.width,
        maxHeight: size.height * controller.value.aspectRatio,
        maxWidth: size.width * controller.value.aspectRatio,
        child: CameraPreview(controller)
      );
  }
}

/// Get the picture taking button that is aligned correctly. This also contains the "onPressed" functionality to print the file path so the picture can later be passed.
SafeArea getCameraButton(CameraController controller) {
  return SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter, 
              child: GestureDetector(
                onTap: () async {
                  final image = await controller.takePicture();
                  debugPrint("Plant identification image path: ${image.path}" );
                }, 
                child: Image.asset('assets/camera/camera-circle-icon.png', width: 80, height: 80)
              )
            ),
          );
}
