import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/speech_item.dart';

class SpeechService {
  static const MethodChannel _audioChannel = MethodChannel(
    'com.atherpulse.solasflow/audio',
  );

  Map<String, dynamic>? _sherpaManifestCache;
  String _lastEngineUsed = 'system';
  String _lastEngineDetail = 'System TTS ready';
  bool _linuxRuntimeBootstrapAttempted = false;

  static const String _sherpaReleaseTag = 'v1.12.34';
  static const String _sherpaModelsReleaseTag = 'tts-models';
  static const String _kokoroArchiveName =
      'kokoro-int8-multi-lang-v1_1.tar.bz2';
  static const String _kokoroArchiveSha256 =
      'a1e94694776049035c4f2c6529f003aaece993c76aae9a78995831c3c4dcafc6';
  static const int _kokoroArchiveSize = 147031220;

  AudioPlayer? _desktopTtsPlayer;
  int _desktopSpeechGeneration = 0;
  Completer<void>? _desktopPlaybackCompleter;

  String get lastEngineUsed => _lastEngineUsed;
  String get lastEngineDetail => _lastEngineDetail;

  void _setEngineStatus(String used, String detail) {
    _lastEngineUsed = used;
    _lastEngineDetail = detail;
  }

  String normalizeSpeechEngineMode(String mode) {
    final trimmed = mode.trim();
    final normalized = trimmed.toLowerCase();
    switch (normalized) {
      case 'auto':
      case 'system_only':
      case 'sherpa_only':
        return normalized;
      default:
        return trimmed.contains('.') ? trimmed : 'auto';
    }
  }

  String _linuxEspeakVoice({required bool useMalayalamNuance}) {
    return useMalayalamNuance ? 'ml' : 'en';
  }

  Future<void> _setMediaVolumeToMax() async {
    try {
      await _audioChannel.invokeMethod<void>('setMediaVolumeToMax');
    } on PlatformException catch (error) {
      debugPrint('Unable to maximize media volume: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Audio channel unavailable: $error');
    }
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
    return value
        .replaceAll('\\\\', Platform.pathSeparator)
        .replaceAll('/', Platform.pathSeparator);
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

    if (Platform.isLinux) {
      bases.add(_linuxRuntimeBaseDir());
    }

    final execParent = File(Platform.resolvedExecutable).parent;
    if (execParent.parent.path != execParent.path) {
      bases.add(execParent.parent.path);
    }
    return bases.toList();
  }

