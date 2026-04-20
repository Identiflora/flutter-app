/// File containing all user badge based utilities.
library;

import 'package:flutter/material.dart';

/// Base account badge class<br>
/// ```dart
/// AccountBadge(String imagePath);
/// ```
abstract class AccountBadge {
  final String imagePath;
  late AssetImage displayImage;

  AccountBadge({required this.imagePath}) {
    displayImage = AssetImage(imagePath);
  }

  AccountBadge.withImage({required this.imagePath, required this.displayImage});

  /// Overridable method for returning the status of badge being unlocked
  bool isUnlocked(int playerLevel);

  /// Overridable method for returning badge unlock condition as a string
  String getUnlockMessage();
}

/// LevelBadge class for level based badge rewards
/// ```dart
/// LevelBadge(String imagePath, int unlockAtLevel);
/// ```
/// Also contains
/// ```dart
/// bool isUnlocked(int playerLevel) {
///   return unlockAtLevel <= playerLevel;
/// }
/// ```
class LevelBadge extends AccountBadge {
  int unlockAtLevel;

  LevelBadge({required super.imagePath, required this.unlockAtLevel});

  LevelBadge.withImage({
    required super.imagePath,
    required dynamic displayImage,
    required this.unlockAtLevel,
  });

  set setUnlockAtLevel(int newLevel) {
    unlockAtLevel = newLevel;
  }

  int get getUnlockAtLevel {
    return unlockAtLevel;
  }

  @override
  bool isUnlocked(int playerLevel) {
    return unlockAtLevel <= playerLevel;
  }

  @override
  String getUnlockMessage() {
    return "You need to reach level $getUnlockAtLevel to unlock this badge!";
  }
}

/// Helper function to compute badge profile display based on the boolean given to avoid messy code. Most badges should be unlocked by the method below.
/// ```dart
/// badge.isUnlocked(unlockParameter)
/// ```
Widget getBadgeDisplay(
  BuildContext context,
  AccountBadge badge,
  bool unlockCondition,
  bool isSelected,
) {
  return Stack(
    fit: StackFit.expand,
    children: [
      CircleAvatar(
        radius: 25.0,
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        backgroundImage: badge.displayImage,
        child: unlockCondition
            ? null
            : CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black.withAlpha(150),
                foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                child: Icon(Icons.lock_person_rounded, size: 35),
              ),
      ),
      isSelected
          ? Positioned(
              right: 0,
              bottom: 0,
              // Child is declared this way instead of using icons.check_circle so that checkmark isn't translucent
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.surface,
                  size: 20,
                ),
              ),
            )
          : Container(),
    ],
  );
}
