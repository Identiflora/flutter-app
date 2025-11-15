import 'package:flutter/material.dart';
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
        body: Stack(children: [
          getCameraWidget()
        ])
      )
    );
  }
}