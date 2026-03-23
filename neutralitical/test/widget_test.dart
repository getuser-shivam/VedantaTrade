import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neutralitical/main.dart';

void main() {
  testWidgets('gallery home renders key showcase sections', (
    WidgetTester tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(const NeutraliticalApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Neutralitical UI release gallery'), findsOneWidget);
    expect(find.text('UI release timeline'), findsOneWidget);
  });
}
