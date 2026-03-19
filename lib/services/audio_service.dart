import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _notifyPlayer = AudioPlayer();

  Future<void> init() async {
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> applyBackground({
    required bool shouldPlay,
    required String assetPath,
    required double volume,
  }) async {
    if (!shouldPlay) return;

    await _bgPlayer.play(AssetSource(assetPath));
    await _bgPlayer.setVolume(volume);
  }

  Future<void> stopBackground() async {
    await _bgPlayer.pause();
  }

  Future<void> playNotification({
    required String assetPath,
    Duration stopAfter = const Duration(seconds: 10),
  }) async {
    await _notifyPlayer.play(AssetSource(assetPath));

    unawaited(
      Future.delayed(stopAfter, () async {
        await _notifyPlayer.pause();
        await _notifyPlayer.seek(Duration.zero);
      }),
    );
  }

  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _notifyPlayer.dispose();
  }
}