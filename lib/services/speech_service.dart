import 'dart:io';
import 'dart:convert';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';

import '../models/speech_item.dart';

class SpeechService {
  Map<String, dynamic>? _sherpaManifestCache;

  String _shellSingleQuoteEscape(String text) {
    return text.replaceAll("'", "'\\''");
  }

  String normalizeSpeechEngineMode(String mode) {
    final normalized = mode.trim().toLowerCase();
    switch (normalized) {
      case 'auto':
      case 'system_only':
      case 'sherpa_only':
        return normalized;
      default:
        return 'auto';
    }
  }

  String _linuxEspeakVoice({required bool useMalayalamNuance}) {
    return useMalayalamNuance ? 'ml' : 'en';
  }

  Future<bool> _speakOnLinuxFallback({
    required String text,
    required bool useMalayalamNuance,
  }) async {
    final shell = Shell();
    final escapedText = _shellSingleQuoteEscape(text);
    final voice = _linuxEspeakVoice(useMalayalamNuance: useMalayalamNuance);

    // Ordered fallback chain for Linux desktop distributions.
    final commands = <String>[
      "espeak-ng -v $voice '$escapedText'",
      "spd-say -w -l $voice '$escapedText'",
      "spd-say -w '$escapedText'",
    ];

    for (final command in commands) {
      try {
        await shell.run(command);
        return true;
      } catch (_) {
        // Try next fallback command.
      }
    }

    return false;
  }

