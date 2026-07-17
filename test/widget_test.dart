import 'package:flutter_test/flutter_test.dart';
import 'package:soil_ai/main.dart';

void main() {
  testWidgets('Soil AI Dashboard render test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SoilAiApp());

    // Verify that the dashboard header is present
    expect(find.text('SOIL AI LAB'), findsWidgets);
    expect(find.text('The Science of Soil,\nPowered by AI.'), findsOneWidget);
  });
}
