import 'package:flutter/material.dart';

/// Widget for leaderboard header display
class LeaderboardHeaderDisplay extends StatelessWidget {
  final String? leaderboardType;
  final String userRegion;

  const LeaderboardHeaderDisplay({
    super.key,
    required this.leaderboardType,
    required this.userRegion
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 8.0,
          ),
          child: Column(
            children: [
              leaderboardType == "Regional" && userRegion != "" ? 
                Text(
                  userRegion,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                )
                : Container(),

              leaderboardType == "Regional" && userRegion != "" ? 
                const SizedBox(height: 16.0)
                : Container(),

              leaderboardType == "Regional" && userRegion != "" ? 
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Theme.of(context).colorScheme.inverseSurface,
                )
                : Container(),
                  
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rank",
                    style: TextStyle(fontSize: 20.0),
                  ),

                  const SizedBox(width: 16.0),
                  Text(
                    "User",
                    style: TextStyle(fontSize: 20.0),
                  ),

                  const SizedBox(width: 16.0),
                  Text(
                    "Points",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
              
              const SizedBox(height: 8.0),
              Divider(
                height: 1.0,
                thickness: 1.0,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
}

/// Widget for leaderboard user rank display
class LeaderboardUserRankDisplay extends StatelessWidget {
  final double screenWidth;
  final int userIndex;
  final Color rankColor;

  const LeaderboardUserRankDisplay({
    super.key,
    required this.screenWidth,
    required this.userIndex,
    required this.rankColor
  });
  
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth * 0.2,
      ),
      child: Row(
        children: [
          userIndex <= 3 ? 
            Icon(
              Icons.emoji_events,
              color: rankColor,
              size: 30,
              shadows: [
                Shadow(blurRadius: 1.0),
              ],
            )
            : Icon(
              null, 
              size: 30
            ),
          userIndex < 10 ? 
              const SizedBox(width: 16.0)
              : const SizedBox(width: 6.0),
          Text(
            "#$userIndex",
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Widget for leaderboard user info display
class LeaderboardUserDisplay extends StatelessWidget {
  final double screenWidth;
  final String username;
  final String? badgeFilePath;

  const LeaderboardUserDisplay({
    super.key,
    required this.screenWidth,
    required this.username,
    required this.badgeFilePath
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth * 0.45,
      child: Row(
        children: [
          badgeFilePath != null ? 
            CircleAvatar(
              foregroundImage: AssetImage(
                badgeFilePath!,
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceBright,
              radius: 20,
            )
            : CircleAvatar(
              foregroundImage: AssetImage('assets/brand/Identiflora_logo.png'),
              backgroundColor: Theme.of(context).colorScheme.surface,
              radius: 20,
            ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              username,
              style: TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Returns max points displayable by leaderboard
int getMaxDisplayPoints() {
  return 9999;
}

/// Widget for leaderboard user points display
class LeaderboardUserPointDisplay extends StatelessWidget {
  final double screenWidth;
  final int userIndex, userPoints;
  final Color rankColor;

  const LeaderboardUserPointDisplay({
    super.key,
    required this.screenWidth,
    required this.userIndex,
    required this.userPoints,
    required this.rankColor
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxWidth: screenWidth * 0.3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.elliptical(15, 15),
        ),
        border: Border.all(
          color: rankColor == Theme.of(context).colorScheme.surface ? 
            Theme.of(context).colorScheme.primaryContainer 
            : rankColor,
          width: 3.5
        ),
        boxShadow: [
          BoxShadow(
            color: rankColor == Theme.of(context).colorScheme.surface ? 
              Theme.of(context).colorScheme.primaryContainer 
              : rankColor,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.surface,
            blurRadius: isDarkMode ? 12.5 : 7.5,
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          userPoints <= getMaxDisplayPoints() ? 
            "$userPoints pts." 
            : "9999+ pts.",
          style: TextStyle(
            fontSize: 12.0, 
            color: Theme.of(context).colorScheme.onSurface, 
            fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}