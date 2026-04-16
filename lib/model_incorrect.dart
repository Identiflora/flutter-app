import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/main.dart';
import 'package:identiflora/widgets/neon_widgets.dart';
import 'package:identiflora/widgets/button_widgets.dart';

// object for plant information for the grid cards
class PlantMatch {
  final String commonName;
  final String scientificName;
  final double confidenceScore;

  PlantMatch({
    required this.commonName,
    required this.scientificName,
    required this.confidenceScore,
  });
}

class TopMatchesWidget extends StatefulWidget {
  final List<Map<String, dynamic>> predictions;

  const TopMatchesWidget({super.key, required this.predictions});

  @override
  State<TopMatchesWidget> createState() => _TopMatchesWidgetState();
}

class _TopMatchesWidgetState extends State<TopMatchesWidget> {
  @override
  Widget build(BuildContext context) {
    const TextStyle mainTextStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );

    final List<PlantMatch> matches = widget.predictions.map((pred) {
      return PlantMatch(
        // no implementation for commonName yet, needs either a second label text document
        // with common name or get it get from database
        commonName: 'Common Name TBD',
        scientificName: pred['label'],
        confidenceScore: pred['score'],
        // maybe plant image could included here as well, still not sure how that will
        // work with getting it from the database
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sorry about that!'), centerTitle: true),
      body: SafeArea(
        child: Scrollbar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomScrollView(
              clipBehavior: Clip.none,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: const Text(
                      "If you don't mind, could you select the plant you believe it is?",
                      textAlign: TextAlign.center,
                      style: mainTextStyle,
                    ),
                  ),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.6,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final match = matches[index];
                    Color confidenceColor;
                    // these ranges might to be tweaked based on what the average
                    // confidence scores seem to actually be in practice
                    if (match.confidenceScore >= 0.6) {
                      confidenceColor = Colors.green;
                    } else if (match.confidenceScore >= 0.3) {
                      confidenceColor = Colors.orange;
                    } else {
                      confidenceColor = Colors.red;
                    }
                    return FutureBuilder(
                      future: getPlantSpeciesUrl(
                        scientificName: match.scientificName,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final String imageUrl = snapshot.data!;
                          final bool isPlaceholder =
                              imageUrl.isEmpty ||
                              imageUrl.startsWith("https://placeholder");

                          return NeonContainer(
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(15, 15),
                            ),
                            child: InkWell(
                              onTap: () {
                                // opens full preview of image with submission confirmation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => DisplayBigPlantScreen(
                                      match: match,
                                      modelMatch: matches[0],
                                      imgPath: snapshot.data!,
                                      confidenceColor: confidenceColor,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        8.0,
                                        8.0,
                                        8.0,
                                        0,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                        // Plant image, might need to be reformatted if we are pulling from database
                                        child: isPlaceholder
                                            ? const Placeholder(
                                                color: Colors.grey,
                                                strokeWidth: 1.0,
                                              )
                                            : Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10.0,
                                      8.0,
                                      10.0,
                                      8.0,
                                    ),
                                    child: Column(
                                      children: [
                                        // Common Name
                                        Text(
                                          match.commonName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),

                                        // Scientific Name
                                        Text(
                                          match.scientificName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),

                                        // Confidence Score
                                        Text(
                                          '${(match.confidenceScore * 100).toStringAsFixed(1)}% Likely',
                                          style: TextStyle(
                                            color: confidenceColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(15, 15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurStyle: BlurStyle.outer,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                // opens full preview of image with submission confirmation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => DisplayBigPlantScreen(
                                      match: match,
                                      modelMatch: matches[0],
                                      imgPath: "",
                                      confidenceColor: confidenceColor,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        8.0,
                                        8.0,
                                        8.0,
                                        0,
                                      ),
                                      child: ClipRRect(
                                        child: const Placeholder(
                                          color: Colors.grey,
                                          strokeWidth: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10.0,
                                      8.0,
                                      10.0,
                                      8.0,
                                    ),
                                    child: Column(
                                      children: [
                                        // Common Name
                                        Text(
                                          match.commonName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),

                                        // Scientific Name
                                        Text(
                                          match.scientificName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),

                                        // Confidence Score
                                        Text(
                                          '${(match.confidenceScore * 100).toStringAsFixed(1)}% Likely',
                                          style: TextStyle(
                                            color: confidenceColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }, childCount: matches.length),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// still need a none of these match button

// Display screen for zoomed in plant picture
class DisplayBigPlantScreen extends StatelessWidget {
  final PlantMatch match;
  final PlantMatch modelMatch;
  final int identification_id;
  final String imgPath;
  final Color confidenceColor;

  const DisplayBigPlantScreen({
    super.key,
    required this.match,
    required this.modelMatch,
    required this.identification_id,
    required this.imgPath,
    required this.confidenceColor,
  });

  /// Get the appropriate text button for navigation.<br><br>
  /// identifyPage = true = no button<br>
  /// identifyPage = false = yes button
  DisabledButton getButton(BuildContext context, bool identifyPage) {
    if (identifyPage) {
      return DisabledButton(
        enableCondition: true,
        labelText: 'No',
        textColor: Theme.of(context).colorScheme.error,
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }

    return DisabledButton(
      enableCondition: true,
      labelText: 'Yes',
      textColor: Theme.of(context).colorScheme.primary,
      onPressed: () async {
        // where database would be sent information on the model being incorrect

        // make call to database to get the ids of the plants
        debugPrint("model pick: ${modelMatch.scientificName}");
        int incorrectSpeciesId = await getPlantSpeciesID(
          scientificName: match.scientificName,
        );
        int correctSpeciesId = await getPlantSpeciesID(
          scientificName: modelMatch.scientificName,
        );

        // Make it so that the function that stores an identification submission
        // returns the identification_id of the submission, use that here to submit
        // the incorrect identification

        // need to implement offline functionality for this

        // // submit the incorrect identification to the database
        // if (!(await submitIncorrectIdentification(
        //   identificationId: identificationId,
        //   correctSpeciesId: correctSpeciesId,
        //   incorrectSpeciesId: incorrectSpeciesId,
        // ))) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text("Please complete all fields"),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        // }

        //above cannot be completed until history is implemented.

        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => AppSetup()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = match.commonName;
    final String sciName = match.scientificName;
    final double confidence = match.confidenceScore * 100;

    return Scaffold(
      appBar: AppBar(title: Text("Is this correct?"), centerTitle: true),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Scrollbar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Text(
                      "Is this the plant that should have been identified?",
                      style: TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24.0),
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
                      child:
                          (imgPath == "" ||
                              imgPath.startsWith("https://placeholder"))
                          ? const Placeholder(
                              color: Colors.grey,
                              strokeWidth: 1.0,
                            )
                          : Image.network(imgPath, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      "Common Name",
                      style: TextStyle(
                        fontSize: 22,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      "Scientific Name",
                      style: TextStyle(
                        fontSize: 22,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      sciName,
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      "Model identified this as",
                      style: TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "${confidence.toStringAsFixed(1)}% Likely",
                      style: TextStyle(
                        fontSize: 22,
                        color: confidenceColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: getButton(context, false)),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: getButton(context, true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
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
