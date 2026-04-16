import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'model_incorrect.dart';
import 'package:geolocator/geolocator.dart';
import 'package:identiflora/widgets/neon_widgets.dart';
import 'package:identiflora/user_data/offline_utils.dart';
import 'package:identiflora/widgets/button_widgets.dart';

class ResultsWidget extends StatefulWidget {
  final int userChoiceIndex;
  final int correctIndex;
  final List<Map<String, dynamic>> allPredictions;
  final List<Map<String, dynamic>> orderedPredictions;
  final String imgURL;
  final String capturedImagePath;

  const ResultsWidget({
    required this.userChoiceIndex,
    required this.correctIndex,
    required this.allPredictions,
    required this.orderedPredictions,
    required this.imgURL,
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
        imgUrl: widget.imgURL,
      );
      return "success";
    } catch (error) {
      // Error is surfaced to loading screen
      return error.toString();
    }
  }

  /// Formats an error string for both history and saving points
  String formatCombinedErrorString(String? historyError) {
    if (historyError != null && historyError.contains("not authenticated")) {
      return "Please log in then try again to save plant history and update earned points.";
    } else if (historyError != null) {
      return "History had error meaning points were not added: $historyError";
    }

    return "History had unexpected non-fatal error.";
  }

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

    const TextStyle mainTextStyle = TextStyle(fontSize: 22, height: 1.2);

    final TextStyle plantNameStyle = mainTextStyle.copyWith(
      fontWeight: FontWeight.bold,
    );

    final int addPoints = 1;

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
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: mainTextStyle,
                      children: <TextSpan>[
                        if (isCorrect) ...[
                          // Correct guess
                          TextSpan(
                            text: "You said this plant is a\n",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium!.color,
                            ),
                          ),
                          TextSpan(
                            text: userPickedName,
                            style: plantNameStyle.copyWith(color: correctColor),
                          ),
                          TextSpan(
                            text: "\nand were correct!",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium!.color,
                            ),
                          ),
                        ] else if (widget.userChoiceIndex != -1) ...[
                          // Incorrect guess
                          TextSpan(
                            text: "You said this plant is a\n",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium!.color,
                            ),
                          ),
                          TextSpan(
                            text: "$userPickedName...\n",
                            style: plantNameStyle.copyWith(
                              color: incorrectColor,
                            ),
                          ),
                          TextSpan(
                            text: "but it is actually a\n",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium!.color,
                            ),
                          ),
                          TextSpan(
                            text: modelTopName,
                            style: plantNameStyle.copyWith(color: correctColor),
                          ),
                        ] else ...[
                          // Skipped Guess
                          TextSpan(
                            text: "This plant is a\n",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.displayMedium!.color,
                            ),
                          ),
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
                        borderRadius: const BorderRadius.all(
                          Radius.elliptical(15, 15),
                        ),
                        child:
                            (widget.imgURL == "" ||
                                widget.imgURL.startsWith("https://placeholder"))
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
                            // Nested loading screens to handle saving plant history and adding points
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoadingScreen.withNav(
                                  loadingMsg:
                                      "Please wait while we save your latest identification...",
                                  foundMsg:
                                      "Identification saved! One moment...",
                                  errorMsg:
                                      "We could not find your account to save plant history. Please check that you are logged in.",
                                  futureFunction: saveHistory(userPickedName),
                                  postLoadingBuilder:
                                      (
                                        context,
                                        historyResult,
                                      ) => LoadingScreen<bool>.withPop(
                                        loadingMsg:
                                            "Please wait while we update your points...",
                                        foundMsg:
                                            "Points updated! One moment...",
                                        errorMsg: historyResult == "success"
                                            ? isCorrect
                                                  ? "Sorry, we couldn't update your points! Please try again later."
                                                  : ""
                                            : formatCombinedErrorString(
                                                historyResult!,
                                              ),
                                        futureFunction: submitUserGlobalPoints(
                                          addPoints:
                                              isCorrect &&
                                                  historyResult == "success"
                                              ? addPoints
                                              : 0, // Enforce errors and incorrect case
                                        ),
                                        postLoadingPop: ModalRoute.withName(
                                          "/",
                                        ),
                                        popErrorScreenButton: null,
                                        popOnError: true,
                                        // If points returns false, make sure error is surfaced
                                        valueEqualCheck: true,
                                      ),
                                  navigateOnError: true,
                                ),
                              ),
                            );
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
                          onPressed: () async {
                            if (await ConnService().getIsOffline) {
                              if (context.mounted) {
                                errorPopupMessage(
                                  context,
                                  "Action not available while offline",
                                  null,
                                );
                              }
                              return;
                            }
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TopMatchesWidget(
                                    predictions: widget.allPredictions,
                                    correctIndex: widget.correctIndex,
                                    capturedImagePath: widget.capturedImagePath,
                                  ),
                                ),
                              );
                            }
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
