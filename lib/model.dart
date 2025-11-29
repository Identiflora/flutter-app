import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';

class OfflinePlantService {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const int INPUT_SIZE = 224;
  static const int NUM_CHANNELS = 3;

  // PlantNet Standard Normalization (from utils.py)
  static const List<double> MEAN = [0.485, 0.456, 0.406];
  static const List<double> STD = [0.229, 0.224, 0.225];

  Future<void> loadModel() async {
    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset('assets/model/plantnet.tflite');
      
      // Load the labels
      final labelData = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelData.split('\n');
      
      print("✅ Model loaded successfully. Input shape: ${_interpreter!.getInputTensor(0).shape}");
    } catch (e) {
      print("❌ Error loading model: $e");
    }
  }

  List<double> softmax(List<double> logits) {
  double maxLogit = logits.reduce((curr, next) => curr > next ? curr : next);
  List<double> exps = logits.map((e) => exp(e - maxLogit)).toList();
  double sumExps = exps.reduce((a, b) => a + b);
  return exps.map((e) => e / sumExps).toList();
  }

  Future<String> predict(File imageFile) async {
    if (_interpreter == null) await loadModel();

    // 1. Decode and Resize Image
    final imageData = await imageFile.readAsBytes();
    final image = img.decodeImage(imageData);
    if (image == null) return "Could not decode image";

    final resizedImage = img.copyResize(image, width: INPUT_SIZE, height: INPUT_SIZE);

    // 2. Preprocess (Normalize to Float32)
    // Input tensor shape: [1, 3, 224, 224] or [1, 224, 224, 3] depending on conversion
    // We assume standard [1, 3, 224, 224] for PyTorch models converted via AI Edge
    var input = Float32List(1 * 3 * INPUT_SIZE * INPUT_SIZE);
    
    // IMPORTANT: Check your model input shape! 
    // If getting "shape mismatch" errors, swap the loops to do [y][x][c] instead.
    int pixelIndex = 0;
    for (int c = 0; c < 3; c++) { // Channels first (PyTorch style)
      for (int y = 0; y < INPUT_SIZE; y++) {
        for (int x = 0; x < INPUT_SIZE; x++) {
          var pixel = resizedImage.getPixel(x, y);
          
          // Extract RGB values (0-255)
          double val = 0;
          if (c == 0) val = pixel.r.toDouble();
          if (c == 1) val = pixel.g.toDouble();
          if (c == 2) val = pixel.b.toDouble();

          // Normalize: (Value/255 - Mean) / Std
          input[pixelIndex++] = ((val / 255.0) - MEAN[c]) / STD[c];
        }
      }
    }

    // 3. Reshape for the model
    // Try [1, 3, 224, 224] first. If that fails, try [1, 224, 224, 3].
    var inputTensor = input.reshape([1, 3, INPUT_SIZE, INPUT_SIZE]); 
    
    // 4. Run Inference
    var outputTensor = List.filled(1 * 1081, 0.0).reshape([1, 1081]);
    _interpreter!.run(inputTensor, outputTensor);

    // 5. Parse Output with Softmax
    List<double> rawLogits = List<double>.from(outputTensor[0]);
    List<double> probabilities = softmax(rawLogits); // <--- NEW STEP

    int bestIndex = 0;
    double bestScore = 0.0;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > bestScore) {
        bestScore = probabilities[i];
        bestIndex = i;
      }
    }

    if (_labels != null && bestIndex < _labels!.length) {
      return "${_labels![bestIndex]} (${(bestScore * 100).toStringAsFixed(1)}%)";
    }
    
    return "Class $bestIndex (Score: ${(bestScore * 100).toStringAsFixed(1)}%)";
  }
}