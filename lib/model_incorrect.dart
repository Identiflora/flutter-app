import 'package:flutter/material.dart';

// object for plant information for the grid cards
// assuming that scientific name will be needed as i think thats what the model
// uses to identify each plant
class PlantMatch {
  final String commonName;
  final String scientificName; 
  final int confidenceScore;

  PlantMatch({
    required this.commonName,
    required this.scientificName,
    required this.confidenceScore,
  });
}

class TopMatchesWidget extends StatefulWidget {
  const TopMatchesWidget({super.key});

  @override
  State<TopMatchesWidget> createState() => _TopMatchesWidgetState();
}

class _TopMatchesWidgetState extends State<TopMatchesWidget> {
  // dummy plant data
  final List<PlantMatch> matches = [
    PlantMatch(commonName: 'Quaking Aspen', scientificName: 'Populus tremuloides', confidenceScore: 92),
    PlantMatch(commonName: 'Sugar Pine', scientificName: 'Pinus lambertiana', confidenceScore: 88),
    PlantMatch(commonName: 'Ponderosa Pine', scientificName: 'Pinus ponderosa', confidenceScore: 85),
    PlantMatch(commonName: 'Jeffery Pine', scientificName: 'Pinus jeffreyi', confidenceScore: 79),
    PlantMatch(commonName: 'White Fir', scientificName: 'Abies concolor', confidenceScore: 74),
  ];

  @override
  Widget build(BuildContext context) {
    final Color confidenceColor = Theme.of(context).colorScheme.primary;
    
    const TextStyle mainTextStyle = TextStyle(
      fontSize: 22,
      color: Colors.black,
    );

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
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Maybe opens full preview of image and then submission confirmation?
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
                                child: const Placeholder(
                                  color: Colors.grey,
                                  strokeWidth: 1.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
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
                                  Text(
                                    '${match.confidenceScore}% Likely',
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