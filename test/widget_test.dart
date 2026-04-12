import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/main.dart';

void main() {
  testWidgets('Main menu shows four module buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('FinalProject'), findsOneWidget);
    expect(find.text('Pet Owners'), findsOneWidget);
    expect(find.text('Pets'), findsOneWidget);
    expect(find.text('Vaccines'), findsOneWidget);
    expect(find.text('Veterinarians'), findsOneWidget);
  });
}
