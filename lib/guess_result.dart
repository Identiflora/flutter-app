import 'package:flutter/material.dart';
import 'package:identiflora/user_data/point_utils.dart';
import 'model_incorrect.dart';
import 'package:identiflora/widgets/neon_widgets.dart';
import 'package:identiflora/widgets/button_widgets.dart';

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
      // fontWeight: FontWeight.bold,
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
                    // if anyone sees this why does this if else need these ...
                    // I dont get it but it doesnt work without it
                    if (isCorrect) ...[
                      // Correct guess
                      const TextSpan(text: "You said this plant is a\n"),
                      TextSpan(
                        text: userPickedName,
                        style: plantNameStyle.copyWith(color: correctColor),
                      ),
                      const TextSpan(text: "\nand were correct!"),
                    ] else if (widget.userChoiceIndex != -1) ...[
                      // Incorrect guess
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
                    ] else ...[
                      // Skipped Guess
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
                child: NeonContainer(
                  borderRadius: BorderRadius.all(Radius.elliptical(15, 15)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.elliptical(15, 15)),
                    child: widget.imgURL == ""
                        ? Placeholder()
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
                        if (isCorrect) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserPointsLoadingScreen(newPoints: addPoints),
                            ),
                          );
                        } else {
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
