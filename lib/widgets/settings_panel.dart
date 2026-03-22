import 'package:flutter/material.dart';

import '../models/sound_option.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class SettingsPanel extends StatelessWidget {
  final String soundChosen;
  final double noiseVolume;
  final double speakVolume;
  final bool fullscreenDarkTheme;
  final bool fullscreenDimBrightness;
  final bool fullscreenStartLandscape;
  final bool appDarkTheme;
  final bool muteSpeechAfterMidnight;
  final String nightMuteMode;
  final String sleepStartLabel;
  final String sleepEndLabel;
  final List<SoundOption> soundList;
  final List<double> volumeLists;
  final bool isSpeechActive;
  final int speechQueueLength;
  final String voiceListMode;
  final List<Map<dynamic, dynamic>> voices;
  final String? favoriteVoiceName;
  final String? favoriteVoiceLocale;
  final ValueChanged<String?> onSoundChanged;
  final ValueChanged<double?> onNoiseVolumeChanged;
  final ValueChanged<double?> onSpeakVolumeChanged;
  final ValueChanged<bool?> onFullscreenDarkThemeChanged;
  final ValueChanged<bool?> onFullscreenDimBrightnessChanged;
  final ValueChanged<bool?> onFullscreenStartLandscapeChanged;
  final ValueChanged<bool?> onAppDarkThemeChanged;
  final ValueChanged<bool?> onMuteSpeechAfterMidnightChanged;
  final ValueChanged<String?> onNightMuteModeChanged;
  final VoidCallback onPickSleepStart;
  final VoidCallback onPickSleepEnd;
  final ValueChanged<String?> onVoiceListModeChanged;
  final ValueChanged<String?> onFavoriteVoiceChanged;
  final VoidCallback onOpenHelp;

  const SettingsPanel({
    super.key,
    required this.soundChosen,
    required this.noiseVolume,
    required this.speakVolume,
    required this.fullscreenDarkTheme,
    required this.fullscreenDimBrightness,
    required this.fullscreenStartLandscape,
    required this.appDarkTheme,
    required this.muteSpeechAfterMidnight,
    required this.nightMuteMode,
    required this.sleepStartLabel,
    required this.sleepEndLabel,
    required this.soundList,
    required this.volumeLists,
    required this.isSpeechActive,
    required this.speechQueueLength,
    required this.voiceListMode,
    required this.voices,
    required this.favoriteVoiceName,
    required this.favoriteVoiceLocale,
    required this.onSoundChanged,
    required this.onNoiseVolumeChanged,
    required this.onSpeakVolumeChanged,
    required this.onFullscreenDarkThemeChanged,
    required this.onFullscreenDimBrightnessChanged,
    required this.onFullscreenStartLandscapeChanged,
    required this.onAppDarkThemeChanged,
    required this.onMuteSpeechAfterMidnightChanged,
    required this.onNightMuteModeChanged,
    required this.onPickSleepStart,
    required this.onPickSleepEnd,
    required this.onVoiceListModeChanged,
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

  @override
  Widget build(BuildContext context) {
    return panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle('Settings', '', icon: Icons.settings_outlined),
          sectionLabel('Background sound'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<String>(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<double>(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<double>(
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
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(
                value: appDarkTheme,
                activeColor: palette.primary,
                checkColor: palette.accent,
                onChanged: onAppDarkThemeChanged,
              ),
              Expanded(
                child: sectionLabel('Use dark theme for app (Material You)'),
              ),
            ],
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
                child: sectionLabel('Use dark theme in fullscreen by default'),
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
          Row(
            children: [
              Checkbox(
                value: muteSpeechAfterMidnight,
                activeColor: palette.primary,
                checkColor: palette.accent,
                onChanged: onMuteSpeechAfterMidnightChanged,
              ),
              Expanded(child: sectionLabel('Enable sleep mode (custom range)')),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<String>(
              value: nightMuteMode,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: const [
                DropdownMenuItem(value: 'manual', child: Text('Manual mode')),
                DropdownMenuItem(
                  value: 'automatic',
                  child: Text('Automatic mode (idle 5 min)'),
                ),
              ],
              selectedItemBuilder: (context) => [
                Text(
                  'Manual mode',
                  style: TextStyle(
                    color: palette.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Automatic mode (idle 5 min)',
                  style: TextStyle(
                    color: palette.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
              onChanged: muteSpeechAfterMidnight
                  ? onNightMuteModeChanged
                  : null,
            ),
          ),
          sectionLabel('Sleep time range'),
          Row(
            children: [
              Expanded(
                child: actionBtn('Start: $sleepStartLabel', onPickSleepStart),
              ),
              const SizedBox(width: 6),
              Expanded(child: actionBtn('End: $sleepEndLabel', onPickSleepEnd)),
            ],
          ),
          sectionLabel('Voice list'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<String>(
              value: voiceListMode,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: [
                DropdownMenuItem(
                  value: 'pleasant',
                  child: Text(
                    'Pleasant voices',
                    style: TextStyle(
                      color: palette.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'all',
                  child: Text(
                    'All English voices',
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
                    'Malayalam voices',
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
          sectionLabel('Favorite voice'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<String>(
              value: () {
                if (favoriteVoiceName == null || favoriteVoiceLocale == null) {
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
                    'Auto select',
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
                  return DropdownMenuItem(
                    value: key,
                    child: Text(
                      '$name ($locale)',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8),
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: palette.primary,
                  width: 1,
                  style: BorderStyle.none,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
        ],
      ),
    );
  }
}
