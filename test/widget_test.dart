import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:taji_app/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App launches and shows home page', (WidgetTester tester) async {
    await tester.pumpWidget(const TajiApp());
    await tester.pumpAndSettle();

    expect(find.text('TAJI THE CREATOR'), findsOneWidget);
    expect(find.text('Elevating Digital Art\n& Graphic Design'), findsOneWidget);
  });

  testWidgets('Swipe button is present', (WidgetTester tester) async {
    await tester.pumpWidget(const TajiApp());
    await tester.pumpAndSettle();

    expect(find.text('Swipe to start'), findsOneWidget);
  });
}