  String _linuxRuntimeBaseDir() {
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      return '${Directory.systemTemp.path}${Platform.pathSeparator}solasflow_runtime';
    }
    return '$home${Platform.pathSeparator}.local${Platform.pathSeparator}share${Platform.pathSeparator}solasflow_runtime';
  }

  bool _fileExists(String path) => File(path).existsSync();

  bool _dirExists(String path) => Directory(path).existsSync();

  Future<File> _downloadToFile({
    required String url,
    required String outPath,
    int? expectedSize,
    String? expectedSha256,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    final outFile = File(outPath);
    final partialFile = File('$outPath.part');
    try {
      final req = await client.getUrl(Uri.parse(url));
      final res = await req.close().timeout(const Duration(seconds: 30));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Download failed ($url): ${res.statusCode}');
      }
      await outFile.parent.create(recursive: true);
      final sink = partialFile.openWrite();
      try {
        await sink.addStream(res.timeout(const Duration(seconds: 45)));
      } finally {
        await sink.close();
      }

      final actualSize = await partialFile.length();
      if (expectedSize != null && actualSize != expectedSize) {
        throw Exception('Download size mismatch: $actualSize bytes');
      }
      if (expectedSha256 != null) {
        final actualSha256 = await _sha256OfFile(partialFile);
        if (actualSha256 != expectedSha256) {
          throw Exception('Download SHA-256 mismatch');
        }
      }
      if (await outFile.exists()) await outFile.delete();
      return await partialFile.rename(outPath);
    } catch (_) {
      if (await partialFile.exists()) await partialFile.delete();
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  Future<String> _sha256OfFile(File file) async {
    final result = await Process.run('sha256sum', [file.path]);
    if (result.exitCode != 0) {
      throw Exception('Unable to verify model archive SHA-256');
    }
    return result.stdout.toString().trim().split(RegExp(r'\s+')).first;
  }

  Future<void> _copyDir(String src, String dst) async {
    final srcDir = Directory(src);
    if (!srcDir.existsSync()) return;
    final dstDir = Directory(dst);
    await dstDir.create(recursive: true);
    await for (final entity in srcDir.list(
      recursive: true,
      followLinks: false,
    )) {
      final rel = entity.path.substring(srcDir.path.length + 1);
      final targetPath = '$dst${Platform.pathSeparator}$rel';
      if (entity is Directory) {
        await Directory(targetPath).create(recursive: true);
      } else if (entity is File) {
        await File(targetPath).parent.create(recursive: true);
        await entity.copy(targetPath);
      }
    }
  }

  Future<void> _extractTarBz2(String archivePath, String outputDir) async {
    final result = await Process.run('tar', [
      '-xjf',
      archivePath,
      '-C',
      outputDir,
    ]);
    if (result.exitCode != 0) {
      throw Exception('tar extract failed: ${result.stderr}');
    }
  }

  Future<void> _ensureLinuxRuntimeAssets() async {
    if (!Platform.isLinux || _linuxRuntimeBootstrapAttempted) return;
    _linuxRuntimeBootstrapAttempted = true;

    final runtimeBase = _linuxRuntimeBaseDir();
    final binBase =
        '$runtimeBase${Platform.pathSeparator}assets${Platform.pathSeparator}tts${Platform.pathSeparator}bin${Platform.pathSeparator}linux-x64';
    final modelsBase =
        '$runtimeBase${Platform.pathSeparator}assets${Platform.pathSeparator}tts${Platform.pathSeparator}models';

    final mustHave = <String>[
      '$binBase${Platform.pathSeparator}sherpa-onnx-offline-tts-play',
      '$modelsBase${Platform.pathSeparator}en${Platform.pathSeparator}primary${Platform.pathSeparator}model.onnx',
      '$modelsBase${Platform.pathSeparator}en${Platform.pathSeparator}primary${Platform.pathSeparator}tokens.txt',
      '$modelsBase${Platform.pathSeparator}ml${Platform.pathSeparator}primary${Platform.pathSeparator}model.onnx',
      '$modelsBase${Platform.pathSeparator}ml${Platform.pathSeparator}primary${Platform.pathSeparator}tokens.txt',
      '$modelsBase${Platform.pathSeparator}espeak-ng-data${Platform.pathSeparator}ml_dict',
    ];
    final alreadyReady = mustHave.every(_fileExists);
    final bundledPaths = <String>[
      'assets/tts/bin/linux-x64/sherpa-onnx-offline-tts-play',
      'assets/tts/models/en/primary/model.onnx',
      'assets/tts/models/en/primary/tokens.txt',
      'assets/tts/models/ml/primary/model.onnx',
      'assets/tts/models/ml/primary/tokens.txt',
      'assets/tts/models/espeak-ng-data/ml_dict',
    ];
    if (bundledPaths.every((path) => _resolveDesktopPath(path) != null) ||
        alreadyReady) {
      await _ensureLinuxKokoroModel();
      return;
    }

    final tmpRoot =
        '${Directory.systemTemp.path}${Platform.pathSeparator}solasflow_sherpa_bootstrap';
    await Directory(tmpRoot).create(recursive: true);

    Future<String> downloadArchive(
      String name, {
      String releaseTag = _sherpaReleaseTag,
    }) async {
      final out = '$tmpRoot${Platform.pathSeparator}$name';
      if (_fileExists(out)) return out;
      final url =
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/$releaseTag/$name';
      await _downloadToFile(url: url, outPath: out);
      return out;
    }

    Future<void> installModel({
      required String archiveName,
      required String onnxName,
      required String language,
      required String tier,
    }) async {
      final arc = await downloadArchive(
        archiveName,
        releaseTag: _sherpaModelsReleaseTag,
      );
      final extractDir = '$tmpRoot${Platform.pathSeparator}${language}_$tier';
      final extractPath = Directory(extractDir);
      if (extractPath.existsSync()) {
        await extractPath.delete(recursive: true);
      }
      await extractPath.create(recursive: true);
      await _extractTarBz2(arc, extractDir);

      final topDirs = Directory(
        extractDir,
      ).listSync().whereType<Directory>().toList();
      if (topDirs.isEmpty) {
        throw Exception('No model directory in $archiveName');
      }
      final src = topDirs.first.path;
      final dstDir =
          '$modelsBase${Platform.pathSeparator}$language${Platform.pathSeparator}$tier';
      await Directory(dstDir).create(recursive: true);
      await File(
        '$src${Platform.pathSeparator}$onnxName',
      ).copy('$dstDir${Platform.pathSeparator}model.onnx');
      await File(
        '$src${Platform.pathSeparator}tokens.txt',
      ).copy('$dstDir${Platform.pathSeparator}tokens.txt');

      final sharedDataDir =
          '$modelsBase${Platform.pathSeparator}espeak-ng-data';
      if (!_dirExists(sharedDataDir)) {
        await _copyDir(
          '$src${Platform.pathSeparator}espeak-ng-data',
          sharedDataDir,
        );
      }
    }

    try {
      final binArchive = await downloadArchive(
        'sherpa-onnx-$_sherpaReleaseTag-linux-x64-static.tar.bz2',
      );
      final binExtract = '$tmpRoot${Platform.pathSeparator}bin_extract';
      final binExtractDir = Directory(binExtract);
      if (binExtractDir.existsSync()) {
        await binExtractDir.delete(recursive: true);
      }
      await binExtractDir.create(recursive: true);
      await _extractTarBz2(binArchive, binExtract);

      final extractedRoot = binExtractDir
          .listSync()
          .whereType<Directory>()
          .firstWhere((d) => d.path.contains('linux-x64-static'));
      final sourceBin = '${extractedRoot.path}${Platform.pathSeparator}bin';
      await Directory(binBase).create(recursive: true);
      for (final exe in [
        'sherpa-onnx-offline-tts-play',
        'sherpa-onnx-offline-tts-play-alsa',
        'sherpa-onnx-offline-tts',
      ]) {
        final src = '$sourceBin${Platform.pathSeparator}$exe';
        final dst = '$binBase${Platform.pathSeparator}$exe';
        await File(src).copy(dst);
        await _ensureExecutableBitIfNeeded(dst);
      }

      await installModel(
        archiveName: 'vits-piper-en_US-lessac-medium.tar.bz2',
        onnxName: 'en_US-lessac-medium.onnx',
        language: 'en',
        tier: 'primary',
      );
      await installModel(
        archiveName: 'vits-piper-en_US-ljspeech-medium.tar.bz2',
        onnxName: 'en_US-ljspeech-medium.onnx',
        language: 'en',
        tier: 'backup',
      );
      await installModel(
        archiveName: 'vits-piper-ml_IN-meera-medium.tar.bz2',
        onnxName: 'ml_IN-meera-medium.onnx',
        language: 'ml',
        tier: 'primary',
      );
      await installModel(
        archiveName: 'vits-piper-ml_IN-arjun-medium.tar.bz2',
        onnxName: 'ml_IN-arjun-medium.onnx',
        language: 'ml',
        tier: 'backup',
      );
      _setEngineStatus(
        'sherpa_ready',
        'Downloaded Linux Sherpa runtime and fallback voices',
      );
    } catch (error) {
      _setEngineStatus(
        'sherpa_download_failed',
        'Runtime setup failed: $error',
      );
    }

    await _ensureLinuxKokoroModel();
  }

  Future<void> _ensureLinuxKokoroModel() async {
    final runtimeBase = _linuxRuntimeBaseDir();
    final kokoroDir = _joinPath(
      _joinPath(_joinPath(runtimeBase, 'assets/tts/models'), 'en'),
      'kokoro',
    );
    final installedFiles = [
      'model.int8.onnx',
      'tokens.txt',
      'voices.bin',
      'lexicon-us-en.txt',
    ];
    if (installedFiles.every(
      (name) => _fileExists(_joinPath(kokoroDir, name)),
    )) {
      return;
    }

    final tmpRoot =
        '${Directory.systemTemp.path}${Platform.pathSeparator}solasflow_sherpa_bootstrap';
    final archivePath = _joinPath(tmpRoot, _kokoroArchiveName);
    final archiveFile = File(archivePath);
    var archiveValid = false;
    try {
      if (archiveFile.existsSync()) {
        archiveValid =
            await archiveFile.length() == _kokoroArchiveSize &&
            await _sha256OfFile(archiveFile) == _kokoroArchiveSha256;
      }
      if (!archiveValid) {
        if (archiveFile.existsSync()) await archiveFile.delete();
        _setEngineStatus(
          'kokoro_downloading',
          'Downloading Kokoro English voice (140 MB, first run only)',
        );
        await _downloadToFile(
          url:
              'https://github.com/k2-fsa/sherpa-onnx/releases/download/$_sherpaModelsReleaseTag/$_kokoroArchiveName',
          outPath: archivePath,
          expectedSize: _kokoroArchiveSize,
          expectedSha256: _kokoroArchiveSha256,
        );
      }

      final extractDir = _joinPath(tmpRoot, 'kokoro_extract');
      final extractPath = Directory(extractDir);
      if (extractPath.existsSync()) {
        await extractPath.delete(recursive: true);
      }
      await extractPath.create(recursive: true);
      await _extractTarBz2(archivePath, extractDir);

      final sourceDir = _joinPath(extractDir, 'kokoro-int8-multi-lang-v1_1');
      if (!installedFiles.every(
        (name) => _fileExists(_joinPath(sourceDir, name)),
      )) {
        throw Exception('Kokoro archive is missing required model files');
      }

      final stagingDir = Directory('$kokoroDir.installing');
      if (stagingDir.existsSync()) {
        await stagingDir.delete(recursive: true);
      }
      await stagingDir.create(recursive: true);
      for (final name in installedFiles) {
        await File(
          _joinPath(sourceDir, name),
        ).copy(_joinPath(stagingDir.path, name));
      }

      final installedDir = Directory(kokoroDir);
      if (installedDir.existsSync()) {
        await installedDir.delete(recursive: true);
      }
      await stagingDir.rename(kokoroDir);
      await extractPath.delete(recursive: true);
      await archiveFile.delete();
      _setEngineStatus(
        'kokoro_ready',
        'Kokoro v1.1 INT8 ready (US English, Maple)',
      );
    } catch (error) {
      _setEngineStatus(
        'kokoro_unavailable',
        'Kokoro unavailable; using the bundled fallback voice: $error',
      );
    }
  }

  String? _resolveDesktopPath(String pathLike) {
    if (pathLike.trim().isEmpty) return null;
    final normalized = _normalizeSep(pathLike.trim());

    if (_looksAbsolutePath(normalized)) {
      return File(normalized).existsSync() ? normalized : null;
    }

    final candidates = <String>{};
    if (Platform.isLinux &&
        normalized.startsWith(
          'assets${Platform.pathSeparator}tts${Platform.pathSeparator}',
        )) {
      candidates.add(_joinPath(_linuxRuntimeBaseDir(), normalized));
    }
    for (final base in _desktopBaseDirs()) {
      candidates.add(_joinPath(base, normalized));
      candidates.add(
        _joinPath(base, 'assets${Platform.pathSeparator}$normalized'),
      );
      candidates.add(
        _joinPath(base, 'flutter_assets${Platform.pathSeparator}$normalized'),
      );
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

  Future<bool> _runExternal(String executable, List<String> args) async {
    try {
      final result = await Process.run(executable, args);
      if (result.exitCode != 0) {
        final stderr = result.stderr.toString().trim();
        if (stderr.isNotEmpty) {
          debugPrint('Speech command failed ($executable): $stderr');
        }
      }
      return result.exitCode == 0;
    } catch (error) {
      debugPrint('Unable to run speech command ($executable): $error');
      return false;
    }
  }

  Future<bool> _playWaveFile(
    String path, {
    required double volume,
    required int generation,
  }) async {
    if (generation != _desktopSpeechGeneration) return true;
    final player = _desktopTtsPlayer ??= AudioPlayer();
    final completed = Completer<void>();
    _desktopPlaybackCompleter = completed;
    final subscription = player.onPlayerComplete.listen((_) {
      if (!completed.isCompleted) completed.complete();
    });
    try {
      await player.stop();
      await player.play(
        DeviceFileSource(path),
        volume: volume.clamp(0.0, 1.0).toDouble(),
      );
      if (generation != _desktopSpeechGeneration) {
        await player.stop();
        if (!completed.isCompleted) completed.complete();
      }
      await completed.future.timeout(const Duration(minutes: 2));
      return generation == _desktopSpeechGeneration;
    } catch (error) {
      debugPrint('Unable to play synthesized speech: $error');
      return false;
    } finally {
      await subscription.cancel();
      if (identical(_desktopPlaybackCompleter, completed)) {
        _desktopPlaybackCompleter = null;
      }
    }
  }

  Future<void> stopDesktopSpeech() async {
    _desktopSpeechGeneration++;
    final completed = _desktopPlaybackCompleter;
    if (completed != null && !completed.isCompleted) completed.complete();
    try {
      await _desktopTtsPlayer?.stop();
    } catch (error) {
      debugPrint('Unable to stop desktop speech: $error');
    }
  }

  Future<void> disposeDesktopSpeech() async {
    await stopDesktopSpeech();
    final player = _desktopTtsPlayer;
    _desktopTtsPlayer = null;
    if (player != null) await player.dispose();
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
      final raw = await rootBundle.loadString(
        'assets/tts/models_manifest.json',
      );
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
        .where(
          (m) => (m['language']?.toString().toLowerCase() ?? '') == language,
        )
        .where((m) {
          final platforms = m['platforms'];
          return platforms is! List ||
              platforms
                  .map((value) => value.toString())
                  .contains(_platformKey());
        })
        .toList();
  }

  List<String> _manifestSherpaCommands(Map<String, dynamic> manifest) {
    final key = _platformKey();
    final commands = manifest['commands'];
    if (commands is! Map) return const [];

    final platformEntry = commands[key];
    if (platformEntry is! List) return const [];

    return platformEntry
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
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
      names.addAll(['sherpa-onnx-offline-tts-play', 'sherpa-onnx-tts-play']);
    }

    final ordered = <String>[];
    final seen = <String>{};
    for (final candidate in names) {
      if (seen.add(candidate)) ordered.add(candidate);
    }

    final resolved = <String>[];
    for (final candidate in ordered) {
      final hasSeparator =
          candidate.contains('/') || candidate.contains('\\\\');
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
    required double volume,
  }) async {
    if (!(Platform.isLinux || Platform.isWindows)) return false;

    final generation = _desktopSpeechGeneration;
    if (Platform.isLinux) {
      await _ensureLinuxRuntimeAssets();
    }
    if (generation != _desktopSpeechGeneration) return true;

    final manifest = await _loadSherpaManifest();
    if (manifest == null) return false;

    final language = useMalayalamNuance ? 'ml' : 'en';
    final models = _manifestModelsForLanguage(manifest, language);
    if (models.isEmpty) return false;

    final sorted = [...models]
      ..sort((a, b) {
        final tierRank = {'primary': 0, 'secondary': 1, 'backup': 2};
        final rankA = tierRank[a['tier']?.toString()] ?? 3;
        final rankB = tierRank[b['tier']?.toString()] ?? 3;
        return rankA.compareTo(rankB);
      });

    for (final model in sorted) {
      final modelPathRaw = model['modelPath']?.toString();
      final tokensPathRaw = model['tokensPath']?.toString();
      if (modelPathRaw == null || tokensPathRaw == null) continue;

      final modelPath = _resolveDesktopPath(modelPathRaw);
      final tokensPath = _resolveDesktopPath(tokensPathRaw);
      if (modelPath == null || tokensPath == null) continue;

      final modelType = model['modelType']?.toString() ?? 'vits';
      final voicesPath = modelType == 'kokoro'
          ? _resolveDesktopPath(model['voicesPath']?.toString() ?? '')
          : null;
      final dataDir = _resolveDesktopPath(model['dataDir']?.toString() ?? '');
      final lexiconPath = _resolveDesktopPath(
        model['lexiconPath']?.toString() ?? '',
      );
      final ruleFstsPath = _resolveDesktopPath(
        model['ruleFstsPath']?.toString() ?? '',
      );
      if (modelType == 'kokoro' &&
          (voicesPath == null || dataDir == null || lexiconPath == null)) {
        continue;
      }

      final commands = await _commandCandidatesForModel(manifest, model);
      List<String> baseModelArgs() {
        if (modelType == 'kokoro') {
          return [
            '--kokoro-model=$modelPath',
            '--kokoro-voices=$voicesPath',
            '--kokoro-tokens=$tokensPath',
            '--kokoro-data-dir=$dataDir',
            '--kokoro-lexicon=$lexiconPath',
            '--sid=${model['speakerId'] ?? 0}',
          ];
        }
        final args = <String>[
          '--vits-model=$modelPath',
          '--vits-tokens=$tokensPath',
          '--sid=0',
        ];
        if (dataDir != null) args.add('--vits-data-dir=$dataDir');
        if (lexiconPath != null) args.add('--vits-lexicon=$lexiconPath');
        if (ruleFstsPath != null) args.add('--tts-rule-fsts=$ruleFstsPath');
        return args;
      }

      for (final command in commands) {
        final lowerCommand = command.toLowerCase();
        final isFileGenerator =
            lowerCommand.endsWith('offline-tts') ||
            lowerCommand.endsWith('offline-tts.exe');
        if (Platform.isLinux && !isFileGenerator) continue;

        if (isFileGenerator) {
          final outFile =
              '${Directory.systemTemp.path}${Platform.pathSeparator}sherpa_tts_${DateTime.now().microsecondsSinceEpoch}.wav';
          final generated = await _runExternal(command, [
            ...baseModelArgs(),
            '--output-filename=$outFile',
            text,
          ]);
          if (generated && await File(outFile).exists()) {
            if (generation != _desktopSpeechGeneration) {
              await File(outFile).delete();
              return true;
            }
            final played = await _playWaveFile(
              outFile,
              volume: volume,
              generation: generation,
            );
            try {
              await File(outFile).delete();
            } catch (_) {}
            if (played && generation == _desktopSpeechGeneration) {
              _setEngineStatus(
                'sherpa',
                model['description']?.toString() ??
                    'Sherpa ${model['id'] ?? language}',
              );
              return true;
            }
            if (generation != _desktopSpeechGeneration) return true;
          }
          if (Platform.isLinux) continue;
        }

        final ok = await _runExternal(command, [...baseModelArgs(), text]);
        if (ok) {
          _setEngineStatus(
            'sherpa',
            model['description']?.toString() ??
                'Sherpa ${model['id'] ?? language}',
          );
          return true;
        }
      }

      final extraArgs = model['commandArgs'];
      if (extraArgs is List && extraArgs.isNotEmpty && !Platform.isLinux) {
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

    _setEngineStatus('sherpa_unavailable', 'No compatible Sherpa model found');
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
        return 'malayalam';
      case 'english':
        return 'english';
      case 'auto':
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

  List<Map<dynamic, dynamic>> _sortByQuality(List<Map<dynamic, dynamic>> list) {
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
      if (malayalam.isNotEmpty) return _sortByQuality(malayalam);
      return [
        {'name': 'Standard Malayalam', 'locale': 'ml-IN'},
      ];
    }

    final effectiveMalayalam = malayalam.isNotEmpty
        ? malayalam
        : [
            {'name': 'Standard Malayalam', 'locale': 'ml-IN'},
          ];
    final mixed = [
      ..._sortByQuality(effectiveMalayalam),
      ..._sortByQuality(english),
    ];
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
    if (ranked.isNotEmpty) return ranked.first;
    if (normalizeVoiceLanguageMode(voiceListMode) == 'malayalam') {
      return {'name': 'Standard Malayalam', 'locale': 'ml-IN'};
    }
    return voices.isNotEmpty ? voices.first : null;
  }

  Future<void> speakItem({
    required FlutterTts flutterTts,
    required SpeechItem item,
    required double speakVolume,
    required bool maximumSpeechVolume,
    required Map<dynamic, dynamic>? preferredVoice,
    required bool useMalayalamNuance,
    required String speechEngineMode,
  }) async {
    final mode = normalizeSpeechEngineMode(speechEngineMode);
    final ttsVolume = maximumSpeechVolume
        ? (speakVolume + 0.40).clamp(0.0, 1.0).toDouble()
        : speakVolume.clamp(0.0, 1.0).toDouble();

    if (Platform.isLinux || Platform.isWindows) {
      if (mode == 'sherpa_only' || mode == 'auto') {
        final sherpaOk = await _speakWithSherpaDesktop(
          text: item.text,
          useMalayalamNuance: useMalayalamNuance,
          volume: ttsVolume,
        );
        if (sherpaOk) return;
      }
    }

    if (mode == 'sherpa_only') {
      // Strict mode requested Sherpa but it was unavailable.
      _setEngineStatus(
        'sherpa_only_silent',
        'Sherpa-only selected; no fallback',
      );
      return;
    }

    if (Platform.isLinux) {
      final fallbackOk = await _speakOnLinuxFallback(
        text: item.text,
        useMalayalamNuance: useMalayalamNuance,
      );
      if (fallbackOk) return;
    }
    if (Platform.isLinux) {
      _setEngineStatus('failed', 'No Linux speech backend is available');
      return;
    }

    final isFavMalayalam =
        preferredVoice != null &&
        isMalayalamLocale(preferredVoice['locale']?.toString());
    final isFavEnglish =
        preferredVoice != null &&
        isEnglishLocale(preferredVoice['locale']?.toString());

    if (useMalayalamNuance) {
      if (isFavMalayalam) {
        await flutterTts.setVoice({
          'name': preferredVoice['name'],
          'locale': preferredVoice['locale'],
        });
      }
      await flutterTts.setLanguage('ml-IN');
    } else {
      if (isFavEnglish) {
        await flutterTts.setVoice({
          'name': preferredVoice['name'],
          'locale': preferredVoice['locale'],
        });
      }
      await flutterTts.setLanguage('en-IN');
    }

    if (useMalayalamNuance) {
      await flutterTts.setPitch(0.98);
      await flutterTts.setSpeechRate(item.isQuote ? 0.40 : 0.44);
    } else {
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(item.isQuote ? 0.45 : 0.5);
    }

    await flutterTts.setVolume(ttsVolume);

    if (maximumSpeechVolume && Platform.isAndroid) {
      await _setMediaVolumeToMax();
    }

    await flutterTts.speak(item.text);

    _setEngineStatus(
      'system',
      'System TTS (${useMalayalamNuance ? 'ml-IN' : 'en-IN'})',
    );
  }

  Future<List<String>> getInstalledEngines(FlutterTts flutterTts) async {
    if (!Platform.isAndroid) return [];
    try {
      final dynamic engines = await flutterTts.getEngines;
      if (engines is List) {
        return engines.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> setSpeechEngine({
    required FlutterTts flutterTts,
    required String engine,
  }) async {
    if (!Platform.isAndroid) return false;
    try {
      await flutterTts.setEngine(engine);
      _setEngineStatus('engine_changed', 'Engine set to $engine');
      return true;
    } catch (e) {
      _setEngineStatus('engine_error', 'Failed setting engine $engine: $e');
      return false;
    }
  }
}
