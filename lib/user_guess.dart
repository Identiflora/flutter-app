import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'guess_result.dart';



class UserChoiceScreen extends StatefulWidget {
  final List<Map<String, dynamic>> predictions;

  const UserChoiceScreen({
    super.key, 
    required this.predictions
  });
  
  @override
  State<StatefulWidget> createState() => _UserChoiceScreen();
}

class _UserChoiceScreen extends State<UserChoiceScreen>{
  late String imgURL;
  int? userChoice; // do need this though

  void selectOption(int index) {
    setState(() {
      userChoice = index;
    });
  }

  // choice selections screen, based off just a dynamic side margin (FractionallySizedBox) but probably
  // needs defined padding instead, i'm just a fan of it from html experience

  // i hope we keep the selection styling i spent way too much time on it
  @override
  Widget build(BuildContext context) {
    // colors based on the geen theme i put in main
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary; 
    final outlineColor = colorScheme.outline;
    final onSurfaceColor = colorScheme.onSurface; 

    
    return Scaffold(
          appBar: AppBar(
            title: const Text(
              'What plant do you think it is?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ), 
          ),
          body: Center(
            child: FractionallySizedBox(
              widthFactor: 0.75, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [
                  // probably dont need a loop for this I just copied what the tutorial
                  // did to construct a list but probably not needed since we will know
                  // the length in advance
                  // However, this could allow to randomize the order of options easily by having
                  // entry start at a random value between 0-4 to print options, just having it
                  // loop back around after 4
                  for (var entry in widget.predictions.asMap().entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0), 
                      child: TextButton(
                        onPressed: () => selectOption(entry.key),
                        style: TextButton.styleFrom(
                          foregroundColor: userChoice == entry.key ? primaryColor : onSurfaceColor,
                          backgroundColor: userChoice == entry.key ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                          side: BorderSide(
                            color: userChoice == entry.key ? primaryColor : outlineColor, 
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16.0),
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
                  const Spacer(),
                  ElevatedButton(
                          onPressed: userChoice != null
                            ? () async {
                                imgURL = await getPlantSpeciesUrl(scientificName: widget.predictions[0]['label']);
                                Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (context) => ResultsWidget(
                                      userChoiceIndex: userChoice!, 
                                      allPredictions: widget.predictions,
                                      imgURL: imgURL)
                                  ),
                                );
                              }
                            : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                              'Confirm Selection', 
                              style: TextStyle(fontSize: 18),
                          ),
                      ),
                    const Spacer(flex:10),
                ]
              ),
            ),
          ),
    );
  }
}