import 'package:flutter_test/flutter_test.dart';
import 'package:solasflow/models/speech_item.dart';
import 'package:solasflow/services/malayalam_tts_service.dart';
import 'package:solasflow/services/speech_language_service.dart';

void main() {
  group('SpeechLanguageService language & voice selection', () {
    late SpeechLanguageService service;

    setUp(() {
      service = SpeechLanguageService();
      service.allVoices = [
        {'name': 'en-US-language', 'locale': 'en-US'},
        {'name': 'en-GB-language', 'locale': 'en-GB'},
        {'name': 'ml-IN-language', 'locale': 'ml-IN'},
      ];
    });

    test('supports auto, english, and malayalam', () {
      expect(
        SpeechLanguageService.supportedLanguages,
        containsAll(['auto', 'english', 'malayalam']),
      );
      expect(service.setLanguage('malayalam'), isTrue);
      expect(service.language, 'malayalam');
      expect(service.isMalayalam, isTrue);

      expect(service.setLanguage('english'), isTrue);
      expect(service.language, 'english');
      expect(service.isMalayalam, isFalse);

      expect(service.setLanguage('auto'), isTrue);
      expect(service.language, 'auto');
    });

    test(
      'voicesForLanguage filters Malayalam voices exclusively when Malayalam is selected',
      () {
        service.setLanguage('malayalam');
        final voices = service.voicesForLanguage();
        expect(voices, hasLength(1));
        expect(voices.first['locale'], 'ml-IN');
        expect(
          voices.any((v) => (v['locale'] as String).startsWith('en')),
          isFalse,
        );
      },
    );

    test(
      'voicesForLanguage provides Standard Malayalam fallback when no native voices exist',
      () {
        service.allVoices = [
          {'name': 'en-US-voice', 'locale': 'en-US'},
        ];
        service.setLanguage('malayalam');
        final voices = service.voicesForLanguage();
        expect(voices, isNotEmpty);
        expect(voices.first['locale'], 'ml-IN');
        expect(voices.first['name'], 'Standard Malayalam');
      },
    );

    test(
      'voicesForLanguage filters English voices when English is selected',
      () {
        service.setLanguage('english');
        final voices = service.voicesForLanguage();
        expect(voices, hasLength(2));
        expect(
          voices.every((v) => (v['locale'] as String).startsWith('en')),
          isTrue,
        );
      },
    );

    test(
      'preferredVoice never returns an English voice when Malayalam is selected',
      () {
        service.setLanguage('malayalam');
        final voice = service.preferredVoice(
          favoriteVoiceName: 'en-US-language',
          favoriteVoiceLocale: 'en-US',
        );
        expect(voice, isNotNull);
        expect(voice!['locale'], startsWith('ml'));
      },
    );

    test(
      'localize translates timer and clock announcements to Malayalam when active',
      () {
        service.setLanguage('malayalam');
        final timerItem = SpeechItem('3 minutes remaining');
        final localized = service.localize(timerItem);
        expect(localized, contains('മിനിറ്റ്'));
      },
    );
    test('Malayalam clock announcements omit the time prefix', () {
      final announcement = MalayalamTtsService().clockAnnouncement(
        DateTime(2026, 9, 7, 18, 22),
      );

      expect(announcement, '6 മണി 22 മിനിറ്റ്.');
      expect(announcement, isNot(startsWith('സമയം')));
    });
  });
}
