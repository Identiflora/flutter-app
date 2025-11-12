import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const AppStartup());
}

// Camera startup logic
class AppStartup extends StatelessWidget {
  const AppStartup({super.key});

  // Get camera info from phone
  Future<CameraDescription> getCamera() async {
    final cameras = await availableCameras();
    return cameras.first;
  }

  // Determine if camera is accessible
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Identiflora",
      home: Scaffold(
        body: Center(
          child: FutureBuilder<CameraDescription>(
            future: getCamera(), 
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(color: Colors.black);
              }
              else if(snapshot.hasError) {
                return Text("Camera had error when loading: ${snapshot.error}");
              }
              else if(snapshot.hasData) {
                return CameraHomepage(camera: snapshot.data!);
              }
              else {
                return Text("No camera found.");
              }
            }),
        ),
      ),
    );
  }
}

class CameraHomepage extends StatefulWidget {
  final CameraDescription camera;
  const CameraHomepage({super.key, required this.camera});

  @override
  State<CameraHomepage> createState() => _CameraHomepageState();
}

// All homepage logic which might be passed to other widgets
class _CameraHomepageState extends State<CameraHomepage> {
  late CameraController _controller;

  // Wait for control then control
  Future<void> controlCamera() async {
    return await _controller.initialize();
  }

  // Start controlling camera
  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
  }

  // Stop using camera when this widget is closed
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
      body: FutureBuilder<void>(future: controlCamera(), builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return Stack(children: [
              Align(
                alignment: Alignment.center, 
                child: PreviewedCamera(size: size, controller: _controller)
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter, 
                  child: IconButton(
                    onPressed: () {
                      print("Photo Taken");
                    }, 
                    icon: Icon(Icons.circle),
                    iconSize: 100,
                    color: Colors.white
                  )
                ),
              )
            ]);
          }
          else {
            return const CircularProgressIndicator(color: Colors.black);
          }
        },
      )
    );
  }}

// All logic to preview camera
class PreviewedCamera extends StatelessWidget {
  const PreviewedCamera({
    super.key,
    required this.size,
    required CameraController controller,
  }) : _controller = controller;

  final Size size;
  final CameraController _controller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        maxHeight: size.height,
        maxWidth: size.width * _controller.value.aspectRatio,
        child: CameraPreview(_controller)
      )
    );
  }
}