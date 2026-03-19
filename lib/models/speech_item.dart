class SpeechItem {
  final String text;
  final bool isQuote;
  final int delayMs;
  SpeechItem(this.text, {this.isQuote = false, this.delayMs = 0});
}
