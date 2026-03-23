// ============================================================================
// QuoteRotationService - Cycling logic for motivational quote selection
// ============================================================================
//
// Responsibilities:
// - Maintain rotation index per quote category/list
// - Return next quote in sequence (round-robin cycling)
// - Handle category fallback for unavailable/typo'd categories
// - Provide both list-based and map-based query interfaces
//
// Behavior:
// - Quotes cycle in order: index 0, 1, 2, ..., N-1, 0, 1, ...
// - Separate index maintained for each key (category)
// - Empty lists return fallback quote immediately
// - Missing categories fall back to default (e.g., 'General')
//
// Example:
// ```dart
// final quotes = ['Tip 1', 'Tip 2', 'Tip 3'];
// service.nextQuoteForList('wellness', quotes, 'Default') // → 'Tip 1'
// service.nextQuoteForList('wellness', quotes, 'Default') // → 'Tip 2'
// service.nextQuoteForList('wellness', quotes, 'Default') // → 'Tip 3'
// service.nextQuoteForList('wellness', quotes, 'Default') // → 'Tip 1' (cycles)
// ```
//
// Benefits:
// - User perceives variety without random repetition
// - Respects order: important quotes can be sequenced
// - Stateful cycling ensures fairness across long sessions
//
// Stateless Alternative:
// If quotes should be random instead, use Random().nextInt() instead of
// indexing. Current design favors cycling to ensure all quotes get equal
// airtime.

class QuoteRotationService {
  /// Track rotation index for each unique category/list
  /// Key: category name or list identifier
  /// Value: current index in that list (auto-increments)
  final Map<String, int> _quoteIndexByCategory = {};

  /// Get next quote from a list with manual cycling
  ///
  /// Parameters:
  /// - key: Identifier for this quote list (stored in rotation index map)
  /// - quotes: List to cycle through
  /// - fallbackQuote: Returned if quotes list is empty
  ///
  /// Returns: Next quote in rotation sequence
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

  /// Get next quote from a category in the quotes map with automatic fallback
  ///
  /// Parameters:
  /// - category: Requested category (e.g., 'General', 'Focus', 'Malayalam')
  /// - quotesByCategory: Map of all available category → quotes lists
  /// - fallbackCategory: Category to use if requested category not found
  /// - fallbackQuote: Returned if fallbackCategory also empty or missing
  ///
  /// Returns: Next quote from requested or fallback category
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
