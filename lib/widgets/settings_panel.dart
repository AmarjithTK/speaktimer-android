import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/sound_option.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class SettingsPanel extends StatelessWidget {
  final String soundChosen;
  final double noiseVolume;
  final double speakVolume;
  final double appFontSizeMultiplier;
  final ValueChanged<double?> onAppFontSizeMultiplierChanged;
  final bool fullscreenDarkTheme;
  final bool fullscreenDimBrightness;
  final bool fullscreenStartLandscape;
  final bool muteSpeechAfterMidnight;
  final String nightMuteMode;
  final String sleepStartLabel;
  final String sleepEndLabel;
  final List<SoundOption> soundList;
  final List<double> volumeLists;
  final bool isSpeechActive;
  final int speechQueueLength;
  final String voiceListMode;
  final String speechEngineMode;
  final String speechEngineRuntime;
  final String speechEngineRuntimeDetail;
  final List<Map<dynamic, dynamic>> voices;
  final String? favoriteVoiceName;
  final String? favoriteVoiceLocale;
  final ValueChanged<String?> onSoundChanged;
  final ValueChanged<double?> onNoiseVolumeChanged;
  final ValueChanged<double?> onSpeakVolumeChanged;
  final ValueChanged<bool?> onFullscreenDarkThemeChanged;
  final ValueChanged<bool?> onFullscreenDimBrightnessChanged;
  final ValueChanged<bool?> onFullscreenStartLandscapeChanged;
  final ValueChanged<bool?> onMuteSpeechAfterMidnightChanged;
  final ValueChanged<String?> onNightMuteModeChanged;
  final VoidCallback onPickSleepStart;
  final VoidCallback onPickSleepEnd;
  final ValueChanged<String?> onVoiceListModeChanged;
  final ValueChanged<String?> onSpeechEngineModeChanged;
  final ValueChanged<String?> onFavoriteVoiceChanged;
  final VoidCallback onOpenHelp;

  const SettingsPanel({
    super.key,
    required this.soundChosen,
    required this.noiseVolume,
    required this.speakVolume,
    required this.appFontSizeMultiplier,
    required this.onAppFontSizeMultiplierChanged,
    required this.fullscreenDarkTheme,
    required this.fullscreenDimBrightness,
    required this.fullscreenStartLandscape,
    required this.muteSpeechAfterMidnight,
    required this.nightMuteMode,
    required this.sleepStartLabel,
    required this.sleepEndLabel,
    required this.soundList,
    required this.volumeLists,
    required this.isSpeechActive,
    required this.speechQueueLength,
    required this.voiceListMode,
    required this.speechEngineMode,
    required this.speechEngineRuntime,
    required this.speechEngineRuntimeDetail,
    required this.voices,
    required this.favoriteVoiceName,
    required this.favoriteVoiceLocale,
    required this.onSoundChanged,
    required this.onNoiseVolumeChanged,
    required this.onSpeakVolumeChanged,
    required this.onFullscreenDarkThemeChanged,
    required this.onFullscreenDimBrightnessChanged,
    required this.onFullscreenStartLandscapeChanged,
    required this.onMuteSpeechAfterMidnightChanged,
    required this.onNightMuteModeChanged,
    required this.onPickSleepStart,
    required this.onPickSleepEnd,
    required this.onVoiceListModeChanged,
    required this.onSpeechEngineModeChanged,
    required this.onFavoriteVoiceChanged,
    required this.onOpenHelp,
  });

  String _getVolTitle(double v) {
    if (v == 0.1) return 'Very Low';
    if (v == 0.2) return 'Low';
    if (v == 0.6) return 'Medium';
    if (v == 0.8) return 'High';
    return 'Very High';
  }

  String _voiceCharacterName(String name, String locale) {
    final lower = name.toLowerCase();
    if (lower.contains('veena')) return 'Veena';
    if (lower.contains('rishi')) return 'Rishi';
    if (lower.contains('female')) return 'Female';
    if (lower.contains('male')) return 'Male';
    if (locale.startsWith('ml')) return 'Malayalam Native';
    if (locale.startsWith('en-in')) return 'Indian English';
    if (locale.startsWith('en-us')) return 'US English';
    if (locale.startsWith('en-gb')) return 'UK English';
    return 'Standard';
  }

  String _voiceReason(String name, String locale) {
    final lower = name.toLowerCase();
    if (lower.contains('neural') ||
        lower.contains('network') ||
        lower.contains('wavenet')) {
      return 'Natural neural quality';
    }
    if (lower.contains('google') || lower.contains('samsung')) {
      return 'High clarity device voice';
    }
    if (locale.startsWith('ml')) return 'Best fit for Malayalam pronunciation';
    if (locale.startsWith('en-in')) return 'Best fit for Indian English accent';
    return 'Stable default voice';
  }

  @override
  Widget build(BuildContext context) {
    Widget sectionCard({
      required String title,
      required IconData icon,
      required List<Widget> children,
      bool initiallyExpanded = false,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: palette.accent,
          border: Border.all(color: palette.primary, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 10),
            childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            iconColor: palette.primary,
            collapsedIconColor: palette.primary,
            textColor: palette.primary,
            collapsedTextColor: palette.primary,
            title: Row(
              children: [
                Icon(icon, color: palette.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            children: children,
          ),
        ),
      );
    }

    Widget dropdownContainer(Widget child) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
          color: palette.accent,
          border: Border.all(color: palette.primary, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: child,
      );
    }

    return panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle('Settings', '', icon: Icons.settings_outlined),
          const SizedBox(height: 8),
          sectionCard(
            title: 'Audio',
            icon: Icons.volume_up_outlined,
            initiallyExpanded: true,
            children: [
              sectionLabel('Background sound'),
              dropdownContainer(
                DropdownButton<String>(
                  value: soundList.any((e) => e.link == soundChosen)
                      ? soundChosen
                      : soundList.first.link,
                  isExpanded: true,
                  underline: const SizedBox(),
                  iconEnabledColor: palette.primary,
                  dropdownColor: palette.accent,
                  items: soundList
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.link,
                          child: Text(
                            e.title,
                            style: TextStyle(
                              color: palette.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onSoundChanged,
                ),
              ),
              sectionLabel('Noise volume'),
              dropdownContainer(
                DropdownButton<double>(
                  value: noiseVolume,
                  isExpanded: true,
                  underline: const SizedBox(),
                  iconEnabledColor: palette.primary,
                  dropdownColor: palette.accent,
                  items: volumeLists
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            _getVolTitle(e),
                            style: TextStyle(
                              color: palette.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onNoiseVolumeChanged,
                ),
              ),
              sectionLabel('Speech volume'),
              dropdownContainer(
                DropdownButton<double>(
                  value: speakVolume,
                  isExpanded: true,
                  underline: const SizedBox(),
                  iconEnabledColor: palette.primary,
                  dropdownColor: palette.accent,
                  items: volumeLists
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            _getVolTitle(e),
                            style: TextStyle(
                              color: palette.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onSpeakVolumeChanged,
                ),
              ),
            ],
          ),
          sectionCard(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [
              sectionLabel('App font size'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Multiplier',
                          style: TextStyle(
                            color: palette.primary.withAlpha(170),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${appFontSizeMultiplier.toStringAsFixed(1)}x',
                          style: TextStyle(
                            color: palette.primary.withAlpha(170),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: appFontSizeMultiplier,
                      min: 0.8,
                      max: 1.5,
                      divisions: 7,
                      activeColor: palette.primary,
                      inactiveColor: palette.primary.withAlpha(50),
                      onChanged: onAppFontSizeMultiplierChanged,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: fullscreenDarkTheme,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onFullscreenDarkThemeChanged,
                  ),
                  Expanded(
                    child: sectionLabel(
                      'Use dark theme in fullscreen by default',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: fullscreenDimBrightness,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onFullscreenDimBrightnessChanged,
                  ),
                  Expanded(
                    child: sectionLabel('Dim screen brightness in fullscreen'),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: fullscreenStartLandscape,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onFullscreenStartLandscapeChanged,
                  ),
                  Expanded(
                    child: sectionLabel(
                      'Start fullscreen in horizontal orientation',
                    ),
                  ),
                ],
              ),
            ],
          ),
          sectionCard(
            title: 'Sleep Mode',
            icon: Icons.nightlight_outlined,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: muteSpeechAfterMidnight,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onMuteSpeechAfterMidnightChanged,
                  ),
                  Expanded(
                    child: sectionLabel('Enable sleep mode (custom range)'),
                  ),
                ],
              ),
              if (muteSpeechAfterMidnight) ...[
                dropdownContainer(
                  DropdownButton<String>(
                    value: nightMuteMode,
                    isExpanded: true,
                    underline: const SizedBox(),
                    iconEnabledColor: palette.primary,
                    dropdownColor: palette.accent,
                    items: const [
                      DropdownMenuItem(
                        value: 'manual',
                        child: Text('Manual mode'),
                      ),
                      DropdownMenuItem(
                        value: 'automatic',
                        child: Text('Automatic mode (idle 5 min)'),
                      ),
                    ],
                    onChanged: onNightMuteModeChanged,
                  ),
                ),
                sectionLabel('Sleep time range'),
                Row(
                  children: [
                    Expanded(
                      child: actionBtn(
                        'Start: $sleepStartLabel',
                        onPickSleepStart,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: actionBtn('End: $sleepEndLabel', onPickSleepEnd),
                    ),
                  ],
                ),
              ],
            ],
          ),
          sectionCard(
            title: 'Voice',
            icon: Icons.record_voice_over_outlined,
            children: [
              sectionLabel('Speech engine'),
              dropdownContainer(
                DropdownButton<String>(
                  value: speechEngineMode,
                  isExpanded: true,
                  underline: const SizedBox(),
                  iconEnabledColor: palette.primary,
                  dropdownColor: palette.accent,
                  items: [
                    DropdownMenuItem(
                      value: 'auto',
                      child: Text(
                        'Auto (System + Sherpa fallback)',
                        style: TextStyle(
                          color: palette.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'system_only',
                      child: Text(
                        'System TTS only',
                        style: TextStyle(
                          color: palette.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (!kIsWeb)
                      DropdownMenuItem(
                        value: 'sherpa_only',
                        child: Text(
                          'Sherpa-ONNX only (Linux/Windows)',
                          style: TextStyle(
                            color: palette.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                  onChanged: onSpeechEngineModeChanged,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Runtime engine: $speechEngineRuntime',
                style: TextStyle(
                  color: palette.primary.withAlpha(190),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                speechEngineRuntimeDetail,
                style: TextStyle(
                  color: palette.primary.withAlpha(150),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              sectionLabel('Language list'),
              dropdownContainer(
                DropdownButton<String>(
                  value: voiceListMode,
                  isExpanded: true,
                  underline: const SizedBox(),
                  iconEnabledColor: palette.primary,
                  dropdownColor: palette.accent,
                  items: [
                    DropdownMenuItem(
                      value: 'auto',
                      child: Text(
                        'Auto (English + Malayalam)',
                        style: TextStyle(
                          color: palette.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'english',
                      child: Text(
                        'English',
                        style: TextStyle(
                          color: palette.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'malayalam',
                      child: Text(
                        'Malayalam',
                        style: TextStyle(
                          color: palette.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  onChanged: onVoiceListModeChanged,
                ),
              ),
              sectionLabel('Voice list'),
              dropdownContainer(
                DropdownButton<String>(
                  value: () {
                    if (favoriteVoiceName == null ||
                        favoriteVoiceLocale == null) {
                      return '__auto__';
                    }
                    final key = '${favoriteVoiceName!}|${favoriteVoiceLocale!}';
                    final exists = voices.any(
                      (voice) => '${voice['name']}|${voice['locale']}' == key,
                    );
                    return exists ? key : '__auto__';
                  }(),
                  isExpanded: true,
                  underline: const SizedBox(),
                  iconEnabledColor: palette.primary,
                  dropdownColor: palette.accent,
                  items: [
                    DropdownMenuItem(
                      value: '__auto__',
                      child: Text(
                        'Best voice for selected language',
                        style: TextStyle(
                          color: palette.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ...voices.map((voice) {
                      final name = voice['name']?.toString() ?? 'Unknown';
                      final locale = voice['locale']?.toString() ?? 'en';
                      final key = '$name|$locale';
                      final character = _voiceCharacterName(name, locale);
                      final reason = _voiceReason(name, locale);
                      return DropdownMenuItem(
                        value: key,
                        child: Text(
                          '$character ($name) · $locale · $reason',
                          style: TextStyle(
                            color: palette.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: onFavoriteVoiceChanged,
                ),
              ),
            ],
          ),
          sectionCard(
            title: 'Help & Status',
            icon: Icons.help_outline,
            children: [
              actionBtn('❓ Help / How it works', onOpenHelp),
              const SizedBox(height: 8),
              Text(
                "${isSpeechActive ? '🔉 Speaking…' : (speechQueueLength > 0 ? '⏳ $speechQueueLength queued' : '✔ Ready')}  ·  A↔B gap: 10 s",
                style: TextStyle(
                  fontSize: 10,
                  color: palette.primary.withAlpha(140),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
