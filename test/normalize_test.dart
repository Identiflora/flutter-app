import 'package:test/test.dart';
import 'package:identiflora/view_account/view_account_utils.dart';

void main() {
  group('normalize()', () {
    test('returns correct value when input is exactly in the middle', () {
      expect(normalize(5.0, 0.0, 10.0), 0.5);
    });

    test('returns 0.0 when value is equal to min', () {
      expect(normalize(0.0, 0.0, 10.0), 0.0);
    });

    test('returns 1.0 when value is equal to max', () {
      expect(normalize(10.0, 0.0, 10.0), 1.0);
    });

    test('clamps to 0.0 when value is below min', () {
      expect(normalize(-5.0, 0.0, 10.0), 0.0);
    });

    test('clamps to 1.0 when value is above max', () {
      expect(normalize(15.0, 0.0, 10.0), 1.0);
    });
  });
}
