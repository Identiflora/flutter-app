/// File containing all user points based utilities and pages.
library;

/// Calculate the current account level via amount of users points to avoid storing unnecessary info in the database.<br>
/// Output is ```MapEntry(level, [additionalPointsForNextLevel, currentProgress, totalPointsForNextLevel, maxLevel])```.
/// * Default Output:
/// ```dart
/// MapEntry(0, [1, 0, 0, maxLevel])
/// ```
/// * Max Level Output:
/// ```dart
/// MapEntry(maxLevel, [currentPoints - accountLevels.values.elementAt(accountLevels.length - 2), currentPoints - accountLevels.values.elementAt(accountLevels.length - 2), accountLevels.values.elementAt(accountLevels.length - 1), maxLevel])
/// ```
/// * All Other Ouputs Determined by Range:
/// ```dart
/// final Map<int, int> accountLevels = const {
///    0: 0,
///    1: 2,   // 2 points needed   (reached after 1 identification)
///    2: 5,   // 3 points needed
///    3: 8,   // 3 points needed
///    4: 11,  // 3 points needed
///    5: 17,  // 6 points needed
///    6: 23,  // 6 points needed
///    7: 32,  // 9 points needed
///    8: 44,  // 12 points needed
///    9: 56,  // 12 points needed
///    10: 68, // 12 points needed
///    11: 83, // 15 points needed
///    12: 101, // 18 points needed
///    13: 122, // 21 points needed
///    14: 143, // 21 points needed
///    15: 164, // 21 points needed
///    16: 188, // 24 points needed
///    17: 215, // 27 points needed
///    18: 242, // 27 points needed
///    19: 269, // 27 points needed
///    20: 299, // 30 points needed  (reached after ~100 identifications)
///  };
/// ```
MapEntry<int, List<int>> calculateAccountLevel(int currentPoints) {
  // Map of account levels where key is level and value is cumulative points needed to reach that level.
  // All thresholds are ≡2 (mod 3) so users earning 3 pts/identification never land exactly on a threshold.
  final Map<int, int> accountLevels = const {
    0: 0,
    1: 2,    // 2 points needed   (reached after 1 identification)
    2: 5,    // 3 points needed
    3: 8,    // 3 points needed
    4: 11,   // 3 points needed
    5: 17,   // 6 points needed
    6: 23,   // 6 points needed
    7: 32,   // 9 points needed
    8: 44,   // 12 points needed
    9: 56,   // 12 points needed
    10: 68,  // 12 points needed
    11: 83,  // 15 points needed
    12: 101, // 18 points needed
    13: 122, // 21 points needed
    14: 143, // 21 points needed
    15: 164, // 21 points needed
    16: 188, // 24 points needed
    17: 215, // 27 points needed
    18: 242, // 27 points needed
    19: 269, // 27 points needed
    20: 299, // 30 points needed  (reached after ~100 identifications)
  };

  // Default values
  int level = 1;
  List<int> pointVals = [1, 0, 0, accountLevels.length - 1];

  // Check if level is between 1 and maxLevel - 1 and get correct values
  if (currentPoints > 0 && currentPoints < accountLevels.values.elementAt(accountLevels.length - 1)) {
    for(level = 1; level < accountLevels.length; level++) {
      if (accountLevels.containsKey(level) && accountLevels.values.elementAt(level) > currentPoints && accountLevels.containsKey(level - 1)) {
        pointVals = [
          accountLevels.values.elementAt(level) - accountLevels.values.elementAt(level - 1),
          currentPoints - accountLevels.values.elementAt(level - 1),
          accountLevels.values.elementAt(level),
          accountLevels.length - 1
        ];
        break;
      }
    }
  }
  // At max level, run special logic to ensure proper values are returned
  else if (currentPoints >= accountLevels.values.elementAt(accountLevels.length - 1)) {
    level = accountLevels.keys.elementAt(accountLevels.length - 1) + 1;
    pointVals = [
      currentPoints - accountLevels.values.elementAt(accountLevels.length - 2), 
      currentPoints - accountLevels.values.elementAt(accountLevels.length - 2), 
      accountLevels.values.elementAt(accountLevels.length - 1),
      accountLevels.length - 1
    ];
  }
  
  // Will return (0, [1, 0, 0, accountLevels.length - 1]) if default level 0 case or function has error.
  return MapEntry(level - 1, pointVals);
}