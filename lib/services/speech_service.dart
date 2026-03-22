import 'package:flutter_tts/flutter_tts.dart';

import '../models/speech_item.dart';

class SpeechService {
  bool isMalayalamLocale(String? locale) {
    return locale?.toLowerCase().startsWith('ml') ?? false;
  }

  List<Map<dynamic, dynamic>> parseSupportedVoices(dynamic voices) {
    if (voices == null) return [];

    return List<Map<dynamic, dynamic>>.from(voices)
        .where((voice) {
          final locale = voice['locale']?.toString().toLowerCase() ?? '';
          return locale.startsWith('en') || locale.startsWith('ml');
        })
        .toList();
  }

  bool isPleasantVoice(Map<dynamic, dynamic> voice) {
    final name = voice['name']?.toString().toLowerCase() ?? '';
    final locale = voice['locale']?.toString().toLowerCase() ?? '';
    return name.contains('network') ||
        name.contains('veena') ||
        name.contains('rishi') ||
        locale == 'en-in' ||
        locale == 'en-us';
  }

  List<Map<dynamic, dynamic>> availableVoicesForSettings({
    required List<Map<dynamic, dynamic>> voices,
    required String voiceListMode,
  }) {
    if (voiceListMode == 'malayalam') {
      final malayalamVoices = voices
          .where((voice) => isMalayalamLocale(voice['locale']?.toString()))
          .toList();
      return malayalamVoices.isNotEmpty ? malayalamVoices : voices;
    }

    if (voiceListMode == 'all') {
      return voices
          .where((voice) => voice['locale']?.toString().startsWith('en') ?? false)
          .toList();
    }

    final englishVoices = voices
        .where((voice) => voice['locale']?.toString().startsWith('en') ?? false)
        .toList();
    final filtered = englishVoices.where(isPleasantVoice).toList();
    if (filtered.isNotEmpty) return filtered;
    return englishVoices.isNotEmpty ? englishVoices : voices;
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

    return available.isNotEmpty ? available.first : voices.first;
  }

  Future<void> speakItem({
    required FlutterTts flutterTts,
    required SpeechItem item,
    required double speakVolume,
    required Map<dynamic, dynamic>? preferredVoice,
    required bool useMalayalamNuance,
  }) async {
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