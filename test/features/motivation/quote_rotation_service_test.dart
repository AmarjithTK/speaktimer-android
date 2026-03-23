import 'package:flutter_test/flutter_test.dart';
import 'package:lifer/features/motivation/services/quote_rotation_service.dart';

void main() {
  group('QuoteRotationService', () {
    test('rotates through quotes in order for a key', () {
      final service = QuoteRotationService();
      final quotes = ['a', 'b', 'c'];

      expect(
        service.nextQuoteForList(
          key: 'General',
          quotes: quotes,
          fallbackQuote: 'fallback',
        ),
        'a',
      );
      expect(
        service.nextQuoteForList(
          key: 'General',
          quotes: quotes,
          fallbackQuote: 'fallback',
        ),
        'b',
      );
      expect(
        service.nextQuoteForList(
          key: 'General',
          quotes: quotes,
          fallbackQuote: 'fallback',
        ),
        'c',
      );
      expect(
        service.nextQuoteForList(
          key: 'General',
          quotes: quotes,
          fallbackQuote: 'fallback',
        ),
        'a',
      );
    });

    test('falls back when category is missing', () {
      final service = QuoteRotationService();
      final quotesByCategory = {
        'General': ['g1'],
      };

      final result = service.nextQuoteFromMap(
        category: 'Unknown',
        quotesByCategory: quotesByCategory,
        fallbackCategory: 'General',
        fallbackQuote: 'fallback',
      );

      expect(result, 'g1');
    });
  });
}
