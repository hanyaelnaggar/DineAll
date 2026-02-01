import 'package:flutter_test/flutter_test.dart';
import 'package:dineall/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DineAllApp());

    // Verify that the title "DineAll" is present.
    expect(find.text('DineAll'), findsOneWidget);
    
    // Verify that the tagline is present.
    expect(find.text('One App, Endless Eats & Drinks'), findsOneWidget);
  });
}
