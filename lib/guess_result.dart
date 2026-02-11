import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'model_incorrect.dart';

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
    final Map<String, dynamic> topMatch = widget.allPredictions[widget.correctIndex];
    final String modelTopName = topMatch['label'];
    final Map<String, dynamic> userPick;
    String userPickedName = "";
    
    // Check for bounds and skip case
    if(widget.userChoiceIndex <= 4 && widget.userChoiceIndex >= 0) {
      userPick = widget.allPredictions[widget.userChoiceIndex];
      userPickedName = userPick['label'];
    }

    final bool isCorrect = widget.userChoiceIndex == widget.correctIndex;

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

    final int addPoints = 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 5.0,
        shadowColor: Theme.of(context).colorScheme.shadow, 
        centerTitle: true,
      ),
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
                    ] else if(userPickedName != "")...[
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
                    ]
                    else ...[
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

              // Plant image placeholder, need to call API in future for image
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: widget.imgURL == "" ? Placeholder() : Image.network(widget.imgURL)
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
                      onPressed: () async {
                        if (isCorrect) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => UserPointsLoadingScreen(newPoints: addPoints),
                          ));
                        }
                        else {
                          Navigator.popUntil(context, ModalRoute.withName("/"));
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

class UserPointsLoadingScreen extends StatelessWidget {
  final int newPoints;

  const UserPointsLoadingScreen({
    super.key, required this.newPoints
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 5.0,
        shadowColor: Theme.of(context).colorScheme.shadow, 
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: submitUserGlobalPoints(addPoints: newPoints), 
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Please wait while we update your points...", 
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary)
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                    )
                  ]
                ),
              );
            }
            else if(snapshot.hasData && snapshot.data != null && snapshot.data == true) {
              // Run navigation after next frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.popUntil(context, ModalRoute.withName("/"));
              });

              // Return a found message for current frame
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Points updated! One moment...", 
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary)
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                    )
                  ]
                ),
              );
            }
            else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("We could not find your account to update points for. Please check that you are logged in and try again.",
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 20)
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName("/"));
                    }, 
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Return to Homepage")
                  )
                ],
              );
            }
          },
        )
      ),
    );
  }
}