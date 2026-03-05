import 'package:flutter_test/flutter_test.dart';
import 'package:identiflora/model.dart';

void main() {
  group('AI Model Output Test(s)', () {
    final service = OfflinePlantService();

    test('softmax converts logits into a valid probability distribution', () {
      final List<double> logits = [14.2, 3.5, -2.1, -10.0, -18.4];
      final results = service.softmax(logits);
      
      // Total probability must sum to approximately 1.0 
      double totalProbability = results.reduce((a, b) => a + b);
      expect(totalProbability, closeTo(1.0, 0.0001));

      // Top result should have a confidence score of 0.99 by design if the softmax
      // normalizes the logits correctly
      expect(results[0], greaterThan(0.99));
      
      // Highest logit (14.2 at index 0) must result in the highest probability
      // 14.2 is significantly higher than 3.5, so index 0 should be > 99% confidence
      expect(results[0], greaterThan(results[1])); 
      expect(results[1], greaterThan(results[2]));
      expect(results[2], greaterThan(results[3]));
      expect(results[3], greaterThan(results[4]));
      
    });
  });
}
