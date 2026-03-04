import 'package:identiflora/user_data/point_utils.dart';
import 'package:test/test.dart';

void main() {
  group('User account level test:', () {
    // Setup variables
    MapEntry<int, List<int>> entry = calculateAccountLevel(0), pastEntry;
    final int checkPointsTill = 1000, maxLevel = entry.value[3];

    // Ensure default function return is same as comments documented
    test('Account level default', () {
      expect(entry.key, 0);
      expect(entry.value[0], 1);
      expect(entry.value[1], 0);
      expect(entry.value[2], 0);
      expect(entry.value[0] - entry.value[1], greaterThan(0));
    });

    // Ensure that the max level greater than 0
    test('Account maxLevel parameter greater than 0', () {
      expect(maxLevel, greaterThan(0));
    });

    // Run through reasonable amount of user point values to check for invalid trends
    for(int i = 1; i <= checkPointsTill; i++) {
      test('Check account point value $i/$checkPointsTill', () {
        pastEntry = entry;
        entry = calculateAccountLevel(i);
        
        // Ensure keys (levels) are increasing
        expect(entry.key, greaterThanOrEqualTo(pastEntry.key));

        // Ensure values are all 0 or positive
        expect(entry.value[0], greaterThanOrEqualTo(0));
        expect(entry.value[1], greaterThanOrEqualTo(0));
        expect(entry.value[2], greaterThan(0));

        // Ensure max level is consistant
        expect(entry.value[3], equals(maxLevel));

        // Ensure that points for next level and progress never reach or go below 0 unless at max level
        if(entry.key < maxLevel) {
          expect(entry.value[0] - entry.value[1], greaterThan(0));
        }
      });
    }
  });
}