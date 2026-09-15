import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _notificationPlayer = AudioPlayer();

  Future<void> _operationTail = Future<void>.value();
  Timer? _notificationStopTimer;
  int _backgroundRevision = 0;
  int _notificationRevision = 0;
  String? _activeAsset;
  double? _activeVolume;
  bool _backgroundPlaying = false;
  bool _disposed = false;

  Future<void> init() => _enqueue(() async {
    await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
  });

  Future<void> applyBackground({
    required bool shouldPlay,
    required String assetPath,
    required double volume,
  }) {
    final revision = ++_backgroundRevision;
    final safeVolume = volume.clamp(0, 1).toDouble();
    return _enqueue(() async {
      if (_disposed || revision != _backgroundRevision) return;
      if (!shouldPlay) {
        await _backgroundPlayer.pause();
        _backgroundPlaying = false;
        return;
      }
      if (_activeVolume != safeVolume) {
        await _backgroundPlayer.setVolume(safeVolume);
        _activeVolume = safeVolume;
      }
      if (!_backgroundPlaying || _activeAsset != assetPath) {
        await _backgroundPlayer.play(AssetSource(assetPath));
        _activeAsset = assetPath;
        _backgroundPlaying = true;
      }
    });
  }

  Future<void> stopBackground() {
    final revision = ++_backgroundRevision;
    return _enqueue(() async {
      if (_disposed || revision != _backgroundRevision) return;
      await _backgroundPlayer.pause();
      _backgroundPlaying = false;
    });
  }

  Future<void> playNotification({
    required String assetPath,
    Duration stopAfter = const Duration(seconds: 10),
  }) {
    final revision = ++_notificationRevision;
    _notificationStopTimer?.cancel();
    return _enqueue(() async {
      if (_disposed || revision != _notificationRevision) return;
      await _notificationPlayer.play(AssetSource(assetPath));
      _notificationStopTimer = Timer(stopAfter, () {
        if (revision == _notificationRevision) {
          unawaited(_stopNotification(revision));
        }
      });
    });
  }

  Future<void> stopNotification() {
    final revision = ++_notificationRevision;
    _notificationStopTimer?.cancel();
    return _stopNotification(revision);
  }

  Future<void> _stopNotification(int revision) => _enqueue(() async {
    if (_disposed || revision != _notificationRevision) return;
    await _notificationPlayer.pause();
    await _notificationPlayer.seek(Duration.zero);
  });

  Future<void> _enqueue(Future<void> Function() operation) {
    _operationTail = _operationTail
        .catchError((Object _) {})
        .then((_) => operation());
    return _operationTail;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _notificationStopTimer?.cancel();
    await _operationTail.catchError((Object _) {});
    await _backgroundPlayer.dispose();
    await _notificationPlayer.dispose();
  }
}
