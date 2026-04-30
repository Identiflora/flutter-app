import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';


class OfflinePlantService {
  Interpreter? _interpreter;
  List<String>? _labels;
  List<String>? _commonNames;

  static const int INPUT_SIZE = 224;
  static const int NUM_CHANNELS = 3;
  // added this for when the # of classes changes after transfer learning
  static const int NUM_CLASSES = 589;

  // PlantNet Standard Normalization
  static const List<double> MEAN = [0.485, 0.456, 0.406];
  static const List<double> STD = [0.229, 0.224, 0.225];

  Future<void> loadModel() async {
    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset('assets/model/identiflora_mobile_ready_vfinal_float32.tflite');

      // Load the scientific name labels      
      final labelData = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelData.split('\n');

      // Load the common name labels
      final commonNameData = await rootBundle.loadString('assets/model/common_names.txt');
      _commonNames = commonNameData.split('\n');
    } catch (e) {
      // EXPOSE THE ERROR so it doesn't fail silently
      debugPrint("Critical Error Loading Model/Labels: $e"); 
    }
  }

  // Softmax function has been removed because its automatically done within the model output now

  Future<List<Map<String, dynamic>>> predict(File imageFile) async {
    if (_interpreter == null) await loadModel();
    if (_interpreter == null) return []; // Abort if model still failed to load

    // Decoding image
    final imageData = await imageFile.readAsBytes();
    final image = img.decodeImage(imageData);
    if (image == null) return [];

    // Center crop to match transfer learning training inputs
    int size = image.width < image.height ? image.width : image.height;
    img.Image croppedImage = img.copyCrop(
      image,
      x: (image.width - size) ~/ 2,
      y: (image.height - size) ~/ 2,
      width: size,
      height: size,
    );
    img.Image resizedImage = img.copyResize(croppedImage, width: INPUT_SIZE, height: INPUT_SIZE);

    var input = Float32List(1 * INPUT_SIZE * INPUT_SIZE * 3);
    int pixelIndex = 0;

    for (int y = 0; y < INPUT_SIZE; y++) {
      for (int x = 0; x < INPUT_SIZE; x++) {
        var pixel = resizedImage.getPixel(x, y);
        
        input[pixelIndex++] = (pixel.r / 255.0 - MEAN[0]) / STD[0];
        input[pixelIndex++] = (pixel.g / 255.0 - MEAN[1]) / STD[1];
        input[pixelIndex++] = (pixel.b / 255.0 - MEAN[2]) / STD[2];
      }
    }

    var inputTensor = input.reshape([1, INPUT_SIZE, INPUT_SIZE, 3]); 
    var outputTensor = List.filled(1 * NUM_CLASSES, 0.0).reshape([1, NUM_CLASSES]);
    
    try {
      _interpreter!.run(inputTensor, outputTensor);
    } catch (e) {
      debugPrint("Inference Error: $e");
      return [];
    }

    // Softmax probabilities are now wrapped inside the model file
    List<double> probabilities = List<double>.from(outputTensor[0]);
    
    List<Map<String, dynamic>> results = [];
    for (int i = 0; i < probabilities.length; i++) {
      results.add({
        'class_index': i,
        'score': probabilities[i],
        'label': _labels != null && i < _labels!.length ? _labels![i].trim() : 'Class $i',
        'common_name': getCommonName(i),
      });
    }

    results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    
    // Debug output to flutter terminal to see top1 confidence score
    var top5 = results.take(5).toList();
    debugPrint("Top Rank: ${top5[0]['label']} (${(top5[0]['score'] * 100).toStringAsFixed(2)}%)");
    
    return top5;
  }

  String getCommonName(int current_idx) {
    if (_commonNames == null || current_idx < 0 || current_idx >= _commonNames!.length) {
      return '';
    }
    return _commonNames![current_idx];
  }
}