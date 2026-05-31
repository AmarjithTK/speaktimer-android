import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/sound_option.dart';

class SettingsPanel extends StatelessWidget {
  final String soundChosen;
  final double noiseVolume;
  final double speakVolume;
  final bool ttsMaxVolumeLockEnabled;
  final bool ttsVolumeBoostEnabled;
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
  final ValueChanged<bool?> onTtsMaxVolumeLockEnabledChanged;
  final ValueChanged<bool?> onTtsVolumeBoostEnabledChanged;
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
  final VoidCallback onOpenGoals;
  final VoidCallback? onOpenAccessibility;
  final bool accessibilityEnabled;

  const SettingsPanel({
    super.key,
    required this.soundChosen,
    required this.noiseVolume,
    required this.speakVolume,
    required this.ttsMaxVolumeLockEnabled,
    required this.ttsVolumeBoostEnabled,
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
    required this.onTtsMaxVolumeLockEnabledChanged,
    required this.onTtsVolumeBoostEnabledChanged,
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
    required this.onOpenGoals,
    this.onOpenAccessibility,
    this.accessibilityEnabled = false,
  });

  String _getVolTitle(double v) {
    if (v == 0.1) return 'Very Low';
    if (v == 0.2) return 'Low';
    if (v == 0.6) return 'Medium';
    if (v == 0.8) return 'High';
    return 'Very High';
  }

