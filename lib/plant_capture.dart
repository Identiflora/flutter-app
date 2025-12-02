import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'model.dart';
import 'user_guess.dart';

// This doesn't use the main menu camera so maybe we could link it to that later
// however this allows for gallery upload in the same menu
// but also idk if we should allow scoring from the gallery uploads though

// also this full process uses the navigation pane thing that always has a back button
// that we should probably disable on release after the image submit page

class PlantCaptureScreen extends StatefulWidget {
  const PlantCaptureScreen({super.key});

  @override
  State<PlantCaptureScreen> createState() => _PlantCaptureScreenState();
}

class _PlantCaptureScreenState extends State<PlantCaptureScreen> {
  final OfflinePlantService _plantService = OfflinePlantService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _plantService.loadModel();
  }

  Future<void> _captureAndIdentify(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo == null) return;

      setState(() => _isLoading = true);

      List<Map<String, dynamic>> results = await _plantService.predict(File(photo.path));

      setState(() => _isLoading = false);

      if (results.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserChoiceScreen(
              predictions: results,
            ),
          ),
        );
      } else {
        _showError("No plant detected.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Identification'), centerTitle: true),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_florist_outlined, size: 100, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                        onPressed: () => _captureAndIdentify(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Take Photo"),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () => _captureAndIdentify(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Gallery"),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                  ),
                ],
              ),
      ),
    );
  }
}