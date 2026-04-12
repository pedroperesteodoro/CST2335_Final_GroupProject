import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/main.dart';
import 'package:final_project/data/database_holder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DatabaseHolder.init();
  });

  testWidgets('Main menu shows four module buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('FinalProject'), findsOneWidget);
    expect(find.text('Pet Owners'), findsOneWidget);
    expect(find.text('Pets'), findsOneWidget);
    expect(find.text('Vaccines'), findsOneWidget);
    expect(find.text('Veterinarians'), findsOneWidget);
  });
}
