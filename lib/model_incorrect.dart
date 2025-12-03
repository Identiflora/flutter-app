import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/main.dart';

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

  const TopMatchesWidget({
    super.key,
    required this.predictions, 
  });

  @override
  State<TopMatchesWidget> createState() => _TopMatchesWidgetState();
}

class _TopMatchesWidgetState extends State<TopMatchesWidget> {

  @override
  Widget build(BuildContext context) {
    const TextStyle mainTextStyle = TextStyle(
      fontSize: 22,
      color: Colors.black,
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
      appBar: AppBar(
        title: const Text(
          'Sorry about that!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "If you don't mind, could you select the plant you believe it is?",
                textAlign: TextAlign.center,
                style: mainTextStyle,
              ),
              const SizedBox(height: 24),
              Expanded(
                // This should lowkey maybe just be a single column scrollable grid but
                // I dont wanna mess it up rn
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
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
                      future: getPlantSpeciesUrl(scientificName: match.scientificName),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: const CircularProgressIndicator(color: Color.fromRGBO(145, 187, 32, 1)));
                        }
                        else if(snapshot.hasError) {
                          return Text("Plant image had error when loading: ${snapshot.error}");
                        }
                        else if(snapshot.hasData && snapshot.data != null) {
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: InkWell(
                              onTap: () {
                                // opens full preview of image with submission confirmation
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute<void>(
                                    builder: (context) => DisplayBigPlantScreen(match: match, imgPath: snapshot.data!),
                                  )
                                );
                              },
                              borderRadius: BorderRadius.circular(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12.0),
                                      ),
                                      // Plant image, might need to be reformatted if we are pulling from database
                                      child: Image.network(snapshot.data!),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
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
                                            fontSize: 15,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                          
                                        // Confidence Score
                                        Text(
                                          '${(match.confidenceScore * 100).toStringAsFixed(1)}% Likely',
                                          style: TextStyle(
                                            color: confidenceColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
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
                        else {
                          return const Placeholder(color: Colors.grey, strokeWidth: 1.0,);
                        }
                      }
                    );
                  },
                ),
              ),
            ],
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
  final String imgPath;

  const DisplayBigPlantScreen({super.key, required this.match, required this.imgPath});

  /// Get the appropriate text button for navigation
  ElevatedButton getButton(BuildContext context, bool identifyPage) {
    if(identifyPage) {
      return ElevatedButton(
        onPressed: () {
          // Navigate to next page
          Navigator.pop(context);
        }, 
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text("No", style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 180, 39, 39)))
        )
      );
    }

    return ElevatedButton(
      onPressed: () async {
        // where database would be sent information on the model being incorrect

        Navigator.push(
          context, 
          MaterialPageRoute<void>(
            builder: (context) => AppSetup(),
          )
        );
      }, 
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text("Yes", style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary))
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final String name = match.commonName;
    final String sciName = match.scientificName;
    final double confidence = match.confidenceScore * 100;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Is this the plant that should have been identified?", style: TextStyle(fontSize: 22, color: Colors.black), textAlign: TextAlign.center,),
                Text("$name\n$sciName\n${confidence.toStringAsFixed(1)}% Likely", style: TextStyle(fontSize: 22, color: Colors.black), textAlign: TextAlign.center,),
                Image.network(imgPath),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    getButton(context, true),
                    getButton(context, false)
                  ],
                )
              ]
            ),
          ),
        )
      )
    );
  }
}