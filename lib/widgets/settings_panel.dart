import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../models/sound_option.dart';
import 'ui_helpers.dart';

class SettingsPanel extends StatelessWidget {
  final String soundChosen;
  final double noiseVolume;
  final double speakVolume;
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
  final ValueChanged<String?> onVoiceListModeChanged;
  final ValueChanged<String?> onFavoriteVoiceChanged;

  const SettingsPanel({
    super.key,
    required this.soundChosen,
    required this.noiseVolume,
    required this.speakVolume,
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
    required this.onVoiceListModeChanged,
    required this.onFavoriteVoiceChanged,
  });

  String _getVolTitle(double v) {
    if (v == 0.1) return "Very Low";
    if (v == 0.2) return "Low";
    if (v == 0.6) return "Medium";
    if (v == 0.8) return "High";
    return "Very High";
  }

  @override
  Widget build(BuildContext context) {
    return panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle("⚙ Settings", ""),
          sectionLabel("Background sound"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<String>(
              value: soundList.any((e) => e.link == soundChosen) ? soundChosen : soundList.first.link,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: soundList.map((e) => DropdownMenuItem(
                value: e.link,
                child: Text(e.title, style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              )).toList(),
              onChanged: onSoundChanged,
            ),
          ),
          sectionLabel("Noise volume"),
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
              items: volumeLists.map((e) => DropdownMenuItem(
                value: e,
                child: Text(_getVolTitle(e), style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              )).toList(),
              onChanged: onNoiseVolumeChanged,
            ),
          ),
          sectionLabel("Speech volume"),
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
              items: volumeLists.map((e) => DropdownMenuItem(
                value: e,
                child: Text(_getVolTitle(e), style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              )).toList(),
              onChanged: onSpeakVolumeChanged,
            ),
          ),
          sectionLabel("Voice list"),
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
                    style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                ),
                DropdownMenuItem(
                  value: 'all',
                  child: Text(
                    'All English voices',
                    style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                ),
              ],
              onChanged: onVoiceListModeChanged,
            ),
          ),
          sectionLabel("Favorite voice"),
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
                    style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12),
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
                      style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12),
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
            decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.primary, width: 1, style: BorderStyle.none))),
            child: Text(
              "${isSpeechActive ? '🔉 Speaking…' : (speechQueueLength > 0 ? '⏳ $speechQueueLength queued' : '✔ Ready')}  ·  A↔B gap: 10 s",
              style: TextStyle(fontSize: 10, color: palette.primary.withAlpha(140)),
            ),
          )
        ],
      )
    );
  }
}
