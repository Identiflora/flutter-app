import 'package:flutter/material.dart';
import 'package:identiflora/main.dart';
import 'model_incorrect.dart';

class ResultsWidget extends StatefulWidget {
  final int userChoiceIndex;
  final List<Map<String, dynamic>> allPredictions;
  final String imgURL;
  
  const ResultsWidget({
    required this.userChoiceIndex,
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
    final Map<String, dynamic> topMatch = widget.allPredictions[0];
    final String modelTopName = topMatch['label'];

    final Map<String, dynamic> userPick = widget.allPredictions[widget.userChoiceIndex];
    final String userPickedName = userPick['label'];

    final bool isCorrect = widget.userChoiceIndex == 0;

    // correct color based off themeing with a hard dark red for incorrect
    final Color incorrectColor = const Color.fromARGB(255, 180, 39, 39);
    final Color correctColor = Theme.of(context).colorScheme.primary;
    
    const TextStyle mainTextStyle = TextStyle(
      fontSize: 22,
      // fontWeight: FontWeight.bold,
      height: 1.2,
      color: Colors.black, 
    );
    
    final TextStyle plantNameStyle = mainTextStyle.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Results',
          style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
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
                    ] else ...[
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
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Plant image placeholder, need to call API in future for image
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(widget.imgURL)
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
                    child: ElevatedButton(
                      onPressed: () {
                        if (isCorrect) {
                          Navigator.push(
                            context, 
                            MaterialPageRoute<void>(
                              builder: (context) => AppSetup(),
                            )
                          );
                        }
                        else {
                          Navigator.push(
                            context, 
                            MaterialPageRoute<void>(
                              builder: (context) => AppSetup(),
                            )
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: correctColor,
                        // backgroundColor: correctColor,
                                          
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Yes'),
                    ),
                  ),
                  const SizedBox(width: 16), 
                  // No Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopMatchesWidget(predictions: widget.allPredictions),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: incorrectColor,
                        foregroundColor: incorrectColor,
                        
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('No'),
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