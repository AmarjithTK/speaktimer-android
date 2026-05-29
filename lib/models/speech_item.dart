class SpeechItem {
  final String text;
  final bool isQuote;
  final int delayMs;
  final String? language; // 'en' or 'ml' - set at enqueue time for consistency

  SpeechItem(this.text, {this.isQuote = false, this.delayMs = 0, this.language});
}
