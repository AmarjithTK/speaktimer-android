import 'package:flutter/foundation.dart';

enum SpeechModelDownloadPhase {
  notDownloaded,
  downloading,
  verifying,
  installing,
  ready,
  failed,
  cancelled,
}

@immutable
class SpeechModelDownloadStatus {
  const SpeechModelDownloadStatus({
    required this.phase,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.error,
  });

  final SpeechModelDownloadPhase phase;
  final int receivedBytes;
  final int totalBytes;
  final String? error;

  bool get isBusy =>
      phase == SpeechModelDownloadPhase.downloading ||
      phase == SpeechModelDownloadPhase.verifying ||
      phase == SpeechModelDownloadPhase.installing;

  bool get canRetry =>
      phase == SpeechModelDownloadPhase.failed ||
      phase == SpeechModelDownloadPhase.cancelled;

  double? get progress {
    if (phase != SpeechModelDownloadPhase.downloading || totalBytes <= 0) {
      return null;
    }
    return (receivedBytes / totalBytes).clamp(0.0, 1.0).toDouble();
  }

  SpeechModelDownloadStatus copyWith({
    SpeechModelDownloadPhase? phase,
    int? receivedBytes,
    int? totalBytes,
    String? error,
    bool clearError = false,
  }) {
    return SpeechModelDownloadStatus(
      phase: phase ?? this.phase,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      error: clearError ? null : error ?? this.error,
    );
  }

  String get message {
    switch (phase) {
      case SpeechModelDownloadPhase.notDownloaded:
        return 'Not downloaded · 140 MiB. English speech continues with Piper until then.';
      case SpeechModelDownloadPhase.downloading:
        final percent = progress;
        final amount = totalBytes > 0
            ? '${_formatMebibytes(receivedBytes)} / ${_formatMebibytes(totalBytes)}'
            : '${_formatMebibytes(receivedBytes)} downloaded';
        return percent == null
            ? 'Downloading Kokoro English · $amount'
            : 'Downloading Kokoro English · ${(percent * 100).round()}% · $amount';
      case SpeechModelDownloadPhase.verifying:
        return 'Download complete · verifying SHA-256';
      case SpeechModelDownloadPhase.installing:
        return 'Installing the offline English voice';
      case SpeechModelDownloadPhase.ready:
        return 'Ready · Kokoro v1.1 English works offline';
      case SpeechModelDownloadPhase.failed:
        return 'Download failed · ${error ?? 'Check your connection and retry.'}';
      case SpeechModelDownloadPhase.cancelled:
        return 'Download cancelled · the bundled Piper voice remains available.';
    }
  }

  static String _formatMebibytes(int bytes) =>
      '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MiB';
}
