// Don't know where to put this but during refactoring/optimization we should create some default
// styles for things like colors, buttons, text formatting etc. I believe it goes in the main app
// build function in main like how the theme is, but lmk what y'all think

// ^ especially for default padding

import 'package:flutter/material.dart';
import 'package:identiflora/gallery_utils.dart';
import 'camera_utils.dart';
import 'login.dart';
import 'plant_capture.dart';

// Button on the top right of the main screen to start plant identification process
class PlantIdentificationTest extends StatelessWidget {
  const PlantIdentificationTest({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:16),
          child: ElevatedButton(onPressed: () {
            Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const PlantCaptureScreen(), 
                ),
            );
          }, 
          child: const Text('Model Identification'))
        )
      ),
    );
  }
}

void main() {
  runApp(const AppSetup());
}

// Camera startup logic
class AppSetup extends StatelessWidget {
  const AppSetup({super.key});

  // Determine if camera is accessible
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Identiflora",
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          getCameraWidget(),
          LoginWidget(),
          PlantIdentificationTest(),
          GalleryWidget()
        ])
      )
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
              child: const Text(
                "Please wait...\nIdentifying your plant!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Color.fromRGBO(145, 187, 32, 1), fontWeight: FontWeight.bold)
              )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: const CircularProgressIndicator(color: Color.fromRGBO(145, 187, 32, 1)),
            )
          ]
        ),
      )
    );
  }
}