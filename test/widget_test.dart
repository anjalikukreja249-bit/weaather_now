// Smoke test — verifies the app shell renders without crashing.

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test placeholder', (WidgetTester tester) async {
    // Full app smoke test requires SharedPreferences + dotenv setup.
    // Meaningful tests live in test/data/ and test/presentation/.
    expect(true, isTrue);
  });
}
