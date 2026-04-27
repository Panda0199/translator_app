import 'package:flutter_test/flutter_test.dart';
import 'package:translator_app/main.dart';

void main() {
  testWidgets('Translator screen is shown', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Translator'), findsOneWidget);
    expect(find.text('Text to Translate:'), findsOneWidget);
    expect(find.text('Translate'), findsAtLeastNWidgets(1));
  });
}
