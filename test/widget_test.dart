import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solasflow/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SolasFlowApp()));
    await tester.pump();
    // App should render without errors
    expect(find.byType(MaterialApp), findsOneWidget);

    // Tear down widget tree so timers are cancelled on dispose
    await tester.pumpWidget(const SizedBox());
  });
}
