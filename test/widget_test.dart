import 'package:flutter_test/flutter_test.dart';
import 'package:holy_quran_tafseer/app.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(HolyQuranTafseerApp());
    await tester.pump();
    expect(find.byType(HolyQuranTafseerApp), findsOneWidget);
  });
}
