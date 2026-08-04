import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app.dart';

void main() {
  testWidgets('Siah app starts successfully', (tester) async {
    await tester.pumpWidget(const SiahApp());

    // Confirms that the application renders without crashing.
    expect(find.byType(SiahApp), findsOneWidget);
  });
}
