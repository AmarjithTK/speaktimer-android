import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solasflow/core/pref_keys.dart';
import 'package:solasflow/widgets/kokoro_download_consent_dialog.dart';

import 'package:solasflow/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      PrefKeys.linuxKokoroConsentPromptSeen: true,
    });
    await tester.pumpWidget(const ProviderScope(child: SolasFlowApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('First Linux launch asks before starting the Kokoro download', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: SolasFlowApp()));

    for (
      var attempt = 0;
      attempt < 40 &&
          find.text('Download the Kokoro English voice?').evaluate().isEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Download the Kokoro English voice?'), findsOneWidget);
    expect(find.text('Accept and download'), findsOneWidget);
    await tester.tap(find.text('Keep Piper'));
    await tester.pump();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(PrefKeys.linuxKokoroConsentPromptSeen), isTrue);
    expect(
      preferences.getBool(PrefKeys.linuxKokoroConsentAccepted),
      isNot(true),
    );
    await tester.pumpWidget(const SizedBox());
  }, skip: !Platform.isLinux || _kokoroModelAlreadyInstalled());

  testWidgets('Consent dialog exposes accept and decline actions', (
    WidgetTester tester,
  ) async {
    var accepted = false;
    var declined = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KokoroDownloadConsentDialog(
            onAccept: () => accepted = true,
            onDecline: () => declined = true,
          ),
        ),
      ),
    );
    expect(find.textContaining('140 MiB'), findsOneWidget);

    await tester.tap(find.text('Keep Piper'));
    expect(declined, isTrue);
    expect(accepted, isFalse);
    await tester.tap(find.text('Accept and download'));
    expect(accepted, isTrue);
  });
}

bool _kokoroModelAlreadyInstalled() {
  final home = Platform.environment['HOME'];
  if (home == null || home.isEmpty) return false;
  const modelFiles = [
    'model.int8.onnx',
    'tokens.txt',
    'voices.bin',
    'lexicon-us-en.txt',
  ];
  return modelFiles.every(
    (name) => File(
      '$home/.local/share/solasflow_runtime/assets/tts/models/en/kokoro/$name',
    ).existsSync(),
  );
}
