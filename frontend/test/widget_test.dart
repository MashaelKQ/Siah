import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';

void main() {
  testWidgets('Siah welcome message appears', (WidgetTester tester) async {
    await tester.pumpWidget(const SiahApp());

    expect(find.text('Welcome to Siah'), findsOneWidget);
    expect(find.text('Siah'), findsOneWidget);
  });
}
