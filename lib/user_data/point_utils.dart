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
///    1: 1,
///    2: 4, // 3 points needed
///    3: 9, // 5 points needed
///    4: 16, // 7 points needed
///    5: 25, // 9 points needed
///    6: 35, // 10 points neeeded
///    7: 45, // 10 points needed
///    8: 60, // 15 points needed
///    9: 75, // 15 points needed
///    10: 100, // 25 points needed
///    11: 125, // 25 points neeed
///    12: 150, // 25 points needed
///    13: 180, // 30 points needed
///    14: 220, // 30 points needed
///    15: 255, // 35 points needed
///    16: 290, // 35 points needed
///    17: 325, // 35 points needed
///    18: 365, // 40 points needed
///    19: 405, // 40 points needed
///    20: 455, // 50 points needed
///  };
/// ```
MapEntry<int, List<int>> calculateAccountLevel(int currentPoints) {
  // Map of account levels where key is level and value is cumulative max points needed for that level.
  final Map<int, int> accountLevels = const {
    0: 0,
    1: 1,
    2: 4, // 3 points needed
    3: 9, // 5 points needed
    4: 16, // 7 points needed
    5: 25, // 9 points needed
    6: 35, // 10 points neeeded
    7: 45, // 10 points needed
    8: 60, // 15 points needed
    9: 75, // 15 points needed
    10: 100, // 25 points needed
    11: 125, // 25 points neeed
    12: 150, // 25 points needed
    13: 180, // 30 points needed
    14: 220, // 30 points needed
    15: 255, // 35 points needed
    16: 290, // 35 points needed
    17: 325, // 35 points needed
    18: 365, // 40 points needed
    19: 405, // 40 points needed
    20: 455, // 50 points needed
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