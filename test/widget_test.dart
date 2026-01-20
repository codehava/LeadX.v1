import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:leadx_crm/app.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LeadXApp(),
      ),
    );

    // Verify that splash screen is shown
    expect(find.text('LeadX CRM'), findsOneWidget);
  });
}
