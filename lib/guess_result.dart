import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'package:identiflora/user_data/cache_utils.dart';
import 'model_incorrect.dart';
import 'package:geolocator/geolocator.dart';
import 'package:identiflora/widgets/neon_widgets.dart';
import 'package:identiflora/user_data/user_data_service.dart';
import 'package:identiflora/widgets/button_widgets.dart';

class ResultsWidget extends StatefulWidget {
  final int userChoiceIndex;
  final int correctIndex;
  final List<Map<String, dynamic>> allPredictions;
  final List<Map<String, dynamic>> orderedPredictions;
  final String scientificName;
  final String capturedImagePath;

  const ResultsWidget({
    required this.userChoiceIndex,
    required this.correctIndex,
    required this.allPredictions,
    required this.orderedPredictions,
    required this.scientificName,
    required this.capturedImagePath,
    super.key,
  });

  @override
  State<ResultsWidget> createState() => _Results();
}

class _Results extends State<ResultsWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 800),
    );
    if (widget.userChoiceIndex == widget.correctIndex) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Helper function for save plant history logic so it can all be placed in a loading screen.
  Future<String> saveHistory(String userPickedName) async {
    try {
      double lat = 0.0, lng = 0.0;

      // Location service check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          try {
            Position position = await Geolocator.getCurrentPosition(
              locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high,
              ),
            );
            lat = position.latitude;
            lng = position.longitude;
          } catch (e) {
            if (mounted) {
              errorPopupMessage(context, "Error getting location: $e", null);
            }
          }
        }
      }

      // Send results to the database
      await savePlantSubmission(
        allPredictions: widget.orderedPredictions,
        userGuess: userPickedName,
        latitude: lat,
        longitude: lng,
      );
      return "success";
    } catch (error) {
      // Error is surfaced to loading screen
      return error.toString();
    }
  }

  Future<String> _saveHistoryAndFirePoints(
    String userPickedName,
    bool isCorrect,
    int addPoints,
  ) async {
    final historyResult = await saveHistory(userPickedName);
    bool allowed = false;

    if (historyResult == "success") {
      // Determine if identification is unique and save to recent if not.
      // This is a second check where the first is defined in camera_utils
      final topLabel = widget.allPredictions[widget.correctIndex]['label'];
      allowed = await checkAndRecordIdentification(topLabel);
    }
    

    final pointsToAdd = isCorrect && allowed && historyResult == "success" ? addPoints : 0;
    submitUserGlobalPoints(addPoints: pointsToAdd).then((result) {
      if (result) UserDataService().refreshPoints();
    });
    
    return historyResult;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> topMatch = widget.allPredictions[widget.correctIndex];
    final String modelTopName = (topMatch['common_name'] as String).isNotEmpty
        ? topMatch['common_name'] as String
        : topMatch['label'] as String;
    final Map<String, dynamic> userPick;
    String userPickedName = "";
    final double rawScore = topMatch['score'] as double? ?? 0.0;
    final double displayScore = calculateAngularConfidence(rawScore);

    // Check for bounds and skip case
    if (widget.userChoiceIndex <= 4 && widget.userChoiceIndex >= 0) {
      userPick = widget.allPredictions[widget.userChoiceIndex];
      userPickedName = (userPick['common_name'] as String).isNotEmpty
          ? userPick['common_name'] as String
          : userPick['label'] as String;
    }

    final bool isCorrect = widget.userChoiceIndex == widget.correctIndex;
    const int addPoints = 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Results'), centerTitle: true),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ResultText(
                    isCorrect: isCorrect,
                    userChoiceIndex: widget.userChoiceIndex,
                    userPickedName: userPickedName,
                    modelTopName: modelTopName,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    child: NeonContainer(
                      borderRadius: BorderRadius.all(Radius.elliptical(15, 15)),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.elliptical(15, 15),
                        ),
                        child: Image.asset(
                          localPlantAssetPath(widget.scientificName),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Placeholder(),
                        ),
                      ),
                    ),
                  ),

                  // Added Confidence Display
                  const SizedBox(height: 12),
                  Text(
                    'Model Confidence: ${(displayScore * 100).toStringAsFixed(1)}%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'Does this look correct?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, height: 1.2),
                  ),

                  const SizedBox(height: 16),
                  GuessResultActionButtons(
                    onYesTap: () => _saveHistoryAndFirePoints(
                      userPickedName,
                      isCorrect,
                      addPoints,
                    ),
                    allPredictions: widget.allPredictions,
                    orderedPredictions: widget.orderedPredictions,
                    correctIndex: widget.correctIndex,
                    capturedImagePath: widget.capturedImagePath,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              gravity: 0.05,
              emissionFrequency: 0.8,
              numberOfParticles: 50,
              maxBlastForce: 200,
              minBlastForce: 50,
            ),
          ),
        ],
      ),
    );
  }
}

