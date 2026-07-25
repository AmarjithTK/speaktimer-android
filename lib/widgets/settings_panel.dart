import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/palette.dart' show AppColorAccess;

import '../models/sound_option.dart';

class SettingsPanel extends StatefulWidget {
  final String soundChosen;
  final double noiseVolume;
  final double speakVolume;
  final bool maximumSpeechVolume;
  final bool speechMasterOn;
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
  final ValueChanged<bool?> onMaximumSpeechVolumeChanged;
  final ValueChanged<bool?> onSpeechMasterOnChanged;
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

  const SettingsPanel({
    super.key,
    required this.soundChosen,
    required this.noiseVolume,
    required this.speakVolume,
    required this.maximumSpeechVolume,
    required this.speechMasterOn,
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
    required this.onMaximumSpeechVolumeChanged,
    required this.onSpeechMasterOnChanged,
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
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  // Local mutable copies so the panel updates its own UI after changes.
  late String _soundChosen;
  late double _noiseVolume;
  late double _speakVolume;
  late bool _maximumSpeechVolume;
  late bool _speechMasterOn;
  late double _appFontSizeMultiplier;
  late bool _fullscreenDarkTheme;
  late bool _fullscreenDimBrightness;
  late bool _fullscreenStartLandscape;
  late bool _muteSpeechAfterMidnight;
  late String _nightMuteMode;
  late String _voiceListMode;
  late String _speechEngineMode;
  late String? _favoriteVoiceName;
  late String? _favoriteVoiceLocale;

  @override
  void initState() {
    super.initState();
    _soundChosen = widget.soundChosen;
    _noiseVolume = widget.noiseVolume;
    _speakVolume = widget.speakVolume;
    _maximumSpeechVolume = widget.maximumSpeechVolume;
    _speechMasterOn = widget.speechMasterOn;
    _appFontSizeMultiplier = widget.appFontSizeMultiplier;
    _fullscreenDarkTheme = widget.fullscreenDarkTheme;
    _fullscreenDimBrightness = widget.fullscreenDimBrightness;
    _fullscreenStartLandscape = widget.fullscreenStartLandscape;
    _muteSpeechAfterMidnight = widget.muteSpeechAfterMidnight;
    _nightMuteMode = widget.nightMuteMode;
    _voiceListMode = widget.voiceListMode;
    _speechEngineMode = widget.speechEngineMode;
    _favoriteVoiceName = widget.favoriteVoiceName;
    _favoriteVoiceLocale = widget.favoriteVoiceLocale;
  }

  @override
  void didUpdateWidget(covariant SettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync local state if parent rebuilds with new values.
    if (oldWidget.soundChosen != widget.soundChosen) _soundChosen = widget.soundChosen;
    if (oldWidget.noiseVolume != widget.noiseVolume) _noiseVolume = widget.noiseVolume;
    if (oldWidget.speakVolume != widget.speakVolume) _speakVolume = widget.speakVolume;
    if (oldWidget.maximumSpeechVolume != widget.maximumSpeechVolume) _maximumSpeechVolume = widget.maximumSpeechVolume;
    if (oldWidget.speechMasterOn != widget.speechMasterOn) _speechMasterOn = widget.speechMasterOn;
    if (oldWidget.appFontSizeMultiplier != widget.appFontSizeMultiplier) _appFontSizeMultiplier = widget.appFontSizeMultiplier;
    if (oldWidget.fullscreenDarkTheme != widget.fullscreenDarkTheme) _fullscreenDarkTheme = widget.fullscreenDarkTheme;
    if (oldWidget.fullscreenDimBrightness != widget.fullscreenDimBrightness) _fullscreenDimBrightness = widget.fullscreenDimBrightness;
    if (oldWidget.fullscreenStartLandscape != widget.fullscreenStartLandscape) _fullscreenStartLandscape = widget.fullscreenStartLandscape;
    if (oldWidget.muteSpeechAfterMidnight != widget.muteSpeechAfterMidnight) _muteSpeechAfterMidnight = widget.muteSpeechAfterMidnight;
    if (oldWidget.nightMuteMode != widget.nightMuteMode) _nightMuteMode = widget.nightMuteMode;
    if (oldWidget.voiceListMode != widget.voiceListMode) _voiceListMode = widget.voiceListMode;
    if (oldWidget.speechEngineMode != widget.speechEngineMode) _speechEngineMode = widget.speechEngineMode;
    if (oldWidget.favoriteVoiceName != widget.favoriteVoiceName) _favoriteVoiceName = widget.favoriteVoiceName;
    if (oldWidget.favoriteVoiceLocale != widget.favoriteVoiceLocale) _favoriteVoiceLocale = widget.favoriteVoiceLocale;
  }

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
    if (_favoriteVoiceName == null || _favoriteVoiceLocale == null) {
      return 'Best voice for selected language';
    }
    return '${_voiceCharacterName(_favoriteVoiceName!, _favoriteVoiceLocale!)} - $_favoriteVoiceLocale';
  }

  String _favoriteVoiceKey() {
    if (_favoriteVoiceName == null || _favoriteVoiceLocale == null) return '__auto__';
    final key = '$_favoriteVoiceName|$_favoriteVoiceLocale';
    final exists = widget.voices.any((v) => '${v['name']}|${v['locale']}' == key);
    return exists ? key : '__auto__';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Audio & Speech ──────────────────────────────────
          _sectionCard(context, Icons.volume_up_rounded, 'Audio & Speech', [
            _settingsSwitch(
              context,
              icon: _speechMasterOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              title: 'Master Audio',
              subtitle: _speechMasterOn ? 'All audio on' : 'All audio off',
              value: _speechMasterOn,
              onChanged: (val) {
                setState(() => _speechMasterOn = val ?? true);
                widget.onSpeechMasterOnChanged(val);
              },
            ),
            _settingsDivider(context),
            _settingsOption(
              context,
              icon: Icons.music_note_rounded,
              title: 'Background sound',
              value: _soundTitle(_soundChosen),
              onTap: () => _showStringPicker(
                context, title: 'Background sound',
                currentValue: _soundChosen,
                options: widget.soundList.map((s) => (s.link, s.title, null)).toList(),
                onChanged: (val) {
                  setState(() => _soundChosen = val!);
                  widget.onSoundChanged(val);
                },
              ),
            ),
            _settingsDivider(context),
            _settingsOption(
              context,
              icon: Icons.volume_up_rounded,
              title: 'Noise volume',
              value: _getVolTitle(_noiseVolume),
              onTap: () => _showDoublePicker(
                context, title: 'Noise volume',
                currentValue: _noiseVolume,
                onChanged: (val) {
                  setState(() => _noiseVolume = val!);
                  widget.onNoiseVolumeChanged(val);
                },
              ),
            ),
            _settingsDivider(context),
            _settingsOption(
              context,
              icon: Icons.record_voice_over_rounded,
              title: 'Speech volume',
              value: _getVolTitle(_speakVolume),
              onTap: () => _showDoublePicker(
                context, title: 'Speech volume',
                currentValue: _speakVolume,
                onChanged: (val) {
                  setState(() => _speakVolume = val!);
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
              value: _maximumSpeechVolume,
              onChanged: (val) {
                setState(() => _maximumSpeechVolume = val ?? false);
                widget.onMaximumSpeechVolumeChanged(val);
              },
            ),
          ]),
          const SizedBox(height: 12),

          // ── Voice ────────────────────────────────────────────
          _sectionCard(context, Icons.record_voice_over_rounded, 'Voice', [
            _settingsOption(
              context,
              icon: Icons.spatial_audio_off_rounded,
              title: 'Speech engine',
              value: _speechEngineLabel(_speechEngineMode),
              onTap: () => _showStringPicker(
                context, title: 'Speech engine',
                currentValue: _speechEngineMode,
                options: speechEngineOptions,
                onChanged: (val) {
                  setState(() => _speechEngineMode = val!);
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
              value: _voiceListLabel(_voiceListMode),
              onTap: () => _showStringPicker(
                context, title: 'Language list',
                currentValue: _voiceListMode,
                options: voiceModeOptions,
                onChanged: (val) {
                  setState(() => _voiceListMode = val!);
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
                    setState(() {
                      _favoriteVoiceName = null;
                      _favoriteVoiceLocale = null;
                    });
                  } else {
                    final parts = val.split('|');
                    if (parts.length == 2) {
                      setState(() {
                        _favoriteVoiceName = parts[0];
                        _favoriteVoiceLocale = parts[1];
                      });
                    }
                  }
                  widget.onFavoriteVoiceChanged(val);
                },
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Focus & Fullscreen ────────────────────────────────
          _sectionCard(context, Icons.fullscreen_rounded, 'Focus & Fullscreen', [
            Padding(
              padding: const EdgeInsets.fromLTRB(52, 8, 14, 0),
              child: Row(
                children: [
                  Text('Font size',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cs.onSurface)),
                  const Spacer(),
                  Text('${_appFontSizeMultiplier.toStringAsFixed(1)}x',
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
            ),
            Slider(
              value: _appFontSizeMultiplier, min: 0.8, max: 1.5, divisions: 7,
              label: '${_appFontSizeMultiplier.toStringAsFixed(1)}x',
              onChanged: (val) {
                setState(() => _appFontSizeMultiplier = val);
                widget.onAppFontSizeMultiplierChanged(val);
              },
            ),
            _settingsDivider(context),
            _settingsSwitch(context,
              icon: Icons.dark_mode_rounded, title: 'Dark fullscreen',
              value: _fullscreenDarkTheme,
              onChanged: (val) {
                setState(() => _fullscreenDarkTheme = val ?? true);
                widget.onFullscreenDarkThemeChanged(val);
              }),
            _settingsDivider(context),
            _settingsSwitch(context,
              icon: Icons.brightness_4_rounded, title: 'Dim brightness',
              value: _fullscreenDimBrightness,
              onChanged: (val) {
                setState(() => _fullscreenDimBrightness = val ?? false);
                widget.onFullscreenDimBrightnessChanged(val);
              }),
            _settingsDivider(context),
            _settingsSwitch(context,
              icon: Icons.screen_rotation_rounded, title: 'Start landscape',
              value: _fullscreenStartLandscape,
              onChanged: (val) {
                setState(() => _fullscreenStartLandscape = val ?? false);
                widget.onFullscreenStartLandscapeChanged(val);
              }),
          ]),
          const SizedBox(height: 12),

          // ── Sleep Mode ────────────────────────────────────────
          _sectionCard(context, Icons.nightlight_round, 'Sleep Mode', [
            _settingsSwitch(context,
              icon: Icons.nightlight_round, title: 'Enable sleep mode',
              subtitle: 'Quiet hours for speech',
              value: _muteSpeechAfterMidnight,
              onChanged: (val) {
                setState(() => _muteSpeechAfterMidnight = val ?? false);
                widget.onMuteSpeechAfterMidnightChanged(val);
              }),
            if (_muteSpeechAfterMidnight) ...[
              _settingsDivider(context),
              _settingsOption(context,
                icon: Icons.bedtime_rounded, title: 'Mode',
                value: _nightMuteMode == 'automatic' ? 'Automatic' : 'Manual',
                onTap: () => _showStringPicker(
                  context, title: 'Sleep mode',
                  currentValue: _nightMuteMode, options: nightModeOptions,
                  onChanged: (val) {
                    setState(() => _nightMuteMode = val!);
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
          ]),
          const SizedBox(height: 12),

          // ── System ────────────────────────────────────────────
          _sectionCard(context, Icons.settings_rounded, 'System', [
            SwitchListTile(
              value: widget.accessibilityEnabled,
              onChanged: (_) => widget.onOpenAccessibility?.call(),
              activeThumbColor: cs.onPrimary, activeTrackColor: cs.primary,
              secondary: Icon(Icons.power_settings_new_rounded, color: cs.primary, size: 22),
              title: Text('Auto-start on reboot',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cs.onSurface)),
              subtitle: Text(
                widget.accessibilityEnabled ? 'Accessibility service is ON' : 'Tap to enable',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ),
            _settingsDivider(context),
            ListTile(
              leading: Icon(Icons.help_outline_rounded, color: cs.primary, size: 22),
              title: Text('Help / Working',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cs.onSurface)),
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              onTap: widget.onOpenHelp,
            ),
            _settingsDivider(context),
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: cs.primary, size: 22),
              title: Text('Built by Amarjith TK',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cs.onSurface)),
              subtitle: Text('Atherpulse Technologies',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: cs.onSurfaceVariant)),
              trailing: Icon(Icons.open_in_new_rounded, color: cs.onSurfaceVariant, size: 20),
              onTap: () async {
                final url = Uri.parse('https://atherpulse.in');
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
          ]),
        ],
      ),
    );
  }

  // ── Reusable section card ────────────────────────────────────
  Widget _sectionCard(BuildContext context, IconData icon, String title, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    final c = context.appColors;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(title,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cs.onSurface)),
                ],
              ),
            ),
            ...children,
            const SizedBox(height: 4),
          ],
        ),
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
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cs.onSurface)),
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
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: cs.onSurface)),
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