  Future<Map<String, dynamic>?> _loadSherpaManifest() async {
    if (_sherpaManifestCache != null) return _sherpaManifestCache;
    try {
      final raw = await rootBundle.loadString('assets/tts/models_manifest.json');
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _sherpaManifestCache = decoded;
        return _sherpaManifestCache;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _manifestModelsForLanguage(
    Map<String, dynamic> manifest,
    String language,
  ) {
    final models = manifest['models'];
    if (models is! List) return const [];
    return models
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .where((m) => (m['language']?.toString().toLowerCase() ?? '') == language)
        .toList();
  }

  Future<bool> _speakWithSherpaDesktop({
    required String text,
    required bool useMalayalamNuance,
  }) async {
    if (!(Platform.isLinux || Platform.isWindows)) {
      return false;
    }

    final manifest = await _loadSherpaManifest();
    if (manifest == null) return false;

    final language = useMalayalamNuance ? 'ml' : 'en';
    final models = _manifestModelsForLanguage(manifest, language);
    if (models.isEmpty) return false;

    final sorted = [...models]
      ..sort((a, b) {
        final tierA = a['tier']?.toString() ?? '';
        final tierB = b['tier']?.toString() ?? '';
        if (tierA == tierB) return 0;
        if (tierA == 'primary') return -1;
        if (tierB == 'primary') return 1;
        return tierA.compareTo(tierB);
      });

    final escapedText = _shellSingleQuoteEscape(text);
    final shell = Shell();

    for (final model in sorted) {
      final modelPath = model['modelPath']?.toString();
      final tokensPath = model['tokensPath']?.toString();
      if (modelPath == null || tokensPath == null) continue;

      final attempts = <String>[
        "sherpa-onnx-offline-tts-play --vits-model '$modelPath' --vits-tokens '$tokensPath' --sid 0 --text '$escapedText'",
        "sherpa-onnx-offline-tts-play --model '$modelPath' --tokens '$tokensPath' --sid 0 --text '$escapedText'",
        "sherpa-onnx-tts-play --vits-model '$modelPath' --vits-tokens '$tokensPath' --sid 0 --text '$escapedText'",
      ];

      for (final cmd in attempts) {
        try {
          await shell.run(cmd);
          return true;
        } catch (_) {
          // Try next command/model.
        }
      }
    }

    return false;
  }

  bool isMalayalamLocale(String? locale) {
    return locale?.toLowerCase().startsWith('ml') ?? false;
  }

  bool isEnglishLocale(String? locale) {
    return locale?.toLowerCase().startsWith('en') ?? false;
  }

  String normalizeVoiceLanguageMode(String mode) {
    final normalized = mode.trim().toLowerCase();
    switch (normalized) {
      case 'malayalam':
      case 'english':
      case 'auto':
        return normalized;
      case 'all':
      case 'pleasant':
        return 'english';
      default:
        return 'auto';
    }
  }

  List<Map<dynamic, dynamic>> parseSupportedVoices(dynamic voices) {
    if (voices == null) return [];

    return List<Map<dynamic, dynamic>>.from(voices).where((voice) {
      final locale = voice['locale']?.toString().toLowerCase() ?? '';
      return locale.startsWith('en') || locale.startsWith('ml');
    }).toList();
  }

  int _voiceScore(Map<dynamic, dynamic> voice) {
    final name = voice['name']?.toString().toLowerCase() ?? '';
    final locale = voice['locale']?.toString().toLowerCase() ?? '';
    int score = 0;

    if (locale == 'ml-in') score += 48;
    if (locale == 'en-in') score += 42;
    if (locale == 'en-us') score += 36;
    if (locale == 'en-gb') score += 34;

    if (name.contains('neural') ||
        name.contains('network') ||
        name.contains('wavenet')) {
      score += 32;
    }

    if (name.contains('veena')) score += 34;
    if (name.contains('rishi')) score += 30;
    if (name.contains('female')) score += 10;
    if (name.contains('male')) score += 8;
    if (name.contains('google') || name.contains('samsung')) score += 10;

    return score;
  }

  List<Map<dynamic, dynamic>> _sortByQuality(
    List<Map<dynamic, dynamic>> list,
  ) {
    final ranked = List<Map<dynamic, dynamic>>.from(list);
    ranked.sort((a, b) {
      final scoreCompare = _voiceScore(b).compareTo(_voiceScore(a));
      if (scoreCompare != 0) return scoreCompare;

      final localeA = a['locale']?.toString() ?? '';
      final localeB = b['locale']?.toString() ?? '';
      final localeCompare = localeA.compareTo(localeB);
      if (localeCompare != 0) return localeCompare;

      final nameA = a['name']?.toString() ?? '';
      final nameB = b['name']?.toString() ?? '';
      return nameA.compareTo(nameB);
    });
    return ranked;
  }

  List<Map<dynamic, dynamic>> availableVoicesForSettings({
    required List<Map<dynamic, dynamic>> voices,
    required String voiceListMode,
  }) {
    final mode = normalizeVoiceLanguageMode(voiceListMode);
    final english = voices
        .where((voice) => isEnglishLocale(voice['locale']?.toString()))
        .toList();
    final malayalam = voices
        .where((voice) => isMalayalamLocale(voice['locale']?.toString()))
        .toList();

    if (mode == 'english') {
      return _sortByQuality(english.isNotEmpty ? english : voices);
    }
    if (mode == 'malayalam') {
      return _sortByQuality(malayalam.isNotEmpty ? malayalam : voices);
    }

    final mixed = [..._sortByQuality(malayalam), ..._sortByQuality(english)];
    if (mixed.isNotEmpty) return mixed;
    return _sortByQuality(voices);
  }

  Map<dynamic, dynamic>? preferredVoice({
    required List<Map<dynamic, dynamic>> voices,
    required String voiceListMode,
    required String? favoriteVoiceName,
    required String? favoriteVoiceLocale,
  }) {
    if (voices.isEmpty) return null;

    final available = availableVoicesForSettings(
      voices: voices,
      voiceListMode: voiceListMode,
    );

    if (favoriteVoiceName != null && favoriteVoiceLocale != null) {
      try {
        return available.firstWhere(
          (voice) =>
              voice['name']?.toString() == favoriteVoiceName &&
              voice['locale']?.toString() == favoriteVoiceLocale,
        );
      } catch (_) {}
    }

    final ranked = _sortByQuality(available);
    return ranked.isNotEmpty ? ranked.first : voices.first;
  }

  Future<void> speakItem({
    required FlutterTts flutterTts,
    required SpeechItem item,
    required double speakVolume,
    required Map<dynamic, dynamic>? preferredVoice,
    required bool useMalayalamNuance,
    required String speechEngineMode,
  }) async {
    final mode = normalizeSpeechEngineMode(speechEngineMode);

    if (Platform.isLinux || Platform.isWindows) {
      if (mode == 'sherpa_only' || mode == 'auto') {
        final sherpaOk = await _speakWithSherpaDesktop(
          text: item.text,
          useMalayalamNuance: useMalayalamNuance,
        );
        if (sherpaOk) return;
      }
    }

    if (mode == 'sherpa_only') {
      // Strict mode requested Sherpa but it was unavailable.
      return;
    }

    if (Platform.isLinux) {
      final fallbackOk = await _speakOnLinuxFallback(
        text: item.text,
        useMalayalamNuance: useMalayalamNuance,
      );
      if (fallbackOk) return;
    }

    if (preferredVoice != null) {
      await flutterTts.setVoice({
        'name': preferredVoice['name'],
        'locale': preferredVoice['locale'],
      });
    }

    if (useMalayalamNuance) {
      await flutterTts.setLanguage('ml-IN');
    } else {
      await flutterTts.setLanguage('en-IN');
    }

    if (useMalayalamNuance) {
      await flutterTts.setPitch(0.98);
      await flutterTts.setSpeechRate(item.isQuote ? 0.40 : 0.44);
    } else {
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(item.isQuote ? 0.45 : 0.5);
    }

    await flutterTts.setVolume(speakVolume);
    await flutterTts.speak(item.text);
  }
}
