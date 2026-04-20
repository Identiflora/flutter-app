import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/friends_utils.dart';
import 'package:identiflora/user_data/user_data_service.dart';
import 'package:identiflora/user_data/badge_utils.dart';
import 'package:identiflora/user_data/point_utils.dart';
import 'level_bottom_sheet.dart';
import 'package:identiflora/user_credentials/settings.dart';
import 'package:identiflora/widgets/neon_widgets.dart';

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
  String selectedBadgeFilePath = 'assets/brand/Identiflora_logo.png';

  int numFriends = 0;

  @override
  void initState() {
    super.initState();
    _loadFromService();
    _refreshInBackground();
    _loadFriendCount();
  }

  void _loadFromService() {
    final svc = UserDataService();
    playerPoints = svc.points;
    username = svc.username.isNotEmpty ? svc.username : ' ';
    if (svc.badgePath.isNotEmpty) selectedBadgeFilePath = svc.badgePath;
    levelData = calculateAccountLevel(playerPoints);
    normalizedPlayerPoints = normalize(
      levelData.value[1].toDouble(),
      0,
      levelData.value[0].toDouble(),
    );
    playerLevel = levelData.key;
  }

  Future<void> _loadFriendCount() async {
    try {
      final rawFriends = await fetchFriendsRaw();
      if (!mounted) return;

      setState(() {
        numFriends = rawFriends.length;
      });
    } catch (e) {
      // optional: handle error
    }
  }

  void _refreshInBackground() {
    UserDataService().refresh().then((_) {
      if (!mounted) return;
      setState(_loadFromService);
    });
  }

  Future<void> _showUsernameDialog() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter new username'),
            maxLength: 16,
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newUsername = controller.text.trim();
                if (newUsername == username.trim()) {
                  Navigator.of(dialogContext).pop();
                  await showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Same Username'),
                      content: const Text(
                        'The new username must be different from your current username.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                try {
                  final success = await submitUsernameChange(newUsername: newUsername);
                  if (success && mounted) {
                    UserDataService().updateUsername(newUsername);
                    setState(() => username = newUsername);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Username updated!'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update username: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            title: const Text('Account'),
            actions: [
              IconButton(
                icon: const NeonIcon(Icons.settings, size: 40.0),
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
          Expanded(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProgressAvatar(
                    normalizedPlayerPoints: normalizedPlayerPoints,
                    imagePath: selectedBadgeFilePath,
                  ),

            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: playerLevel == levelData.value[3]
                  ? const Text("Max level reached!")
                  : levelData.value[0] - levelData.value[1] == 1
                  ? Text("1 more point until level ${playerLevel + 1}!")
                  : Text("${levelData.value[1]}/${levelData.value[0]}"),
            ),

            // begin username and edit icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 56.0),
                Text(username, style: TextStyle(fontSize: 30.0)),
                IconButton(
                  onPressed: () => _showUsernameDialog(),
                  icon: NeonIcon(Icons.edit),
                ),
                SizedBox(width: 8.0),
              ],
            ), // end username and edit icon
            //line separator begin
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: NeonContainer(
                width: 350,
                height: 7,
                backgroundColor: Theme.of(context).colorScheme.secondary,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FriendsScreen()),
                    );
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
              child: BadgesDisplay(
                badges: badges,
                playerLevel: playerLevel,
                selectedBadge: selectedBadgeFilePath,
                onBadgeSelected: (badgePath) {
                  setState(() {
                    selectedBadgeFilePath = badgePath;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    ),
        ],
      ),
    );
  }
}

class BadgesDisplay extends StatefulWidget {
  final List<LevelBadge> badges;
  final int playerLevel;
  final bool isReadOnly;
  final String? selectedBadge;
  final Function(String)? onBadgeSelected;

  /// Creates a [BadgesDisplay] that generates a grid of badge images.
  const BadgesDisplay({
    super.key,
    required this.badges,
    required this.playerLevel,
    this.isReadOnly = false,
    this.selectedBadge,
    this.onBadgeSelected,
  });

  @override
  State<BadgesDisplay> createState() => _BadgesDisplayState();
}

class _BadgesDisplayState extends State<BadgesDisplay> {
  String selectedBadgeFilePath = '';

  @override
  void initState() {
    super.initState();

    if (widget.selectedBadge != null) {
      selectedBadgeFilePath = widget.selectedBadge!;
    } else {
      selectedBadgeFilePath = UserDataService().badgePath;
    }
  }

  @override
  void didUpdateWidget(covariant BadgesDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedBadge != null &&
        widget.selectedBadge != oldWidget.selectedBadge) {
      setState(() {
        selectedBadgeFilePath = widget.selectedBadge!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final int crossAxisCount = isTablet ? 6 : 4;
    final double badgeRadius = isTablet ? 20.0 : 25.0;
    final double spacing = isTablet ? 10.0 : 15.0;
    final double padding = isTablet ? 12.0 : 16.0;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.badges.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemBuilder: (context, index) {
        AccountBadge badge = widget.badges[index];

        return GestureDetector(
          onTap: () async {
            if (widget.isReadOnly) return;
            if (badge.isUnlocked(widget.playerLevel)) {
              final previousBadge = selectedBadgeFilePath;
              setState(() {
                selectedBadgeFilePath = badge.imagePath;
              });
              UserDataService().updateBadge(badge.imagePath);
              if (widget.onBadgeSelected != null) {
                widget.onBadgeSelected!(badge.imagePath);
              }

              try {
                await submitUserBadge(badgeFilePath: badge.imagePath);
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
                setState(() {
                  selectedBadgeFilePath = previousBadge;
                });
                UserDataService().updateBadge(previousBadge);
                if (widget.onBadgeSelected != null) {
                  widget.onBadgeSelected!(previousBadge);
                }
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
            badgeRadius: badgeRadius,
            isTablet: isTablet,
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
            foregroundImage: AssetImage(imagePath),
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
