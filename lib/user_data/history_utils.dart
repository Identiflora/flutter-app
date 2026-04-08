

import 'package:identiflora/database_utils.dart';

class HistoryData {
  List<Map<String, dynamic>> allPredictions;
  String userGuess;
  double latitude;
  double longitude;
  String imgUrl;

  /// Datatype for identification submissions
  HistoryData ({
    required this.allPredictions,
    required this.userGuess,
    required this.latitude,
    required this.longitude,
    required this.imgUrl,
  });

  /// Convert history data to JSON
  Map<String, dynamic> toJson() => {
    'predictions': allPredictions, 
    'user_guess': userGuess,
    'latitude': latitude,
    'longitude': longitude,
    'img_url': imgUrl,
  };

  /// Parse history data from JSON
  HistoryData.fromJson(Map<String, dynamic> json) :
    allPredictions = List<Map<String, dynamic>>.from(json['predictions']),
    userGuess = json['user_guess'],
    latitude = json['latitude'],
    longitude = json['longitude'],
    imgUrl = json['image_url'] ??= "";

  /// Update image URL for proper display after being offline
  Future<void> updateImgUrl() async {
    if(imgUrl == "") {
      String? imgPath = await getPlantSpeciesUrl(scientificName: allPredictions.first['label']);
      imgUrl = imgPath; 
    }
  }
}