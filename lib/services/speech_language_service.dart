import 'package:flutter_tts/flutter_tts.dart';

import '../models/speech_item.dart';
import 'malayalam_tts_service.dart';

/// Centralized speech language manager.
/// The selected language is the single source of truth for all speech.
class SpeechLanguageService {
  static const List<String> supportedLanguages = ['english', 'malayalam'];

  /// The active speech language.
  String _language = 'english';
  String get language => _language;

  /// Available TTS voices (set externally from [FlutterTts.getVoices]).
  List<Map<dynamic, dynamic>> allVoices = [];

  /// Sets the language. Returns true if changed.
  bool setLanguage(String lang) {
    final normalized = lang.trim().toLowerCase();
    if (!supportedLanguages.contains(normalized)) return false;
    if (_language == normalized) return false;
    _language = normalized;
    return true;
  }

  /// Returns voices filtered to the active language.
  List<Map<dynamic, dynamic>> voicesForLanguage() {
    if (_language == 'malayalam') {
      return allVoices.where((v) {
        final locale = (v['locale']?.toString() ?? '').toLowerCase();
        return locale.startsWith('ml');
      }).toList();
    }
    // English
    return allVoices.where((v) {
      final locale = (v['locale']?.toString() ?? '').toLowerCase();
      // Show English locales (en-US, en-GB, en-IN, etc.)
      return locale.startsWith('en');
    }).toList();
  }

  /// Finds the best voice for the active language from the available voices.
  /// Returns null if no suitable voice exists.
  Map<dynamic, dynamic>? preferredVoice({
    required String? favoriteVoiceName,
    required String? favoriteVoiceLocale,
  }) {
    final langVoices = voicesForLanguage();
    if (langVoices.isEmpty) return null;

    // Try favorite voice first
    if (favoriteVoiceName != null && favoriteVoiceLocale != null) {
      final match = langVoices.cast<Map<dynamic, dynamic>?>().firstWhere(
        (v) =>
            v?['name']?.toString() == favoriteVoiceName &&
            v?['locale']?.toString() == favoriteVoiceLocale,
        orElse: () => null,
      );
      if (match != null) return match;
    }

    // Prefer enhigh-quality voices (neural, veena, rishi, wavenet)
    for (final v in langVoices) {
      final name = (v['name']?.toString() ?? '').toLowerCase();
      if (name.contains('neural') || name.contains('wavenet')) return v;
    }
    if (_language == 'malayalam') {
      for (final v in langVoices) {
        final name = (v['name']?.toString() ?? '').toLowerCase();
        if (name.contains('veena') || name.contains('rishi')) return v;
      }
    }

    // Fallback: first available voice
    if (langVoices.isNotEmpty) return langVoices.first;
    return null;
  }

  /// Whether the active language is Malayalam.
  bool get isMalayalam => _language == 'malayalam';

  /// Generates speech text for the given [item] in the active language.
  String localize(SpeechItem item) {
    if (_language == 'malayalam') {
      return _toMalayalam(item);
    }
    return item.text;
  }

  String _toMalayalam(SpeechItem item) {
    final ml = MalayalamTtsService();
    final text = item.text.toLowerCase();

    if (item.isQuote) {
      // For quotes, check if already in Malayalam
      if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(item.text)) return item.text;
      return ml.defaultQuote();
    }

    // Clock announcement
    if (text.contains('time') || text.contains('o\'clock')) {
      return ml.clockAnnouncement(DateTime.now());
    }

    // Timer remaining
    if (text.contains('remaining') || text.contains('minute') || text.contains('second')) {
      final mins = _extractNumber(text);
      return ml.timerRemaining(mins);
    }

    // Timer finished
    if (text.contains('finished') || text.contains('done') || text.contains('complete')) {
      return ml.timerFinished();
    }

    // Elapsed time
    if (text.contains('elapsed')) {
      return ml.timerRemaining(_extractNumber(text));
    }

    // Goal reminder
    if (text.contains('goal')) {
      final goal = item.text.replaceAll(RegExp(r'^Goal reminder:\s*', caseSensitive: false), '');
      if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(goal)) return goal;
      return '$goal എന്ന ലക്ഷ്യത്തെ കുറിച്ച് ഓർമ്മിപ്പിക്കുന്നു.';
    }

    return ml.defaultQuote();
  }

  int _extractNumber(String text) {
    final match = RegExp(r'(\d+)').firstMatch(text);
    if (match != null) return int.tryParse(match.group(1)!) ?? 0;
    return 0;
  }

  /// Malayalam clock announcement for the given time.
  String malayalamClockAnnouncement(DateTime now) {
    return MalayalamTtsService().clockAnnouncement(now);
  }

  /// Malayalam timer announcement for the given minutes remaining.
  String malayalamTimerRemaining(int minutes) {
    return MalayalamTtsService().timerRemaining(minutes);
  }

  /// Malayalam timer finished announcement.
  String malayalamTimerFinished() {
    return MalayalamTtsService().timerFinished();
  }

  /// Malayalam stopwatch elapsed announcement.
  String malayalamStopwatchElapsed(int seconds) {
    final mins = seconds ~/ 60;
    if (mins <= 0) return 'കഴിഞ്ഞു $seconds സെക്കന്റ്.';
    return 'കഴിഞ്ഞു $mins മിനിറ്റ്.';
  }
}
