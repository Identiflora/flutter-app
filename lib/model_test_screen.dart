// This was just used for testing that the model works at all, still could be useful
// in the future to give the model an image and immediately get what the top result
// is

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'model.dart';

class ModelTestScreen extends StatefulWidget {
  const ModelTestScreen({super.key});

  @override
  State<ModelTestScreen> createState() => _ModelTestScreenState();
}

class _ModelTestScreenState extends State<ModelTestScreen> {
  final OfflinePlantService _plantService = OfflinePlantService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  String _output = "Model not run yet.";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    setState(() => _output = "Loading model...");
    await _plantService.loadModel();
    setState(() => _output = "Model Loaded! Ready to scan.");
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo == null) return;

    setState(() {
      _selectedImage = File(photo.path);
      _isLoading = true;
      _output = "Analyzing...";
    });

    // 3. Run the prediction
    try {
      await Future.delayed(const Duration(milliseconds: 100)); 
      
      List<Map<String, dynamic>> result = await _plantService.predict(_selectedImage!);
      String topName = result[0]['label'];
      double topScore = result[0]['score'];
      
      setState(() {
        _output = "$topName (${(topScore * 100).toStringAsFixed(1)}%)";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _output = "Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TFLite Debugger")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Image Preview
            Container(
              height: 300,
              width: 300,
              color: Colors.grey[200],
              child: _selectedImage == null
                  ? const Center(child: Text("No Image Selected"))
                  : Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
            
            const SizedBox(height: 20),
            
            // Result Output
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _output,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            
            if (_isLoading) const CircularProgressIndicator(),
            
            const SizedBox(height: 20),
            
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}