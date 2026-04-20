import 'dart:io';
import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/main.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'package:identiflora/user_data/cache_utils.dart';
import 'package:identiflora/user_data/history_utils.dart';
import 'package:identiflora/user_data/offline_utils.dart';
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
  final int correctIndex;
  final String capturedImagePath;

  const TopMatchesWidget({
    super.key,
    required this.predictions,
    required this.correctIndex,
    required this.capturedImagePath,
  });

  @override
  State<TopMatchesWidget> createState() => _TopMatchesWidgetState();
}

class _TopMatchesWidgetState extends State<TopMatchesWidget> {
  /// Returns a [Color] representing how confident the model is in a prediction.
  ///
  /// - Green: score >= 0.6 (high confidence)
  /// - Orange: score >= 0.3 (moderate confidence)
  /// - Red: score < 0.3 (low confidence)
  ///
  /// These ranges may need tweaking once real-world confidence distributions
  /// are better understood.
  Color _confidenceColor(double score) {
    if (score >= 0.6) return Colors.green;
    if (score >= 0.3) return Colors.orange;
    return Colors.red;
  }

  /// Converts the raw [widget.predictions] list into a typed [List<PlantMatch>].
  ///
  /// Each prediction map is expected to have:
  /// - `'label'` (String): the scientific name from the model output
  /// - `'score'` (double): the confidence score in the range [0.0, 1.0]
  ///
  /// Common names are not yet sourced from the model — they are stubbed as
  /// `'Common Name TBD'` until a second label file or database lookup is added.
  List<PlantMatch> _buildMatches() {
    return widget.predictions.map((pred) {
      return PlantMatch(
        commonName: (pred['common_name'] as String).isNotEmpty
            ? pred['common_name'] as String
            : pred['label'] as String,
        scientificName: pred['label'],
        confidenceScore: pred['score'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<PlantMatch> allMatches = _buildMatches();
    final PlantMatch correctMatch = allMatches[widget.correctIndex];
    final List<PlantMatch> displayMatches = List.from(allMatches)
      ..removeAt(widget.correctIndex);

    return Scaffold(
      appBar: AppBar(title: const Text('Sorry about that!'), centerTitle: true),
      body: SafeArea(
        child: Scrollbar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomScrollView(
              clipBehavior: Clip.none,
              slivers: [
                const _PlantSelectionHeader(),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _PlantMatchCard(
                      match: displayMatches[index],
                      confidenceColor: _confidenceColor(
                        displayMatches[index].confidenceScore,
                      ),
                      correctMatch: correctMatch,
                      allPredictions: widget.predictions,
                      capturedImagePath: widget.capturedImagePath,
                    ),
                    childCount: displayMatches.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantSelectionHeader extends StatelessWidget {

  /// Sliver header shown above the plant-selection grid on the "Sorry about that!"
  /// screen. Prompts the user to pick the plant they believe the model should
  /// have identified.
  const _PlantSelectionHeader();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(bottom: 24.0),
        child: Text(
          "If you don't mind, could you select the plant you believe it is?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


class _PlantMatchCard extends StatelessWidget {
  final PlantMatch match;
  final Color confidenceColor;
  final PlantMatch correctMatch;
  final List<Map<String, dynamic>> allPredictions;
  final String capturedImagePath;

  /// A single card in the plant-selection grid.
  ///
  /// Fetches the species image URL via [getPlantSpeciesUrl] and renders one of
  /// three states while the future resolves:
  /// - **Loading**: centered [CircularProgressIndicator]
  /// - **Loaded**: [NeonContainer] with the fetched image and plant info
  /// - **Error / no data**: [NeonContainer] with a placeholder image and plant info
  ///
  /// Tapping the card navigates to [DisplayBigPlantScreen] for full-size preview
  /// and submission confirmation.
  ///
  /// Parameters:
  /// - [match]: the plant this card represents
  /// - [confidenceColor]: pre-computed color for the confidence score display
  /// - [correctMatch]: the plant the model originally (incorrectly) identified;
  ///   passed through to [DisplayBigPlantScreen] for comparison
  /// - [allPredictions]: the full raw predictions list; forwarded to
  ///   [DisplayBigPlantScreen] so the submission can be recorded
  /// - [capturedImagePath]: local file path of the user's captured photo;
  ///   forwarded to [DisplayBigPlantScreen] for S3 upload on submission
  const _PlantMatchCard({
    required this.match,
    required this.confidenceColor,
    required this.correctMatch,
    required this.allPredictions,
    required this.capturedImagePath,
  });

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DisplayBigPlantScreen(
          match: match,
          modelMatch: correctMatch,
          allPredictions: allPredictions,
          confidenceColor: confidenceColor,
          capturedImagePath: capturedImagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeonContainer(
      borderRadius: const BorderRadius.all(Radius.elliptical(15, 15)),
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PlantCardImage(scientificName: match.scientificName),
            _PlantCardInfo(match: match, confidenceColor: confidenceColor),
          ],
        ),
      ),
    );
  }
}

class _PlantCardImage extends StatelessWidget {
  final String scientificName;

  const _PlantCardImage({required this.scientificName});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.asset(
            localPlantAssetPath(scientificName),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Placeholder(color: Colors.grey, strokeWidth: 1.0),
          ),
        ),
      ),
    );
  }
}

///   should be produced by [_TopMatchesWidgetState._confidenceColor]
class _PlantCardInfo extends StatelessWidget {
  final PlantMatch match;
  final Color confidenceColor;

  /// The text section of a plant card — sits below the image.
  ///
  /// Displays three lines of information for [match]:
  /// 1. Common name (bold, 16 pt, max 2 lines)
  /// 2. Scientific name (bold italic, 14 pt, max 3 lines)
  /// 3. Confidence score formatted as `"XX.X% Likely"`, colored by
  ///    [confidenceColor]
  ///
  /// Used by both the loaded and fallback states of [_PlantMatchCard] to avoid
  /// duplicating the text layout.
  ///
  /// Parameters:
  /// - [match]: the plant whose names and score are displayed
  /// - [confidenceColor]: the color to apply to the confidence score text;
  const _PlantCardInfo({required this.match, required this.confidenceColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
      child: Column(
        children: [
          Text(
            match.commonName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            match.scientificName.replaceAll("_", " "),
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
    );
  }
}

// still need a none of these match button

// Display screen for zoomed in plant picture
class DisplayBigPlantScreen extends StatelessWidget {
  final PlantMatch match;
  final PlantMatch modelMatch;
  final List<Map<String, dynamic>> allPredictions;
  final Color confidenceColor;
  final String capturedImagePath;

  const DisplayBigPlantScreen({
    super.key,
    required this.match,
    required this.modelMatch,
    required this.allPredictions,
    required this.confidenceColor,
    required this.capturedImagePath,
  });

  /// Performs the full incorrect-identification submission:
  /// 1. Looks up the species IDs for both the user-selected plant and the
  ///    model's original (incorrect) prediction.
  /// 2. Saves the plant submission to get an identification ID.
  /// 3. Submits the incorrect identification record.
  ///
  /// Throws an [Exception] if the final submission fails, so [LoadingScreen]
  /// can display [errorMsg].
  Future<void> _submitIdentification() async {
    debugPrint('[IncorrectID] _submitIdentification started');
    debugPrint('[IncorrectID] capturedImagePath=$capturedImagePath');
    debugPrint('[IncorrectID] correct=${match.scientificName} incorrect=${modelMatch.scientificName}');

    final bool isOffline = await ConnService().getIsOffline;
    debugPrint('[IncorrectID] isOffline=$isOffline');

    if (isOffline) {
      debugPrint('[IncorrectID] Offline — saving to queue');
      await saveQueuedIncorrectID(QueuedIncorrectID(
        allPredictions: allPredictions,
        userGuess: match.scientificName.replaceAll("_", " "),
        latitude: 0.0,
        longitude: 0.0,
        correctSpeciesSciName: match.scientificName,
        incorrectSpeciesSciName: modelMatch.scientificName,
        imagePath: capturedImagePath,
      ));
      debugPrint('[IncorrectID] Queued successfully');
      return;
    }

    debugPrint('[IncorrectID] Online — calling savePlantSubmission');
    final int identificationId = await savePlantSubmission(
      allPredictions: allPredictions,
      userGuess: match.scientificName.replaceAll("_", " "),
      latitude: 0.0,
      longitude: 0.0,
    );
    debugPrint('[IncorrectID] savePlantSubmission returned identificationId=$identificationId');

    debugPrint('[IncorrectID] Calling submitIncorrectIdentification');
    await submitIncorrectIdentification(
      identificationId: identificationId,
      correctSpeciesSciName: match.scientificName,
      incorrectSpeciesSciName: modelMatch.scientificName,
      image: File(capturedImagePath),
    );
    debugPrint('[IncorrectID] submitIncorrectIdentification completed');
  }

  /// Builds the Submit button. On tap, navigates to a [LoadingScreen] that
  /// runs [_submitIdentification] and then routes to the home screen on success.
  DisabledButton _buildSubmitButton(BuildContext context) {
    return DisabledButton(
      enableCondition: true,
      labelText: 'Submit',
      textColor: Theme.of(context).colorScheme.primary,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => LoadingScreen<void>.withNav(
              loadingMsg: "Submitting incorrect model identification...",
              foundMsg: "Submitted! Returning to home...",
              errorMsg: "Failed to submit. Please try again.",
              futureFunction: _submitIdentification(),
              postLoadingBuilder: (context, _) => AppSetup(),
              navigateOnError: true,
            ),
          ),
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
                      child: Image.asset(
                        localPlantAssetPath(match.scientificName),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Placeholder(
                          color: Colors.grey,
                          strokeWidth: 1.0,
                        ),
                      ),
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
                      sciName.replaceAll("_", " "),
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
                    _buildSubmitButton(context),
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
