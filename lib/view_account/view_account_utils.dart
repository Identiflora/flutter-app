import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/user_data/badge_utils.dart';
import 'package:identiflora/user_data/point_utils.dart';
import 'level_bottom_sheet.dart';
import 'package:identiflora/settings.dart';

double normalize(double value, double min, double max) {
  return ((value - min) / (max - min)).clamp(0.0, 1.0);
}

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
  List<LevelBadge> badges = [
    LevelBadge(imagePath: 'assets/badge/seed_badge.png', unlockAtLevel: 5),
    LevelBadge(imagePath: 'assets/badge/sprout_badge.png', unlockAtLevel: 10),
    LevelBadge(imagePath: 'assets/badge/sapling_badge.png', unlockAtLevel: 15),
    LevelBadge(imagePath: 'assets/badge/tree_badge.png', unlockAtLevel: 20),
  ]; //this is the list thats passed to the gridview to display the badges

  String username = " ";

  int numFriends = 15; //need to calculate number of friends in initState

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
    List<Shadow> iconShadows = [
      BoxShadow(
        color: Theme.of(context).colorScheme.secondary,
        blurRadius: 2.0,
        spreadRadius: 1.0,
      ),
      BoxShadow(
        color: Theme.of(context).colorScheme.primary,
        blurRadius: 15.0,
        spreadRadius: 2.0,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.secondary,
              shadows: iconShadows,
            ),
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

            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: playerLevel == levelData.value[3]
                  ? const Text("Max level reached!")
                  : levelData.value[0] - levelData.value[1] == 1
                  ? Text("1 more point until level ${playerLevel + 1}!")
                  : Text("${levelData.value[1]}/${levelData.value[0]}"),
            ),
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
                    color: Theme.of(context).colorScheme.secondary,
                    shadows: [
                      Shadow(
                        color: Theme.of(context).colorScheme.primary,
                        blurRadius: 5.0,
                      ),
                      Shadow(
                        color: Theme.of(context).colorScheme.primary,
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.0),
              ],
            ),
            // playerLevel == levelData.value[3]
            //     ? const Text("Max level reached!")
            //     : levelData.value[0] - levelData.value[1] == 1
            //     ? Text("1 more point until level ${playerLevel + 1}!")
            //     : Text(
            //         "${levelData.value[0] - levelData.value[1]} more points until level ${playerLevel + 1}!",
            //       ),
            //line separator begin
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 350,
                height: 7,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.secondary,
                      blurRadius: 2.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary,
                      blurRadius: 6.0,
                      spreadRadius: 1.0,
                    ),
                  ],
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

            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Container(
            //     width: 350,
            //     height: 7,
            //     decoration: BoxDecoration(
            //       color: Theme.of(context).colorScheme.primary,
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: const Text("Badges", style: TextStyle(fontSize: 20.0)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 2.0,
              ),
              child: Divider(
                height: 0.5,
                thickness: 0.5,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),

            Expanded(
              child: BadgesDisplay(badges: badges, playerLevel: playerLevel),
            ),
          ],
        ),
      ),
    );
  }
}

class BadgesDisplay extends StatefulWidget {
  final List<LevelBadge> badges;
  final int playerLevel;

  /// Creates a [BadgesDisplay] that generates a grid of badge images.
  const BadgesDisplay({
    super.key,
    required this.badges,
    required this.playerLevel,
  });

  @override
  State<BadgesDisplay> createState() => _BadgesDisplayState();
}

class _BadgesDisplayState extends State<BadgesDisplay> {
  String selectedBadgeFilePath = '';

  Future<String> _getPlayerSelectedBadge() async {
    return await fetchUserBadge();
  }

  @override
  void initState() {
    super.initState();

    _getPlayerSelectedBadge().then((response) {
      setState(() {
        selectedBadgeFilePath = response;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Number of badges per row
        crossAxisSpacing: 15.0, // Horizontal space between badges
        mainAxisSpacing: 15.0, // Vertical space between rows
      ),
      itemBuilder: (context, index) {
        AccountBadge badge = widget.badges[index];

        return GestureDetector(
          onTap: () async {
            if (badge.isUnlocked(widget.playerLevel)) {
              // Run API based selection logic here
              try {
                await submitUserBadge(badgeFilePath: badge.imagePath);

                setState(() {
                  selectedBadgeFilePath = badge.imagePath;
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Badge selected!"),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Badge selection storing failed: $error"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(badge.getUnlockMessage()),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
          },
          child: getBadgeDisplay(
            context,
            badge,
            badge.isUnlocked(widget.playerLevel),
            selectedBadgeFilePath == badge.imagePath,
          ),
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
      padding: const EdgeInsets.only(top: 22.0, bottom: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          //begin avatar
          CircleAvatar(
            backgroundColor: Theme.of(context)
                .colorScheme
                .surface, //eventually make this a profile picture or let them choose color
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Outter glow of progress indicator
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 22.0,
                          sigmaY: 22.0,
                        ),
                        child: CircularProgressIndicator(
                          value: animatedValue,
                          strokeWidth: 24.0,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.transparent,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(80),
                        ),
                      ),

                      // Inner glow of progress indicator
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                        child: CircularProgressIndicator(
                          value: animatedValue,
                          strokeWidth: 12.0,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.transparent,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      CircularProgressIndicator(
                        value: animatedValue,
                        semanticsLabel: 'Linear progress indicator',
                        strokeWidth: 12.0,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(50),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
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
