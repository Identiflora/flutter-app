import 'package:flutter/material.dart';
import 'level_bottom_sheet.dart';
import 'badges_bottom_sheet.dart';

class ViewAccountScreen extends StatefulWidget {
  const ViewAccountScreen({super.key});

  @override
  State<ViewAccountScreen> createState() => _ViewAccountScreenState();
}

class _ViewAccountScreenState extends State<ViewAccountScreen> {
  int playerLevel = 1; //placeholder
  int playerPoints = 5; //placeholder obviously
  double normalizedPlayerPoints = 0.0;

  String username =
      "John Smith"; // need to implement retrieving username in initState

  int numFriends = 15; //need to calculate number of friends in initState

  double normalize(double value, double min, double max) {
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    normalizedPlayerPoints = normalize(
      playerPoints.toDouble(),
      0,
      10,
    ); //need to change the 10.0 to whatever max points will be
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 45.0,
            onPressed: () {
              //take you to marks settings page
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  //need to replace img's with variables later
                  child: BadgesDisplay(
                    topImg: 'assets/brand/Identiflora_logo.png',
                    middleImg: 'assets/brand/Identiflora_logo.png',
                    bottomImg: 'assets/brand/Identiflora_logo.png',
                  ),
                ),
                ProgressAvatar(normalizedPlayerPoints: normalizedPlayerPoints),
              ],
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 40.0,
                    ),
                    child: IconButton(
                      onPressed: () {
                        BadgesModalBottomSheet.show(context);
                      },
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(170),
                      ),
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(username, style: TextStyle(fontSize: 30.0)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 85.0, left: 8.0),
                        child: IconButton(
                          onPressed: () {
                            //takes you to edit username
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(170),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            //line separator begin
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 350,
                height: 7,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ), //line separator end
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TappableMetric(
                  numericValue: playerLevel,
                  category: "Level",
                  onTap: () {
                    LevelModalBottomSheet.show(context);
                  },
                ),
                TappableMetric(
                  numericValue: playerPoints,
                  category: "Points",
                  onTap: () {
                    LevelModalBottomSheet.show(
                      context,
                    ); //for now assuming levels and points can be explained on the same page.
                  },
                ),
                TappableMetric(
                  numericValue: numFriends,
                  category: "Friends",
                  onTap: () {
                    debugPrint(
                      "Friends button pressed",
                    ); //this is where you can navigate to the friends page
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BadgesDisplay extends StatelessWidget {
  final String topImg, middleImg, bottomImg;

  ///Creates a [BadgesDisplay]
  ///
  ///Column with three [CircleAvatar] widgets inside
  /// * [topImg] is the image for the top badge
  /// * [middleImg] is the image for the middle badge
  /// * [bottomImg] is the image for the bottom badge
  const BadgesDisplay({
    super.key,
    required this.topImg,
    required this.middleImg,
    required this.bottomImg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(4.0),
          child: CircleAvatar(
            foregroundImage: AssetImage(topImg),
            backgroundColor: Color.fromARGB(255, 168, 152, 2),
            radius: 25.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 40.0),
          child: CircleAvatar(
            foregroundImage: AssetImage(middleImg),
            backgroundColor: Color.fromARGB(255, 168, 23, 12),
            radius: 25.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
          child: CircleAvatar(
            foregroundImage: AssetImage(bottomImg),
            backgroundColor: Color.fromARGB(255, 16, 113, 192),
            radius: 25.0,
          ),
        ),
      ],
    );
  }
}

class ProgressAvatar extends StatelessWidget {
  final double normalizedPlayerPoints;
  final String imagePath;

  /// Creates a [ProgressAvatar]
  ///
  /// Profile picture of user ([CircleAvatar]), surrounded by a [CircularProgressIndicator], which is a visualization of the players points.
  /// * [normalizedPlayerPoints] is the players points normalized to a value between 0 and 1.
  /// * [imagePath] is the image associated with the badge to be displayed.
  const ProgressAvatar({
    super.key,
    required this.normalizedPlayerPoints,
    this.imagePath = 'assets/brand/Identiflora_logo.png',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          //begin avatar
          CircleAvatar(
            backgroundColor: Theme.of(context)
                .colorScheme
                .primary, //eventually make this a profile picture or let them choose color
            foregroundImage: const AssetImage(
              'assets/brand/Identiflora_logo.png',
            ),
            radius: 50.0, // changes the size of profile picture display
          ),
          //begin progress indicator
          SizedBox(
            width: 140.0,
            height: 140.0,
            // Tween animates progress bar filling up
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: normalizedPlayerPoints),
              duration: const Duration(seconds: 3), //speed of animation
              builder: (context, animatedValue, child) {
                //This is the actual progress bar
                return Transform.flip(
                  flipX: true,
                  child: CircularProgressIndicator(
                    value: animatedValue,
                    semanticsLabel: 'Linear progress indicator',
                    strokeWidth: 18.0,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(120),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TappableMetric extends StatelessWidget {
  final int numericValue;
  final String category;
  final VoidCallback onTap;

  /// Creates a [TappableMetric].
  ///
  /// * [numericValue] is displayed above [category].
  /// * [onTap] is the function triggered when the column is pressed. [onTap] will activate when the text or nearby location is pressed.
  const TappableMetric({
    super.key,
    required this.numericValue,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Text(
              numericValue.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            Text(category, style: TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
    );
  }
}
