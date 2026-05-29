import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solasflow/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SolasFlowApp());
    await tester.pump();
    // App should render without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
