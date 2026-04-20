
class QueuedIncorrectID {
  List<Map<String, dynamic>> allPredictions;
  String userGuess;
  double latitude;
  double longitude;
  String correctSpeciesSciName;
  String incorrectSpeciesSciName;
  String imagePath;

  QueuedIncorrectID({
    required this.allPredictions,
    required this.userGuess,
    required this.latitude,
    required this.longitude,
    required this.correctSpeciesSciName,
    required this.incorrectSpeciesSciName,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'predictions': allPredictions,
    'user_guess': userGuess,
    'latitude': latitude,
    'longitude': longitude,
    'correct_species': correctSpeciesSciName,
    'incorrect_species': incorrectSpeciesSciName,
    'image_path': imagePath,
  };

  QueuedIncorrectID.fromJson(Map<String, dynamic> json) :
    allPredictions = List<Map<String, dynamic>>.from(json['predictions']),
    userGuess = json['user_guess'],
    latitude = json['latitude'],
    longitude = json['longitude'],
    correctSpeciesSciName = json['correct_species'],
    incorrectSpeciesSciName = json['incorrect_species'],
    imagePath = json['image_path'];
}

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

}