class GuessResultActionButtons extends StatelessWidget {
  final Future<String> Function() onYesTap;
  final List<Map<String, dynamic>> allPredictions;
  final List<Map<String, dynamic>> orderedPredictions;
  final int correctIndex;
  final String capturedImagePath;

  const GuessResultActionButtons({
    required this.onYesTap,
    required this.allPredictions,
    required this.orderedPredictions,
    required this.correctIndex,
    required this.capturedImagePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color correctColor = Theme.of(context).colorScheme.secondary;
    final Color incorrectColor = Theme.of(context).colorScheme.error;

    return Row(
      children: [
        Expanded(
          child: DisabledButton(
            enableCondition: true,
            labelText: 'Yes',
            textColor: correctColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoadingScreen<String>.withPop(
                    loadingMsg: "Please wait while we save your latest identification...",
                    foundMsg: "Identification saved! One moment...",
                    errorMsg: "We could not find your account to save plant history. Please check that you are logged in.",
                    futureFunction: onYesTap(),
                    postLoadingPop: ModalRoute.withName("/"),
                    popErrorScreenButton: null,
                    popOnError: true,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        // Would like to eventually change to neon outlined buttons, red outline for no
        Expanded(
          child: DisabledButton(
            enableCondition: true,
            labelText: 'No',
            textColor: incorrectColor,
            onPressed: () async {
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopMatchesWidget(
                      predictions: orderedPredictions,
                      correctIndex: correctIndex,
                      capturedImagePath: capturedImagePath,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class ResultText extends StatelessWidget {
  final bool isCorrect;
  final int userChoiceIndex;
  final String userPickedName;
  final String modelTopName;

  const ResultText({
    required this.isCorrect,
    required this.userChoiceIndex,
    required this.userPickedName,
    required this.modelTopName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle mainTextStyle = TextStyle(fontSize: 22, height: 1.2);
    final TextStyle plantNameStyle = mainTextStyle.copyWith(
      fontWeight: FontWeight.bold,
    );
    final Color correctColor = Theme.of(context).colorScheme.secondary;
    final Color incorrectColor = Theme.of(context).colorScheme.error;
    final Color defaultTextColor =
        Theme.of(context).textTheme.displayMedium!.color!;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: mainTextStyle,
        children: <TextSpan>[
          if (isCorrect) ...[
            TextSpan(
              text: "You said this plant is a\n",
              style: TextStyle(color: defaultTextColor),
            ),
            TextSpan(
              text: userPickedName,
              style: plantNameStyle.copyWith(color: correctColor),
            ),
            TextSpan(
              text: "\nand the model agrees!",
              style: TextStyle(color: defaultTextColor),
            ),
          ] else if (userChoiceIndex != -1) ...[
            TextSpan(
              text: "You said this plant is a\n",
              style: TextStyle(color: defaultTextColor),
            ),
            TextSpan(
              text: "$userPickedName...\n",
              style: plantNameStyle.copyWith(color: incorrectColor),
            ),
            TextSpan(
              text: "but the model suggests it may be a\n",
              style: TextStyle(color: defaultTextColor),
            ),
            TextSpan(
              text: modelTopName,
              style: plantNameStyle.copyWith(color: correctColor),
            ),
          ] else ...[
            TextSpan(
              text: "The model suggests this may be a\n",
              style: TextStyle(color: defaultTextColor),
            ),
            TextSpan(
              text: modelTopName,
              style: plantNameStyle.copyWith(color: correctColor),
            ),
          ],
        ],
      ),
    );
  }
}
