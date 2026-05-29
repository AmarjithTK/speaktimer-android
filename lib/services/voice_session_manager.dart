/// Singleton voice session manager that resolves and caches the active
/// TTS voice configuration for the duration of a speech session.
///
/// This prevents language mixing (Malayalam + English) during announcements
/// by locking the voice at session start and only re-resolving when the
/// user explicitly changes language/voice settings.
class VoiceSessionManager {
  VoiceSessionManager._();
  static final VoiceSessionManager _instance = VoiceSessionManager._();
  factory VoiceSessionManager() => _instance;

  /// Cached preferred voice (resolved once per session).
  Map<dynamic, dynamic>? _cachedVoice;

  /// Cached Malayalam active state (resolved once per session).
  bool _cachedIsMalayalam = false;

  /// The voice list mode at the time of caching.
  String _cachedVoiceListMode = '';

  /// The favorite voice name at the time of caching.
  String? _cachedFavoriteVoiceName;

  /// The favorite voice locale at the time of caching.
  String? _cachedFavoriteVoiceLocale;

  /// Whether the cache is valid for the current settings.
  bool _isCacheValid({
    required String voiceListMode,
    required String? favoriteVoiceName,
    required String? favoriteVoiceLocale,
  }) {
    return _cachedVoice != null &&
        _cachedVoiceListMode == voiceListMode &&
        _cachedFavoriteVoiceName == favoriteVoiceName &&
        _cachedFavoriteVoiceLocale == favoriteVoiceLocale;
  }

  /// Returns the cached preferred voice, or resolves a new one if cache is invalid.
  /// [voiceResolver] should return a single preferred voice Map (not a list).
  Map<dynamic, dynamic>? getPreferredVoice({
    required Map<dynamic, dynamic>? Function() voiceResolver,
    required String voiceListMode,
    required String? favoriteVoiceName,
    required String? favoriteVoiceLocale,
  }) {
    if (!_isCacheValid(
      voiceListMode: voiceListMode,
      favoriteVoiceName: favoriteVoiceName,
      favoriteVoiceLocale: favoriteVoiceLocale,
    )) {
      _cachedVoice = voiceResolver();
      _cachedVoiceListMode = voiceListMode;
      _cachedFavoriteVoiceName = favoriteVoiceName;
      _cachedFavoriteVoiceLocale = favoriteVoiceLocale;
    }
    return _cachedVoice;
  }

  /// Returns the cached Malayalam state, or resolves from voice.
  bool isMalayalamActive({
    required bool Function(Map<dynamic, dynamic>?) isMalayalamResolver,
    required Map<dynamic, dynamic>? preferredVoice,
  }) {
    if (_cachedIsMalayalam == false && _cachedVoice == null) {
      _cachedIsMalayalam = isMalayalamResolver(preferredVoice);
    }
    return _cachedIsMalayalam;
  }

  /// Resets the entire session cache. Call when user changes voice settings.
  void resetSession() {
    _cachedVoice = null;
    _cachedIsMalayalam = false;
    _cachedVoiceListMode = '';
    _cachedFavoriteVoiceName = null;
    _cachedFavoriteVoiceLocale = null;
  }
}
