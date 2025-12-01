import 'package:flutter/material.dart';
import 'guess_result.dart';

class IdentificationWidget extends StatefulWidget {
  const IdentificationWidget({super.key});

  @override
  State<StatefulWidget> createState() => _Identification();
}

// main menu button for testing
class _Identification extends State<IdentificationWidget>{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:16),
          child: ElevatedButton(onPressed: () {
            Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const UserChoiceScreen(), 
                ),
            );
          }, 
          child: const Text('Model Identification'))
        )
      ),
    );
  }
}


class UserChoiceScreen extends StatefulWidget {
  final List<Map<String, dynamic>> predictions;

  const UserChoiceScreen({
    super.key, 
    required this.predictions
  });
  
  @override
  State<StatefulWidget> createState() => _UserChoiceScreen();
}

// setup stubbed plant choices based on strings
class _UserChoiceScreen extends State<UserChoiceScreen>{
  int? userChoice;
  // String modelChoice = 'Quaking Aspen';
  // var optionList = ['Quaking Aspen', 'Sugar Pine', 'Ponderosa Pine', 'Jeffery Pine', 'White Fir'];

  void selectOption(int index) {
    setState(() {
      userChoice = index;
    });
  }

  // choice selections screen, based off just a dynamic side margin but probably
  // needs defined padding instead
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
                            ? () {
                                Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (context) => ResultsWidget(userChoiceIndex: userChoice!, allPredictions: widget.predictions)
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