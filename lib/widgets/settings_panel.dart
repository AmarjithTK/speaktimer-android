import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/sound_option.dart';
import '../providers/app_state.dart';

class SettingsPanel extends ConsumerStatefulWidget {
  // ── Side-effect callbacks only (audio, TTS, foreground service) ──
  final List<SoundOption> soundList;
  final List<double> volumeLists;
  final bool isSpeechActive;
  final int speechQueueLength;
  final List<Map<dynamic, dynamic>> voices;
  final String speechEngineRuntime;
  final String speechEngineRuntimeDetail;
  final String sleepStartLabel;
  final String sleepEndLabel;

  final ValueChanged<String?> onSoundChanged;
  final ValueChanged<double?> onNoiseVolumeChanged;
  final ValueChanged<double?> onSpeakVolumeChanged;
  final ValueChanged<bool?> onMaximumSpeechVolumeChanged;
  final ValueChanged<bool?> onSpeechMasterOnChanged;
  final ValueChanged<double?> onAppFontSizeMultiplierChanged;
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
  final VoidCallback? onOpenAccessibility;
  final bool accessibilityEnabled;
  final VoidCallback? onBackupSettings;
  final VoidCallback? onRestoreSettings;

  const SettingsPanel({
    super.key,
    required this.soundList,
    required this.volumeLists,
    required this.isSpeechActive,
    required this.speechQueueLength,
    required this.voices,
    required this.speechEngineRuntime,
    required this.speechEngineRuntimeDetail,
    required this.sleepStartLabel,
    required this.sleepEndLabel,
    required this.onSoundChanged,
    required this.onNoiseVolumeChanged,
    required this.onSpeakVolumeChanged,
    required this.onMaximumSpeechVolumeChanged,
    required this.onSpeechMasterOnChanged,
    required this.onAppFontSizeMultiplierChanged,
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
    this.onOpenAccessibility,
    this.accessibilityEnabled = false,
    this.onBackupSettings,
    this.onRestoreSettings,
  });

