import 'package:flutter_tts/flutter_tts.dart';

import '../models/speech_item.dart';

class SpeechService {
  List<Map<dynamic, dynamic>> parseEnglishVoices(dynamic voices) {
    if (voices == null) return [];

    return List<Map<dynamic, dynamic>>.from(voices)
        .where((voice) => voice['locale']?.toString().startsWith('en') ?? false)
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
    if (voiceListMode == 'all') {
      return voices;
    }

    final filtered = voices.where(isPleasantVoice).toList();
    return filtered.isNotEmpty ? filtered : voices;
  }

  Map<dynamic, dynamic>? preferredVoice({
    required List<Map<dynamic, dynamic>> voices,
    required String voiceListMode,
    required String? favoriteVoiceName,
    required String? favoriteVoiceLocale,
  }) {
    if (voices.isEmpty) return null;

    if (favoriteVoiceName != null && favoriteVoiceLocale != null) {
      try {
        return voices.firstWhere(
          (voice) =>
              voice['name']?.toString() == favoriteVoiceName &&
              voice['locale']?.toString() == favoriteVoiceLocale,
        );
      } catch (_) {}
    }

    final available = availableVoicesForSettings(
      voices: voices,
      voiceListMode: voiceListMode,
    );
    return available.isNotEmpty ? available.first : voices.first;
  }

  Future<void> speakItem({
    required FlutterTts flutterTts,
    required SpeechItem item,
    required double speakVolume,
    required Map<dynamic, dynamic>? preferredVoice,
  }) async {
    if (preferredVoice != null) {
      await flutterTts.setVoice({
        'name': preferredVoice['name'],
        'locale': preferredVoice['locale'],
      });
    }

    if (item.isQuote) {
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.45);
    } else {
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
    }

    await flutterTts.setVolume(speakVolume);
    await flutterTts.speak(item.text);
  }
}