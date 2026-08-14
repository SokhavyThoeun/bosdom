import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bosdom/main.dart';

void main() {
  testWidgets('App renders root screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BosdomApp()));

    expect(find.text('Bosdom'), findsWidgets);
  });
}