  @override
  ConsumerState<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends ConsumerState<SettingsPanel> {
  String _getVolTitle(double v) {
    if (v == 0.1) return 'Very Low';
    if (v == 0.2) return 'Low';
    if (v == 0.6) return 'Medium';
    if (v == 0.8) return 'High';
    return 'Very High';
  }

  String _soundTitle(String link) {
    for (final sound in widget.soundList) {
      if (sound.link == link) return sound.title;
    }
    return widget.soundList.isEmpty ? 'None' : widget.soundList.first.title;
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

  String _speechEngineLabel(String value) {
    switch (value) {
      case 'system_only': return 'System TTS only';
      case 'sherpa_only': return 'Sherpa-ONNX only';
      default: return 'Auto';
    }
  }

  String _voiceListLabel(String value) {
    switch (value) {
      case 'english': return 'English';
      case 'malayalam': return 'Malayalam';
      default: return 'Auto';
    }
  }

  String _favoriteVoiceLabel() {
    final s = ref.read(settingsProvider);
    if (s.favoriteVoiceName == null || s.favoriteVoiceLocale == null) {
      return 'Best voice for selected language';
    }
    return '${_voiceCharacterName(s.favoriteVoiceName!, s.favoriteVoiceLocale!)} - ${s.favoriteVoiceLocale}';
  }

  String _favoriteVoiceKey() {
    final s = ref.read(settingsProvider);
    if (s.favoriteVoiceName == null || s.favoriteVoiceLocale == null) return '__auto__';
    final key = '${s.favoriteVoiceName}|${s.favoriteVoiceLocale}';
    final exists = widget.voices.any((v) => '${v['name']}|${v['locale']}' == key);
    return exists ? key : '__auto__';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final speechEngineOptions = <(String, String, String?)>[
      ('auto', 'Auto', 'System TTS with Sherpa fallback'),
      ('system_only', 'System TTS only', 'Use the device speech engine'),
      if (!kIsWeb)
        ('sherpa_only', 'Sherpa-ONNX only', 'Linux/Windows fallback voice'),
    ];
    final voiceModeOptions = <(String, String, String?)>[
      ('auto', 'Auto', 'Automatically pick based on content'),
      ('english', 'English', null),
      ('malayalam', 'Malayalam', null),
    ];
    final nightModeOptions = <(String, String, String?)>[
      ('manual', 'Manual mode', 'Use the selected quiet hours'),
      ('automatic', 'Automatic mode', 'Mute after idle time at night'),
    ];
    final voiceOptions = <(String, String, String?)>[
      ('__auto__', 'Best voice for selected language', null),
      ...widget.voices.map((voice) {
        final name = voice['name']?.toString() ?? 'Unknown';
        final locale = voice['locale']?.toString() ?? 'en';
        final key = '$name|$locale';
        return (key, '${_voiceCharacterName(name, locale)} - $locale', name);
      }),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _settingsSwitch(
            context,
            icon: s.speechMasterOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            title: 'Master Audio',
            subtitle: s.speechMasterOn ? 'All audio on' : 'All audio off',
            value: s.speechMasterOn,
            onChanged: (val) {
              final newVal = val ?? true;
              notifier.updateSpeechMasterOn(newVal);
              widget.onSpeechMasterOnChanged(val);
            },
          ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.music_note_rounded,
            title: 'Background sound',
            value: _soundTitle(s.soundChosen),
            onTap: () => _showStringPicker(
              context, title: 'Background sound',
              currentValue: s.soundChosen,
              options: widget.soundList.map((s) => (s.link, s.title, null)).toList(),
              onChanged: (val) {
                notifier.updateSound(val!);
                widget.onSoundChanged(val);
              },
            ),
          ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.volume_up_rounded,
            title: 'Noise volume',
            value: _getVolTitle(s.noiseVolume),
            onTap: () => _showDoublePicker(
              context, title: 'Noise volume',
              currentValue: s.noiseVolume,
              onChanged: (val) {
                notifier.updateNoiseVolume(val!);
                widget.onNoiseVolumeChanged(val);
              },
            ),
          ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.record_voice_over_rounded,
            title: 'Speech volume',
            value: _getVolTitle(s.speakVolume),
            onTap: () => _showDoublePicker(
              context, title: 'Speech volume',
              currentValue: s.speakVolume,
              onChanged: (val) {
                notifier.updateSpeakVolume(val!);
                widget.onSpeakVolumeChanged(val);
              },
            ),
          ),
          _settingsDivider(context),
          _settingsSwitch(
            context,
            icon: Icons.volume_up_rounded,
            title: 'Boost TTS Volume',
            subtitle: 'Maximum volume for speech announcements only',
            value: s.maximumSpeechVolume,
            onChanged: (val) {
              notifier.updateMaximumSpeechVolume(val ?? false);
              widget.onMaximumSpeechVolumeChanged(val);
            },
          ),
          const SizedBox(height: 20),

          _settingsOption(
            context,
            icon: Icons.spatial_audio_off_rounded,
            title: 'Speech engine',
            value: _speechEngineLabel(s.speechEngineMode),
            onTap: () => _showStringPicker(
              context, title: 'Speech engine',
              currentValue: s.speechEngineMode,
              options: speechEngineOptions,
              onChanged: (val) {
                notifier.updateSpeechEngineMode(val!);
                widget.onSpeechEngineModeChanged(val);
              },
            ),
          ),
          if (widget.speechEngineRuntime.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(52, 0, 14, 8),
              child: Text(
                '${widget.speechEngineRuntime} — ${widget.speechEngineRuntimeDetail}',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                maxLines: 2,
              ),
            ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.language_rounded,
            title: 'Language list',
            value: _voiceListLabel(s.voiceListMode),
            onTap: () => _showStringPicker(
              context, title: 'Language list',
              currentValue: s.voiceListMode,
              options: voiceModeOptions,
              onChanged: (val) {
                notifier.updateVoiceListMode(val!);
                widget.onVoiceListModeChanged(val);
              },
            ),
          ),
          _settingsDivider(context),
          _settingsOption(
            context,
            icon: Icons.person_search_rounded,
            title: 'Preferred voice',
            value: _favoriteVoiceLabel(),
            onTap: () => _showStringPicker(
              context, title: 'Voice',
              currentValue: _favoriteVoiceKey(),
              options: voiceOptions,
              onChanged: (val) {
                if (val == null || val == '__auto__') {
                  notifier.updateFavoriteVoice(null, null);
                } else {
                  final parts = val.split('|');
                  if (parts.length == 2) {
                    notifier.updateFavoriteVoice(parts[0], parts[1]);
                  }
                }
                widget.onFavoriteVoiceChanged(val);
              },
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.fromLTRB(52, 8, 14, 0),
            child: Row(
              children: [
                Text('Font size',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                const Spacer(),
                Text('${s.appFontSizeMultiplier.toStringAsFixed(1)}x',
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          Slider(
            value: s.appFontSizeMultiplier, min: 0.8, max: 1.5, divisions: 7,
            label: '${s.appFontSizeMultiplier.toStringAsFixed(1)}x',
            onChanged: (val) {
              notifier.updateAppFontSizeMultiplier(val);
              widget.onAppFontSizeMultiplierChanged(val);
            },
          ),
          _settingsDivider(context),
          _settingsSwitch(context,
            icon: Icons.dark_mode_rounded, title: 'Dark fullscreen',
            value: s.fullscreenDarkTheme,
            onChanged: (val) {
              notifier.updateFullscreenDarkTheme(val ?? true);
              widget.onFullscreenDarkThemeChanged(val);
            }),
          _settingsDivider(context),
          _settingsSwitch(context,
            icon: Icons.brightness_4_rounded, title: 'Dim brightness',
            value: s.fullscreenDimBrightness,
            onChanged: (val) {
              notifier.updateFullscreenDimBrightness(val ?? false);
              widget.onFullscreenDimBrightnessChanged(val);
            }),
          _settingsDivider(context),
          _settingsSwitch(context,
            icon: Icons.screen_rotation_rounded, title: 'Start landscape',
            value: s.fullscreenStartLandscape,
            onChanged: (val) {
              notifier.updateFullscreenStartLandscape(val ?? false);
              widget.onFullscreenStartLandscapeChanged(val);
            }),
          const SizedBox(height: 20),

          _settingsSwitch(context,
            icon: Icons.nightlight_round, title: 'Enable sleep mode',
            subtitle: 'Quiet hours for speech',
            value: s.muteSpeechAfterMidnight,
            onChanged: (val) {
              notifier.updateMuteSpeechAfterMidnight(val ?? false);
              widget.onMuteSpeechAfterMidnightChanged(val);
            }),
          if (s.muteSpeechAfterMidnight) ...[
            _settingsDivider(context),
            _settingsOption(context,
              icon: Icons.bedtime_rounded, title: 'Mode',
              value: s.nightMuteMode == 'automatic' ? 'Automatic' : 'Manual',
              onTap: () => _showStringPicker(
                context, title: 'Sleep mode',
                currentValue: s.nightMuteMode, options: nightModeOptions,
                onChanged: (val) {
                  notifier.updateNightMuteMode(val!);
                  widget.onNightMuteModeChanged(val);
                })),
            _settingsDivider(context),
            _settingsOption(context,
              icon: Icons.schedule_rounded, title: 'Starts at',
              value: widget.sleepStartLabel, onTap: widget.onPickSleepStart),
            _settingsDivider(context),
            _settingsOption(context,
              icon: Icons.alarm_rounded, title: 'Ends at',
              value: widget.sleepEndLabel, onTap: widget.onPickSleepEnd),
          ],
          const SizedBox(height: 20),

          SwitchListTile(
            value: widget.accessibilityEnabled,
            onChanged: (_) => widget.onOpenAccessibility?.call(),
            activeThumbColor: cs.onPrimary, activeTrackColor: cs.primary,
            secondary: Icon(Icons.power_settings_new_rounded, color: cs.primary, size: 22),
            title: Text('Auto-start on reboot',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
            subtitle: Text(
              widget.accessibilityEnabled ? 'Accessibility service is ON' : 'Tap to enable',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ),
          _settingsDivider(context),
          ListTile(
            leading: Icon(Icons.backup_rounded, color: cs.primary, size: 22),
            title: Text('Backup settings',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
            subtitle: Text('Export all settings as JSON',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            trailing: Icon(Icons.file_download_outlined, color: cs.onSurfaceVariant, size: 20),
            onTap: widget.onBackupSettings,
          ),
          _settingsDivider(context),
          ListTile(
            leading: Icon(Icons.restore_rounded, color: cs.primary, size: 22),
            title: Text('Restore settings',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
            subtitle: Text('Import settings from a JSON backup',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            trailing: Icon(Icons.file_upload_outlined, color: cs.onSurfaceVariant, size: 20),
            onTap: widget.onRestoreSettings,
          ),
          _settingsDivider(context),
          ListTile(
            leading: Icon(Icons.help_outline_rounded, color: cs.primary, size: 22),
            title: Text('Help / Working',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
            trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            onTap: widget.onOpenHelp,
          ),
          _settingsDivider(context),
          ListTile(
            leading: Icon(Icons.info_outline_rounded, color: cs.primary, size: 22),
            title: Text('Built by Amarjith TK',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
            subtitle: Text('Atherpulse Technologies',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: cs.onSurfaceVariant)),
            trailing: Icon(Icons.open_in_new_rounded, color: cs.onSurfaceVariant, size: 20),
            onTap: () async {
              final url = Uri.parse('https://atherpulse.in');
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }


  Widget _settingsSwitch(BuildContext context, {
    required IconData icon, required String title,
    String? subtitle, required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return SwitchListTile(
      value: value, onChanged: onChanged,
      activeThumbColor: cs.onPrimary, activeTrackColor: cs.primary,
      secondary: Icon(icon, color: cs.primary, size: 22),
      title: Text(title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12))
          : null,
    );
  }

  Widget _settingsOption(BuildContext context, {
    required IconData icon, required String title,
    required String value, required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.primary, size: 22),
      title: Text(title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(value,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _settingsDivider(BuildContext context) {
    return Divider(height: 1, indent: 52, endIndent: 16,
      color: Theme.of(context).colorScheme.outlineVariant);
  }

  // ── Bottom sheet pickers ────────────────────────────────────
  Future<void> _showStringPicker(BuildContext context, {
    required String title, required String currentValue,
    required List<(String, String, String?)> options,
    required ValueChanged<String?> onChanged,
  }) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context, showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (listCtx, i) {
                    final o = options[i];
                    final selected = o.$1 == currentValue;
                    return ListTile(
                      selected: selected,
                      selectedTileColor: cs.primaryContainer.withAlpha(80),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      leading: Icon(
                        selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                        color: selected ? cs.primary : cs.onSurfaceVariant),
                      title: Text(o.$2, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      subtitle: o.$3 != null
                          ? Text(o.$3!, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)
                          : null,
                      onTap: () {
                        onChanged(o.$1);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDoublePicker(BuildContext context, {
    required String title, required double currentValue,
    required ValueChanged<double?> onChanged,
  }) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context, showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...widget.volumeLists.map((volume) {
                final selected = volume == currentValue;
                return ListTile(
                  selected: selected, selectedTileColor: cs.primaryContainer.withAlpha(80),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Icon(
                    selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                    color: selected ? cs.primary : cs.onSurfaceVariant),
                  title: Text(_getVolTitle(volume),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  subtitle: Text('${(volume * 100).round()}%',
                    style: const TextStyle(fontSize: 12)),
                  onTap: () {
                    onChanged(volume);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
