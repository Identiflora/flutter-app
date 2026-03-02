import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identiflora/view_account/view_account_utils.dart'; 

void main() {
  testWidgets('TappableMetric displays correct data and responds to tap', (WidgetTester tester) async {
    // Setup dummy data and a tracker for the button being pressed
    const int testValue = 42;
    const String testCategory = 'Friends';
    bool wasTapped = false;

    // Pump the widget inside a MaterialApp and Scaffold 
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TappableMetric(
            numericValue: testValue,
            category: testCategory,
            onTap: () {
              wasTapped = true; // Used to confirm gesture detector works
            },
          ),
        ),
      ),
    );

    // Verify correct data is displayed
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);

    // Verify button press did not occur yet
    expect(wasTapped, isFalse);

    // Simulate user pressing the button
    await tester.tap(find.byType(TappableMetric));

    // Rebuild the widget tree to process the button press
    await tester.pump(); 

    // Verify the button press worked
    expect(wasTapped, isTrue);
  });
}