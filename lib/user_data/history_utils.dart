

class HistoryData {
  List<Map<String, dynamic>> allPredictions;
  String userGuess;
  double latitude;
  double longitude;
  String imgUrl;

  HistoryData ({
    required this.allPredictions,
    required this.userGuess,
    required this.latitude,
    required this.longitude,
    required this.imgUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'predictions': allPredictions, 
      'user_guess': userGuess,
      'latitude': latitude,
      'longitude': longitude,
      'img_url': imgUrl,
    };
  }
  
  
}