  String _soundTitle(String link) {
    for (final sound in soundList) {
      if (sound.link == link) return sound.title;
    }
    return soundList.isEmpty ? 'None' : soundList.first.title;
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

  String _speechEngineLabel(String value) {
    switch (value) {
      case 'system_only':
        return 'System TTS only';
      case 'sherpa_only':
        return 'Sherpa-ONNX only';
      default:
        return 'Auto';
    }
  }

  String _voiceListLabel(String value) {
    switch (value) {
      case 'english':
        return 'English';
      case 'malayalam':
        return 'Malayalam';
      default:
        return 'Auto';
    }
  }

  String _favoriteVoiceLabel() {
    if (favoriteVoiceName == null || favoriteVoiceLocale == null) {
      return 'Best voice for selected language';
    }
    return '${_voiceCharacterName(favoriteVoiceName!, favoriteVoiceLocale!)} - $favoriteVoiceLocale';
  }

  String _favoriteVoiceKey() {
    if (favoriteVoiceName == null || favoriteVoiceLocale == null) {
      return '__auto__';
    }
    final key = '$favoriteVoiceName|$favoriteVoiceLocale';
    final exists = voices.any(
      (voice) => '${voice['name']}|${voice['locale']}' == key,
    );
    return exists ? key : '__auto__';
  }

  Future<void> _showStringPicker(
    BuildContext context, {
    required String title,
    required String currentValue,
    required List<(String, String, String?)> options,
    required ValueChanged<String?> onChanged,
  }) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetTitle(context, title),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.58,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: options.map((option) {
                    final selected = option.$1 == currentValue;
                    return _pickerTile(
                      context,
                      selected: selected,
                      title: option.$2,
                      subtitle: option.$3,
                      onTap: () {
                        onChanged(option.$1);
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDoublePicker(
    BuildContext context, {
    required String title,
    required double currentValue,
    required ValueChanged<double?> onChanged,
  }) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetTitle(context, title),
              const SizedBox(height: 8),
              ...volumeLists.map((volume) {
                final selected = volume == currentValue;
                return _pickerTile(
                  context,
                  selected: selected,
                  title: _getVolTitle(volume),
                  subtitle: '${(volume * 100).round()}%',
                  onTap: () {
                    onChanged(volume);
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTitle(BuildContext context, String title) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        color: cs.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _pickerTile(
    BuildContext context, {
    required bool selected,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      selected: selected,
      selectedTileColor: cs.primaryContainer.withAlpha(80),
      leading: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
        color: selected ? cs.primary : cs.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
      onTap: onTap,
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _card(BuildContext context, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Column(children: children),
    );
  }

  Widget _selectRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Icon(icon, color: cs.primary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _switchRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    String? subtitle,
  }) {
    final cs = Theme.of(context).colorScheme;
    return SwitchListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      secondary: Icon(icon, color: cs.primary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
      value: value,
      activeThumbColor: cs.onPrimary,
      activeTrackColor: cs.primary,
      onChanged: (value) => onChanged(value),
    );
  }

  Widget _divider(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(height: 1, indent: 52, color: cs.outlineVariant);
  }

  Widget _filledAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final speechEngineOptions = <(String, String, String?)>[
      ('auto', 'Auto', 'System TTS with Sherpa fallback'),
      ('system_only', 'System TTS only', 'Use the device speech engine'),
      if (!kIsWeb)
        ('sherpa_only', 'Sherpa-ONNX only', 'Linux and Windows fallback voice'),
    ];
    final voiceModeOptions = <(String, String, String?)>[
      ('english', 'English', null),
      ('malayalam', 'Malayalam', null),
    ];
    final nightModeOptions = <(String, String, String?)>[
      ('manual', 'Manual mode', 'Use the selected quiet hours'),
      ('automatic', 'Automatic mode', 'Mute after idle time at night'),
    ];
    final voiceOptions = <(String, String, String?)>[
      ('__auto__', 'Best voice for selected language', null),
      ...voices.map((voice) {
        final name = voice['name']?.toString() ?? 'Unknown';
        final locale = voice['locale']?.toString() ?? 'en';
        final key = '$name|$locale';
        return (
          key,
          '${_voiceCharacterName(name, locale)} - $locale',
          '$name - ${_voiceReason(name, locale)}',
        );
      }),
    ];
    final status = isSpeechActive
        ? 'Speaking'
        : (speechQueueLength > 0 ? '$speechQueueLength queued' : 'Ready');

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return ColoredBox(
          color: cs.surface,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? double.infinity : 430,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _sectionTitle(context, 'Audio'),
                          _card(context, [
                            _selectRow(
                              context,
                              icon: Icons.music_note_rounded,
                              title: 'Background sound',
                              value: _soundTitle(soundChosen),
                              onTap: () => _showStringPicker(
                                context,
                                title: 'Background sound',
                                currentValue: soundChosen,
                                options: soundList
                                    .map(
                                      (sound) =>
                                          (sound.link, sound.title, null),
                                    )
                                    .toList(),
                                onChanged: onSoundChanged,
                              ),
                            ),
                            _divider(context),
                            _selectRow(
                              context,
                              icon: Icons.volume_up_rounded,
                              title: 'Noise volume',
                              value: _getVolTitle(noiseVolume),
                              onTap: () => _showDoublePicker(
                                context,
                                title: 'Noise volume',
                                currentValue: noiseVolume,
                                onChanged: onNoiseVolumeChanged,
                              ),
                            ),
                            _divider(context),
                            _selectRow(
                              context,
                              icon: Icons.record_voice_over_rounded,
                              title: 'Speech volume',
                              value: _getVolTitle(speakVolume),
                              onTap: () => _showDoublePicker(
                                context,
                                title: 'Speech volume',
                                currentValue: speakVolume,
                                onChanged: onSpeakVolumeChanged,
                              ),
                            ),
                            _divider(context),
                            _switchRow(
                              context,
                              icon: Icons.volume_up_outlined,
                              title: 'Max device volume for TTS',
                              value: ttsMaxVolumeLockEnabled,
                              onChanged: onTtsMaxVolumeLockEnabledChanged,
                            ),
                            _divider(context),
                            _switchRow(
                              context,
                              icon: Icons.surround_sound_rounded,
                              title: 'Boost announcement speech',
                              subtitle: 'TTS only',
                              value: ttsVolumeBoostEnabled,
                              onChanged: onTtsVolumeBoostEnabledChanged,
                            ),
                          ]),
                          _sectionTitle(context, 'Voice'),
                          _card(context, [
                            _selectRow(
                              context,
                              icon: Icons.spatial_audio_off_rounded,
                              title: 'Speech engine',
                              value: _speechEngineLabel(speechEngineMode),
                              onTap: () => _showStringPicker(
                                context,
                                title: 'Speech engine',
                                currentValue: speechEngineMode,
                                options: speechEngineOptions,
                                onChanged: onSpeechEngineModeChanged,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                52,
                                0,
                                14,
                                10,
                              ),
                              child: Text(
                                '$speechEngineRuntime - $speechEngineRuntimeDetail',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _divider(context),
                            _selectRow(
                              context,
                              icon: Icons.language_rounded,
                              title: 'Language list',
                              value: _voiceListLabel(voiceListMode),
                              onTap: () => _showStringPicker(
                                context,
                                title: 'Language list',
                                currentValue: voiceListMode,
                                options: voiceModeOptions,
                                onChanged: onVoiceListModeChanged,
                              ),
                            ),
                            _divider(context),
                            _selectRow(
                              context,
                              icon: Icons.person_search_rounded,
                              title: 'Voice',
                              value: _favoriteVoiceLabel(),
                              onTap: () => _showStringPicker(
                                context,
                                title: 'Voice',
                                currentValue: _favoriteVoiceKey(),
                                options: voiceOptions,
                                onChanged: onFavoriteVoiceChanged,
                              ),
                            ),
                          ]),
                          _sectionTitle(context, 'Appearance'),
                          _card(context, [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.text_fields_rounded,
                                    color: cs.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 18),
                                  Text(
                                    'App font size',
                                    style: TextStyle(
                                      color: cs.onSurface,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${appFontSizeMultiplier.toStringAsFixed(1)}x',
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Slider(
                              value: appFontSizeMultiplier,
                              min: 0.8,
                              max: 1.5,
                              divisions: 7,
                              label:
                                  '${appFontSizeMultiplier.toStringAsFixed(1)}x',
                              onChanged: onAppFontSizeMultiplierChanged,
                            ),
                            _divider(context),
                            _switchRow(
                              context,
                              icon: Icons.dark_mode_rounded,
                              title: 'Dark fullscreen',
                              value: fullscreenDarkTheme,
                              onChanged: onFullscreenDarkThemeChanged,
                            ),
                            _divider(context),
                            _switchRow(
                              context,
                              icon: Icons.brightness_4_rounded,
                              title: 'Dim fullscreen brightness',
                              value: fullscreenDimBrightness,
                              onChanged: onFullscreenDimBrightnessChanged,
                            ),
                            _divider(context),
                            _switchRow(
                              context,
                              icon: Icons.screen_rotation_rounded,
                              title: 'Start fullscreen landscape',
                              value: fullscreenStartLandscape,
                              onChanged: onFullscreenStartLandscapeChanged,
                            ),
                          ]),
                          _sectionTitle(context, 'Sleep mode'),
                          _card(context, [
                            _switchRow(
                              context,
                              icon: Icons.nightlight_round,
                              title: 'Enable sleep mode',
                              subtitle: 'Custom quiet range',
                              value: muteSpeechAfterMidnight,
                              onChanged: onMuteSpeechAfterMidnightChanged,
                            ),
                            if (muteSpeechAfterMidnight) ...[
                              _divider(context),
                              _selectRow(
                                context,
                                icon: Icons.bedtime_rounded,
                                title: 'Mode',
                                value: nightMuteMode == 'automatic'
                                    ? 'Automatic'
                                    : 'Manual',
                                onTap: () => _showStringPicker(
                                  context,
                                  title: 'Sleep mode',
                                  currentValue: nightMuteMode,
                                  options: nightModeOptions,
                                  onChanged: onNightMuteModeChanged,
                                ),
                              ),
                              _divider(context),
                              _selectRow(
                                context,
                                icon: Icons.schedule_rounded,
                                title: 'Starts',
                                value: sleepStartLabel,
                                onTap: onPickSleepStart,
                              ),
                              _divider(context),
                              _selectRow(
                                context,
                                icon: Icons.alarm_rounded,
                                title: 'Ends',
                                value: sleepEndLabel,
                                onTap: onPickSleepEnd,
                              ),
                            ],
                          ]),
                          _sectionTitle(context, 'Goals'),
                          _card(context, [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: FilledButton.icon(
                                  onPressed: onOpenGoals,
                                  icon: const Icon(Icons.flag_rounded, size: 18),
                                  label: const Text('Manage Goals'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: cs.primary,
                                    foregroundColor: cs.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        _sectionTitle(context, 'Auto-start'),
                        _card(context, [
                          SwitchListTile(
                              value: accessibilityEnabled,
                              onChanged: (val) {
                                if (!accessibilityEnabled) {
                                  onOpenAccessibility?.call();
                                }
                              },
                            activeThumbColor: cs.onPrimary,
                            activeTrackColor: cs.primary,
                            secondary: Icon(
                              Icons.power_settings_new_rounded,
                              color: cs.primary,
                              size: 20,
                            ),
                            title: Text(
                              'Auto-start after reboot',
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              accessibilityEnabled
                                  ? 'Accessibility service is ON'
                                  : 'Tap to enable in system settings',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ]),
                        _sectionTitle(context, 'Help & Status'),
                          _card(context, [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _filledAction(
                                    context,
                                    icon: Icons.help_outline_rounded,
                                    label: 'Help / How it works',
                                    onPressed: onOpenHelp,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        isSpeechActive
                                            ? Icons.volume_up_rounded
                                            : Icons.check_circle_outline_rounded,
                                        color: cs.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '$status - A/B gap: 10 s',
                                          style: TextStyle(
                                            color: cs.onSurfaceVariant,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ]),
                          _sectionTitle(context, 'About'),
                          _card(context, [
                            ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              leading: Icon(
                                Icons.info_outline_rounded,
                                color: cs.primary,
                                size: 20,
                              ),
                              title: const Text(
                                'Built by Amarjith TK',
                                style: TextStyle(
                                  color: Color(0xFF1C1B1F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: const Text(
                                'Atherpulse Technologies',
                                style: TextStyle(
                                  color: Color(0xFF49454F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                              ),
                              onTap: () async {
                                final url = Uri.parse(
                                  'https://atherpulse.in',
                                );
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
