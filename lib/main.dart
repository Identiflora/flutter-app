import 'package:flutter/material.dart';
import 'package:identiflora/gallery_utils.dart';
import 'camera_utils.dart';

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
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          getCameraWidget(),
          GalleryWidget()
        ])
      )
    );
  }
}

// Temporary loading screen for the model. This should be moved to a new utils file or replaced with the appropriate code when created
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