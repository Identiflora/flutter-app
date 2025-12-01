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
  // added this for when the # of classes changes after transfer learning
  static const int NUM_CLASSES = 1081;

  // PlantNet Standard Normalization
  static const List<double> MEAN = [0.485, 0.456, 0.406];
  static const List<double> STD = [0.229, 0.224, 0.225];

  Future<void> loadModel() async {
    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset('assets/model/plantnet.tflite');
      
      // Load the scientific name labels
      final labelData = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelData.split('\n');
    } catch (e) {
      // whatever error handling we go with
    }
  }

  List<double> softmax(List<double> logits) {
    double maxLogit = logits.reduce((curr, next) => curr > next ? curr : next);
    List<double> exps = logits.map((e) => exp(e - maxLogit)).toList();
    double sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  Future<List<Map<String, dynamic>>> predict(File imageFile) async {
    if (_interpreter == null) await loadModel();

    // Decode and Resize Image
    final imageData = await imageFile.readAsBytes();
    final image = img.decodeImage(imageData);
    // if (image == null) return "Could not decode image";

    final resizedImage = img.copyResize(image!, width: INPUT_SIZE, height: INPUT_SIZE);

    // Preprocess (Normalize to Float32)
    var input = Float32List(1 * 3 * INPUT_SIZE * INPUT_SIZE);
    

    int pixelIndex = 0;
    for (int c = 0; c < 3; c++) { 
      for (int y = 0; y < INPUT_SIZE; y++) {
        for (int x = 0; x < INPUT_SIZE; x++) {
          var pixel = resizedImage.getPixel(x, y);
          
          double val = 0;
          if (c == 0) val = pixel.r.toDouble();
          if (c == 1) val = pixel.g.toDouble();
          if (c == 2) val = pixel.b.toDouble();

          input[pixelIndex++] = ((val / 255.0) - MEAN[c]) / STD[c];
        }
      }
    }

    // Reshape for the model
    var inputTensor = input.reshape([1, 3, INPUT_SIZE, INPUT_SIZE]); 
    
    // Run Inference
    var outputTensor = List.filled(1 * NUM_CLASSES, 0.0).reshape([1, 1081]);
    _interpreter!.run(inputTensor, outputTensor);

    // Parse Output with Softmax
    List<double> rawLogits = List<double>.from(outputTensor[0]);
    List<double> probabilities = softmax(rawLogits);
    List<Map<String, dynamic>> sortedResults = [];
    for (int i = 0; i < rawLogits.length; i++) {
      sortedResults.add({
        // NOTE FOR DATABASE: if we match the id's of the plant classes (class_index) 
        // that the model uses with what we save as the identification number 
        // in the database that would be goated
        'class_index': i,
        // this saves the confidence score as a converted percentage, it might be more sound to save
        // the raw score and then apply the softmax when its actually needed but idk
        'score': probabilities[i], 
        'label': _labels != null ? _labels![i] : 'Class $i',
      });
    }

    // Sort by score, still have to make the choice options not show in descending order though
    // I like sorting them like this as cell 0 will always be top option and the show all 5 options
    // screen will display in order of confidence score inherently
    sortedResults.sort((a, b) => (b['score'] as double).compareTo(a['score']));

    return sortedResults.take(5).toList(); 
  }
}