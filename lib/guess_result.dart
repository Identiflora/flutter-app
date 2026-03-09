import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'model_incorrect.dart';
import 'package:geolocator/geolocator.dart';
import 'package:identiflora/widgets/neon_widgets.dart';
import 'package:identiflora/widgets/button_widgets.dart';

class ResultsWidget extends StatefulWidget {
  final int userChoiceIndex;
  final int correctIndex;
  final List<Map<String, dynamic>> allPredictions;
  final List<Map<String, dynamic>> orderedPredictions;
  final String imgURL;

  const ResultsWidget({
    required this.userChoiceIndex,
    required this.correctIndex,
    required this.allPredictions,
    required this.orderedPredictions,
    required this.imgURL,
    super.key,
  });

  @override
  State<ResultsWidget> createState() => _Results();
}

class _Results extends State<ResultsWidget> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> topMatch =
        widget.allPredictions[widget.correctIndex];
    final String modelTopName = topMatch['label'];
    final Map<String, dynamic> userPick;
    String userPickedName = "";

    // Check for bounds and skip case
    if (widget.userChoiceIndex <= 4 && widget.userChoiceIndex >= 0) {
      userPick = widget.allPredictions[widget.userChoiceIndex];
      userPickedName = userPick['label'];
    }

    final bool isCorrect = widget.userChoiceIndex == widget.correctIndex;

    // correct color based off themeing with a hard dark red for incorrect
    final Color incorrectColor = Theme.of(context).colorScheme.error;
    final Color correctColor = Theme.of(context).colorScheme.secondary;

    const TextStyle mainTextStyle = TextStyle(
      fontSize: 22,
      height: 1.2,
    );

    final TextStyle plantNameStyle = mainTextStyle.copyWith(
      fontWeight: FontWeight.bold,
    );

    final int addPoints = 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Results'), centerTitle: true),
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
                      // Correct guess
                      TextSpan(text: "You said this plant is a\n", style: TextStyle(color: Theme.of(context).textTheme.displayMedium!.color)),
                      TextSpan(
                        text: userPickedName,
                        style: plantNameStyle.copyWith(color: correctColor),
                      ),
                      TextSpan(text: "\nand were correct!", style: TextStyle(color: Theme.of(context).textTheme.displayMedium!.color)),
                    ] else if (widget.userChoiceIndex != -1) ...[
                      // Incorrect guess
                      TextSpan(text: "You said this plant is a\n", style: TextStyle(color: Theme.of(context).textTheme.displayMedium!.color)),
                      TextSpan(
                        text: "$userPickedName...\n",
                        style: plantNameStyle.copyWith(color: incorrectColor),
                      ),
                      TextSpan(text: "but it is actually a\n", style: TextStyle(color: Theme.of(context).textTheme.displayMedium!.color)),
                      TextSpan(
                        text: modelTopName,
                        style: plantNameStyle.copyWith(color: correctColor),
                      ),
                    ] else ...[
                      // Skipped Guess
                      TextSpan(text: "This plant is a\n", style: TextStyle(color: Theme.of(context).textTheme.displayMedium!.color)),
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
                child: NeonContainer(
                  borderRadius: BorderRadius.all(Radius.elliptical(15, 15)),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.elliptical(15, 15)),
                    child: (widget.imgURL == "" || widget.imgURL.startsWith("https://placeholder"))
                        ? const Placeholder() 
                        : Image.network(widget.imgURL, fit: BoxFit.cover),
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
                    child: DisabledButton(
                      enableCondition: true,
                      labelText: 'Yes',
                      textColor: correctColor,
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
                              Position position = await Geolocator.getCurrentPosition(
                                locationSettings: LocationSettings(
                                  accuracy: LocationAccuracy.high
                                )
                              );
                              lat = position.latitude;
                              lng = position.longitude;
                            } catch (e) {
                              // we should probably do something in this error
                              debugPrint("Error getting location: $e");
                            }
                          }
                        }

                        // Send results to the database
                        await savePlantSubmission(
                          allPredictions: widget.orderedPredictions,
                          userGuess: userPickedName, 
                          latitude: lat, 
                          longitude: lng,
                          imgUrl: widget.imgURL,
                        );

                        // Navigation and Points
                        if (isCorrect && context.mounted) {
                          // Award points only if the original guess was right
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoadingScreen<bool>.withPop(
                                loadingMsg: "Please wait while we update your points...", 
                                foundMsg: "Points updated! One moment...", 
                                errorMsg: "We could not find your account to update points for. Please check that you are logged in and try again.", 
                                futureFunction: submitUserGlobalPoints(addPoints: addPoints), 
                                postLoadingPop: ModalRoute.withName("/"),
                                popErrorScreenButton: "Return to Homepage",
                                valueEqualCheck: true,
                              )
                            ),
                          );
                        } else if (context.mounted) {
                          // If they were wrong but clicked Yes (confirming the correct one), just go home
                          Navigator.popUntil(context, ModalRoute.withName("/"));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // No Button
                  Expanded(
                    // Would like to eventually change to neon outlined buttons, red outline for no
                    child: DisabledButton(
                      enableCondition: true,
                      labelText: 'No',
                      textColor: incorrectColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopMatchesWidget(
                              predictions: widget.allPredictions,
                            ),
                          ),
                        );
                      },
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
