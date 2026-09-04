import 'package:flutter_test/flutter_test.dart';
import 'package:solasflow/services/speech_service.dart';

void main() {
  group('SpeechService language mode and voice selection', () {
    late SpeechService service;

    setUp(() {
      service = SpeechService();
    });

    test('normalizeVoiceLanguageMode normalizes correctly', () {
      expect(service.normalizeVoiceLanguageMode('malayalam'), 'malayalam');
      expect(service.normalizeVoiceLanguageMode('Malayalam'), 'malayalam');
      expect(service.normalizeVoiceLanguageMode('english'), 'english');
      expect(service.normalizeVoiceLanguageMode('auto'), 'auto');
    });

    test('availableVoicesForSettings never falls back to English when Malayalam is chosen', () {
      final englishOnly = [
        {'name': 'en-US-x-sfg#female', 'locale': 'en-US'},
        {'name': 'en-GB-x-rjs#male', 'locale': 'en-GB'},
      ];

      final voices = service.availableVoicesForSettings(
        voices: englishOnly,
        voiceListMode: 'malayalam',
      );

      expect(voices, isNotEmpty);
      expect(voices.first['locale'], 'ml-IN');
      expect(voices.any((v) => (v['locale'] as String).startsWith('en')), isFalse);
    });

    test('availableVoicesForSettings returns Malayalam voices when present', () {
      final mixed = [
        {'name': 'en-US-x-sfg#female', 'locale': 'en-US'},
        {'name': 'ml-in-x-mlc#male', 'locale': 'ml-IN'},
      ];

      final voices = service.availableVoicesForSettings(
        voices: mixed,
        voiceListMode: 'malayalam',
      );

      expect(voices, hasLength(1));
      expect(voices.first['locale'], 'ml-IN');
      expect(voices.first['name'], 'ml-in-x-mlc#male');
    });

    test('preferredVoice returns Malayalam voice when Malayalam mode is active', () {
      final mixed = [
        {'name': 'en-US-x-sfg#female', 'locale': 'en-US'},
        {'name': 'ml-in-x-mlc#male', 'locale': 'ml-IN'},
      ];

      final voice = service.preferredVoice(
        voices: mixed,
        voiceListMode: 'malayalam',
        favoriteVoiceName: null,
        favoriteVoiceLocale: null,
      );

      expect(voice, isNotNull);
      expect(voice!['locale'], 'ml-IN');
    });
  });
}
