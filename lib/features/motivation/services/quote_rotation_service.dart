class QuoteRotationService {
  final Map<String, int> _quoteIndexByCategory = {};

  String nextQuoteForList({
    required String key,
    required List<String> quotes,
    required String fallbackQuote,
  }) {
    if (quotes.isEmpty) {
      return fallbackQuote;
    }

    final currentIndex = _quoteIndexByCategory[key] ?? 0;
    final selected = quotes[currentIndex % quotes.length];
    _quoteIndexByCategory[key] = currentIndex + 1;
    return selected;
  }

  String nextQuoteFromMap({
    required String category,
    required Map<String, List<String>> quotesByCategory,
    required String fallbackCategory,
    required String fallbackQuote,
  }) {
    final normalizedCategory = quotesByCategory.containsKey(category)
        ? category
        : fallbackCategory;

    final categoryQuotes = quotesByCategory[normalizedCategory] ?? const [];
    return nextQuoteForList(
      key: normalizedCategory,
      quotes: categoryQuotes,
      fallbackQuote: fallbackQuote,
    );
  }
}
