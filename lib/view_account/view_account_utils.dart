import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/user_data/point_utils.dart';
import 'level_bottom_sheet.dart';
import 'package:identiflora/settings.dart';

class ViewAccountScreen extends StatefulWidget {
  const ViewAccountScreen({super.key});

  @override
  State<ViewAccountScreen> createState() => _ViewAccountScreenState();
}

class _ViewAccountScreenState extends State<ViewAccountScreen> {
  MapEntry<int, List<int>> levelData = MapEntry(0, [1, 0, 0, -1]);
  int playerLevel = 0;
  int playerPoints = 0;
  double normalizedPlayerPoints = 0.0;
  List<String> badgeImages = [
    'assets/brand/Identiflora_logo.png',
    'assets/brand/Identiflora_logo.png',
    'assets/brand/Identiflora_logo.png',
    'assets/brand/Identiflora_logo.png',
  ]; //this is the list thats passed to the gridview to display the badges

  String username =
      "Not found"; // need to implement retrieving username in initState

  int numFriends = 15; //need to calculate number of friends in initState

  double normalize(double value, double min, double max) {
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();

    _getPlayerPoints().then((response) {
      setState(() {
        playerPoints = response;
        levelData = calculateAccountLevel(playerPoints);
        normalizedPlayerPoints = normalize(
          levelData.value[1].toDouble(),
          0,
          levelData.value[0].toDouble(),
        );
        debugPrint("${levelData.value[0]}, ${levelData.value[1].toDouble()}");
        playerLevel = levelData.key;
      });
    });

    _getPlayerUsername().then((response) {
      setState(() {
        username = response;
      });
    });
  }

  Future<int> _getPlayerPoints() async {
    return await getUserPoints();
  }

  Future<String> _getPlayerUsername() async {
    return await getUsername();
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProgressAvatar(normalizedPlayerPoints: normalizedPlayerPoints),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 56.0),
                Text(username, style: TextStyle(fontSize: 30.0)),
                IconButton(
                  onPressed: () {
                    //takes you to edit username
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary.withAlpha(170),
                  ),
                ),
                SizedBox(width: 8.0),
              ],
            ),
            playerLevel == levelData.value[3] ? const Text("Max level reached!") :
            levelData.value[0] - levelData.value[1] == 1 ? 
              Text("1 more point until level ${playerLevel + 1}!") 
              : Text("${levelData.value[0] - levelData.value[1]} more points until level ${playerLevel + 1}!"),
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
            Expanded(child: BadgesDisplay(badgeImages: badgeImages)),
          ],
        ),
      ),
    );
  }
}

class BadgesDisplay extends StatelessWidget {
  final List<String> badgeImages;

  /// Creates a [BadgesDisplay] that generates a grid of badge images.
  const BadgesDisplay({super.key, required this.badgeImages});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      itemCount: badgeImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Number of badges per row
        crossAxisSpacing: 15.0, // Horizontal space between badges
        mainAxisSpacing: 15.0, // Vertical space between rows
      ),
      itemBuilder: (context, index) {
        return CircleAvatar(
          radius: 25.0,
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
          foregroundImage: AssetImage(badgeImages[index]),
        );
      },
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
