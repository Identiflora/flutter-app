import 'package:flutter/material.dart';
import 'package:identiflora/user_data/point_utils.dart';
import 'model_incorrect.dart';
import 'package:geolocator/geolocator.dart';
import 'package:identiflora/database_utils.dart';

class ResultsWidget extends StatefulWidget {
  final int userChoiceIndex;
  final int correctIndex;
  final List<Map<String, dynamic>> allPredictions;
  final String imgURL;
  
  const ResultsWidget({
    required this.userChoiceIndex,
    required this.correctIndex,
    required this.allPredictions,
    required this.imgURL,
    super.key,
  });

  @override
  State<ResultsWidget> createState() => _Results();
}

class _Results extends State<ResultsWidget> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> topMatch = widget.allPredictions[widget.correctIndex];
    final String modelTopName = topMatch['label'];
    final Map<String, dynamic> userPick;
    String userPickedName = "";
    
    // Check for bounds and skip case
    if(widget.userChoiceIndex <= 4 && widget.userChoiceIndex >= 0) {
      userPick = widget.allPredictions[widget.userChoiceIndex];
      userPickedName = userPick['label'];
    }

    final bool isCorrect = widget.userChoiceIndex == widget.correctIndex;

    // correct color based off themeing with a hard dark red for incorrect
    final Color incorrectColor = const Color.fromARGB(255, 180, 39, 39);
    final Color correctColor = Theme.of(context).colorScheme.primary;
    
    const TextStyle mainTextStyle = TextStyle(
      fontSize: 22,
      height: 1.2,
      color: Colors.black, 
    );
    
    final TextStyle plantNameStyle = mainTextStyle.copyWith(
      fontWeight: FontWeight.bold,
    );

    final int addPoints = 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: mainTextStyle,
                  children: <TextSpan>[
                    if (isCorrect) ...[
                      const TextSpan(text: "You said this plant is a\n"),
                      TextSpan(
                        text: userPickedName, 
                        style: plantNameStyle.copyWith(color: correctColor),
                      ),
                      const TextSpan(text: "\nand were correct!"),
                    ] else if(widget.userChoiceIndex != -1)...[
                      const TextSpan(text: "You said this plant is a\n"),
                      TextSpan(
                        text: "$userPickedName...\n",
                        style: plantNameStyle.copyWith(color: incorrectColor),
                      ),
                      const TextSpan(text: "but it is actually a\n"),
                      TextSpan(
                        text: modelTopName,
                        style: plantNameStyle.copyWith(color: correctColor),
                      ),
                    ]
                    else ...[
                      const TextSpan(text: "This plant is a\n"),
                      TextSpan(
                        text: modelTopName,
                        style: plantNameStyle.copyWith(color: correctColor),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: Container(
                  decoration: widget.imgURL == "" ? null : BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.all(Radius.elliptical(15, 15)),
                    boxShadow: const [
                      BoxShadow(
                        blurStyle: BlurStyle.outer,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.elliptical(15, 15)),
                    child: widget.imgURL == "" ? const Placeholder() : Image.network(widget.imgURL, fit: BoxFit.cover,)
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Does this look correct?',
                textAlign: TextAlign.center,
                style: mainTextStyle,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  // Yes Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        double lat = 0.0, lng = 0.0;  
                        
                        // Location service check
                        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                        if (serviceEnabled) {
                          LocationPermission permission = await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                          }
                          
                          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                            try {
                              Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                              lat = position.latitude;
                              lng = position.longitude;
                            } catch (e) {
                              debugPrint("Error getting location: $e");
                            }
                          }
                        }

                        // Send results to the database
                        await savePlantSubmission(
                          allPredictions: widget.allPredictions,
                          userGuess: modelTopName, 
                          latitude: lat, 
                          longitude: lng,
                          imgUrl: widget.imgURL,
                        );

                        // Navigation and Points
                        if (isCorrect && context.mounted) {
                          // Award points only if the original guess was right
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => UserPointsLoadingScreen(newPoints: addPoints),
                          ));
                        } else if (context.mounted) {
                          // If they were wrong but clicked Yes (confirming the correct one), just go home
                          Navigator.popUntil(context, ModalRoute.withName("/"));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: correctColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Yes'),
                    ),
                  ),
                  const SizedBox(width: 16), 
                  // No Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopMatchesWidget(predictions: widget.allPredictions),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: incorrectColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('No'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}