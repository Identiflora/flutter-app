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
  late final String correctChoice;
  late ScrollController _scrollController;

  void selectOption(int index) {
    setState(() {
      userChoice = index;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    correctChoice = widget.predictions.first['label'];
    widget.predictions.shuffle();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final int correctIndex = widget.predictions.indexWhere((element) => element['label'] == correctChoice);

    return Scaffold(
          appBar: AppBar(
            title: const Text('What do you think?'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Scrollbar(
                controller: _scrollController,
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.8, 
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch, 
                        children: [
                          // probably dont need a loop for this I just copied what the tutorial
                          // did to construct a list but probably not needed since we will know
                          // the length in advance
                          // However, this could allow to randomize the order of options easily by having
                          // entry start at a random value between 0-4 to print options, just having it
                          // loop back around after 4
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: const Text("Guess what plant this is from the options below!", 
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 3),
                          for (var entry in widget.predictions.asMap().entries)
                            Padding(
                              padding: entry.key == widget.predictions.asMap().length ? const EdgeInsets.only() : const EdgeInsets.only(bottom: 8.0),
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
                          const SizedBox(height: 2),
                          ElevatedButton(
                                  onPressed: userChoice != null
                                    ? () {
                                        Navigator.push(context,
                                          MaterialPageRoute(
                                            builder: (context) => UserChoiceLoadingScreen(
                                              userChoiceIndex: userChoice!, 
                                              correctIndex: correctIndex,
                                              allPredictions: widget.predictions,
                                            )
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
                          const SizedBox(height: 4),
                         ElevatedButton(
                            onPressed: userChoice == null
                              ? () {
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                      builder: (context) => UserChoiceLoadingScreen(
                                        userChoiceIndex: -1, 
                                        correctIndex: correctIndex,
                                        allPredictions: widget.predictions,
                                      )
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
                                'Skip Selection', 
                                style: TextStyle(fontSize: 18),
                            ),),
                          const SizedBox(height:10),
                        ]
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

class UserChoiceLoadingScreen extends StatelessWidget {
  final int userChoiceIndex;
  final int correctIndex;
  final List<Map<String, dynamic>> allPredictions;

  const UserChoiceLoadingScreen({
    super.key,
    required this.userChoiceIndex,
    required this.correctIndex,
    required this.allPredictions
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: getPlantSpeciesUrl(scientificName: allPredictions[correctIndex]['label']), 
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Please wait while we retrieve this identification information...", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                  )
                ]
              );
            }
            else if(snapshot.hasData && snapshot.data != null) {
              // Run navigation after next frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Remove loading screen from stack
                Navigator.pop(context);

                // Navigate to new screen
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => ResultsWidget(
                      userChoiceIndex: userChoiceIndex, 
                      correctIndex: correctIndex,
                      allPredictions: allPredictions,
                      imgURL: snapshot.data!)
                  ),
                );
              });

              // Return a found message for current frame
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Identification information found! One moment...", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                  ),
                ]
              );
            }
            else {
              // Run navigation after next frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Remove loading screen from stack
                Navigator.pop(context);

                // Navigate to new screen
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => ResultsWidget(
                      userChoiceIndex: userChoiceIndex, 
                      correctIndex: correctIndex,
                      allPredictions: allPredictions,
                      imgURL: "")
                  ),
                );
              });

              // Return a found message for current frame
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Unable to find identification information. One moment...", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                  ),
                ]
              );
            }
          }
        )
      ),
    );
  }
}

