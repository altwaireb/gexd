import 'package:flutter_test/flutter_test.dart';

import 'package:{{project_name.snakeCase()}}/main.dart';

void main() {
  testWidgets('MainApp builds and settles', (WidgetTester tester) async {
    // Build the application and ensure it boots without throwing.
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    // Basic sanity: MainApp is present in the widget tree.
    expect(find.byType(MainApp), findsOneWidget);
  });
}
