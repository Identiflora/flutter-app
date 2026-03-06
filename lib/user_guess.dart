import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'package:identiflora/widgets/neon_widgets.dart';
import 'guess_result.dart';
import 'package:identiflora/widgets/button_widgets.dart';

class UserChoiceScreen extends StatefulWidget {
  final List<Map<String, dynamic>> predictions;

  const UserChoiceScreen({super.key, required this.predictions});

  @override
  State<StatefulWidget> createState() => _UserChoiceScreen();
}

class _UserChoiceScreen extends State<UserChoiceScreen> {
  late String imgURL;
  int? userChoice; // do need this though
  late final String correctChoice;

  void selectOption(int index) {
    setState(() {
      userChoice = index;
    });
  }

  @override
  void initState() {
    correctChoice = widget.predictions.first['label'];
    widget.predictions.shuffle();
    super.initState();
  }

  // choice selections screen, based off just a dynamic side margin (FractionallySizedBox) but probably
  // needs defined padding instead, i'm just a fan of it from html experience

  // i hope we keep the selection styling i spent way too much time on it
  @override
  Widget build(BuildContext context) {
    // colors based on the geen theme i put in main
    final colorScheme = Theme.of(context).colorScheme;
    // final primaryColor = colorScheme.primary;
    // final inversePrimaryColor = colorScheme.inversePrimary;
    // final outlineColor = colorScheme.outline;
    final int correctIndex = widget.predictions.indexWhere(
      (element) => element['label'] == correctChoice,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('What do you think?'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // probably dont need a loop for this I just copied what the tutorial
                    // did to construct a list but probably not needed since we will know
                    // the length in advance
                    // However, this could allow to randomize the order of options easily by having
                    // entry start at a random value between 0-4 to print options, just having it
                    // loop back around after 4
                    const Text(
                      "Guess what plant this is from the options below!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                    const SizedBox(height: 16.0),
                    for (var entry in widget.predictions.asMap().entries)
                      Padding(
                        padding: entry.key == widget.predictions.asMap().length
                            ? const EdgeInsets.only()
                            : const EdgeInsets.only(bottom: 16.0),
                        child: userChoice == entry.key
                            ? NeonOutlinedButton(
                                onPressed: () => selectOption(entry.key),
                                borderRadius: BorderRadius.circular(8),
                                borderWidth: 4,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                labelText: entry.value['label'],
                              )
                            : TextButton(
                                onPressed: () => selectOption(entry.key),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  entry.value['label'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    const SizedBox(height: 8.0),
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),

                    const SizedBox(height: 16.0),
                    DisabledButton(
                      enableCondition: userChoice != null,
                      labelText: 'Confirm Selection',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoadingScreen<String>.withNav(
                              loadingMsg: "Please wait while we retrieve this identification information...", 
                              foundMsg: "Identification information found! One moment...", 
                              errorMsg: "Unable to find identification information. One moment...", 
                              futureFunction: getPlantSpeciesUrl(
                                scientificName: widget.predictions[correctIndex]['label']
                              ),
                              postLoadingBuilder: (context, imgURL) => ResultsWidget(
                                userChoiceIndex: userChoice!,
                                correctIndex: correctIndex,
                                allPredictions: widget.predictions,
                                imgURL: imgURL ?? "",
                              ),
                              navigateOnError: true,
                            )
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8.0),
                    DisabledButton(
                      enableCondition: userChoice == null,
                      labelText: 'Skip Selection',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoadingScreen<String>.withNav(
                              loadingMsg: "Please wait while we retrieve this identification information...", 
                              foundMsg: "Identification information found! One moment...", 
                              errorMsg: "Unable to find identification information. One moment...", 
                              futureFunction: getPlantSpeciesUrl(
                                scientificName: widget.predictions[correctIndex]['label']
                              ),
                              postLoadingBuilder: (context, imgURL) => ResultsWidget(
                                userChoiceIndex: -1,
                                correctIndex: correctIndex,
                                allPredictions: widget.predictions,
                                imgURL: imgURL ?? "",
                              ), 
                              navigateOnError: true,
                            )
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
