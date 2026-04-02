import 'dart:io';
import 'dart:convert';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

import '../models/speech_item.dart';

class SpeechService {
  Map<String, dynamic>? _sherpaManifestCache;
  String _lastEngineUsed = 'system';
  String _lastEngineDetail = 'System TTS ready';

  String get lastEngineUsed => _lastEngineUsed;
  String get lastEngineDetail => _lastEngineDetail;

  void _setEngineStatus(String used, String detail) {
    _lastEngineUsed = used;
    _lastEngineDetail = detail;
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

  String _platformKey() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    if (Platform.isMacOS) return 'macos';
    return 'unknown';
  }

  bool _looksAbsolutePath(String value) {
    if (value.startsWith('/')) return true;
    return RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value);
  }

  String _normalizeSep(String value) {
    return value.replaceAll('\\\\', Platform.pathSeparator).replaceAll('/', Platform.pathSeparator);
  }

  String _joinPath(String base, String relative) {
    if (base.endsWith(Platform.pathSeparator)) {
      return '$base${_normalizeSep(relative)}';
    }
    return '$base${Platform.pathSeparator}${_normalizeSep(relative)}';
  }

  List<String> _desktopBaseDirs() {
    final bases = <String>{
      Directory.current.path,
      File(Platform.resolvedExecutable).parent.path,
    };

    final execParent = File(Platform.resolvedExecutable).parent;
    if (execParent.parent.path != execParent.path) {
      bases.add(execParent.parent.path);
    }
    return bases.toList();
  }

  String? _resolveDesktopPath(String pathLike) {
    if (pathLike.trim().isEmpty) return null;
    final normalized = _normalizeSep(pathLike.trim());

    if (_looksAbsolutePath(normalized)) {
      return File(normalized).existsSync() ? normalized : null;
    }

    final candidates = <String>{};
    for (final base in _desktopBaseDirs()) {
      candidates.add(_joinPath(base, normalized));
      candidates.add(_joinPath(base, 'assets${Platform.pathSeparator}$normalized'));
      candidates.add(_joinPath(base, 'flutter_assets${Platform.pathSeparator}$normalized'));
      candidates.add(
        _joinPath(
          base,
          'data${Platform.pathSeparator}flutter_assets${Platform.pathSeparator}$normalized',
        ),
      );
    }

    for (final candidate in candidates) {
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }
    return null;
  }

  Future<void> _ensureExecutableBitIfNeeded(String executablePath) async {
    if (!Platform.isLinux) return;
    try {
      await Process.run('chmod', ['+x', executablePath]);
    } catch (_) {
      // Non-fatal; execution may still work depending on packaging.
    }
  }

  Future<bool> _runExternal(
    String executable,
    List<String> args,
  ) async {
    try {
      final result = await Process.run(executable, args);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _speakOnLinuxFallback({
    required String text,
    required bool useMalayalamNuance,
  }) async {
    final voice = _linuxEspeakVoice(useMalayalamNuance: useMalayalamNuance);

    // Ordered fallback chain for Linux desktop distributions.
    final commands = <({String exe, List<String> args})>[
      (exe: 'espeak-ng', args: ['-v', voice, text]),
      (exe: 'spd-say', args: ['-w', '-l', voice, text]),
      (exe: 'spd-say', args: ['-w', text]),
    ];

    for (final command in commands) {
      final ok = await _runExternal(command.exe, command.args);
      if (ok) {
        _setEngineStatus('linux_fallback', '${command.exe} succeeded');
        return true;
      }
    }

    _setEngineStatus('failed', 'Linux fallback speech engines unavailable');
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

  List<String> _manifestSherpaCommands(Map<String, dynamic> manifest) {
    final key = _platformKey();
    final commands = manifest['commands'];
    if (commands is! Map) return const [];

    final platformEntry = commands[key];
    if (platformEntry is! List) return const [];

    return platformEntry.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<List<String>> _commandCandidatesForModel(
    Map<String, dynamic> manifest,
    Map<String, dynamic> model,
  ) async {
    final names = <String>[];

    final modelCommand = model['command']?.toString();
    if (modelCommand != null && modelCommand.trim().isNotEmpty) {
      names.add(modelCommand.trim());
    }

    names.addAll(_manifestSherpaCommands(manifest));

    if (Platform.isWindows) {
      names.addAll([
        'sherpa-onnx-offline-tts-play.exe',
        'sherpa-onnx-tts-play.exe',
      ]);
    } else {
      names.addAll([
        'sherpa-onnx-offline-tts-play',
        'sherpa-onnx-tts-play',
      ]);
    }

    final ordered = <String>[];
    final seen = <String>{};
    for (final candidate in names) {
      if (seen.add(candidate)) ordered.add(candidate);
    }

    final resolved = <String>[];
    for (final candidate in ordered) {
      final hasSeparator = candidate.contains('/') || candidate.contains('\\\\');
      final resolvedPath = hasSeparator || _looksAbsolutePath(candidate)
          ? _resolveDesktopPath(candidate)
          : null;
      if (resolvedPath != null) {
        await _ensureExecutableBitIfNeeded(resolvedPath);
        resolved.add(resolvedPath);
      } else {
        resolved.add(candidate);
      }
    }
    return resolved;
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

    for (final model in sorted) {
      final modelPathRaw = model['modelPath']?.toString();
      final tokensPathRaw = model['tokensPath']?.toString();
      if (modelPathRaw == null || tokensPathRaw == null) continue;

      final modelPath = _resolveDesktopPath(modelPathRaw);
      final tokensPath = _resolveDesktopPath(tokensPathRaw);
      if (modelPath == null || tokensPath == null) {
        _setEngineStatus(
          'sherpa_unavailable',
          'Missing model files for ${model['id'] ?? language}',
        );
        continue;
      }

      final commands = await _commandCandidatesForModel(manifest, model);
      final attempts = <List<String>>[
        ['--vits-model', modelPath, '--vits-tokens', tokensPath, '--sid', '0', '--text', text],
        ['--model', modelPath, '--tokens', tokensPath, '--sid', '0', '--text', text],
      ];

      for (final command in commands) {
        for (final args in attempts) {
          final ok = await _runExternal(command, args);
          if (ok) {
            _setEngineStatus(
              'sherpa',
              'Sherpa model ${model['id'] ?? language} via $command',
            );
            return true;
          }
        }
      }

      // Last attempt: optional model-specific args from manifest.
      final extraArgs = model['commandArgs'];
      if (extraArgs is List && extraArgs.isNotEmpty) {
        for (final command in commands) {
          final ok = await _runExternal(
            command,
            extraArgs.map((e) => e.toString()).toList(),
          );
          if (ok) {
            _setEngineStatus(
              'sherpa',
              'Sherpa custom args model ${model['id'] ?? language}',
            );
          return true;
          }
        }
      }
    }

    _setEngineStatus('sherpa_unavailable', 'Sherpa command or model not available');
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
      _setEngineStatus('sherpa_only_silent', 'Sherpa-only selected; no fallback');
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
    _setEngineStatus('system', 'System TTS (${useMalayalamNuance ? 'ml-IN' : 'en-IN'})');
  }
}
