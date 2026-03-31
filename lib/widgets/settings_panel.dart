import 'package:flutter/material.dart';

import '../models/sound_option.dart';
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
  final bool goalReminderOn;
  final int goalReminderIntervalMins;
  final List<int> goalReminderIntervalOptions;
  final List<String> goalReminderItems;
  final int goalReminderNextIndex;
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
  final ValueChanged<bool?> onGoalReminderOnChanged;
  final ValueChanged<int?> onGoalReminderIntervalChanged;
  final VoidCallback onAddGoal;
  final VoidCallback onBulkAddGoals;
  final void Function(int index) onEditGoal;
  final void Function(int index) onRemoveGoal;
  final VoidCallback onSpeakNextGoalNow;
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
    required this.goalReminderOn,
    required this.goalReminderIntervalMins,
    required this.goalReminderIntervalOptions,
    required this.goalReminderItems,
    required this.goalReminderNextIndex,
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
    required this.onGoalReminderOnChanged,
    required this.onGoalReminderIntervalChanged,
    required this.onAddGoal,
    required this.onBulkAddGoals,
    required this.onEditGoal,
    required this.onRemoveGoal,
    required this.onSpeakNextGoalNow,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget sectionCard({
      required String title,
      required IconData icon,
      required List<Widget> children,
      bool initiallyExpanded = false,
    }) {
      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        color: cs.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            iconColor: cs.onSurfaceVariant,
            collapsedIconColor: cs.onSurfaceVariant,
            title: Row(
              children: [
                Icon(icon, color: cs.primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            children: children,
          ),
        ),
      );
    }

    Widget dropdownField<T>({
      required T value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T?> onChanged,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          iconEnabledColor: cs.onSurfaceVariant,
          dropdownColor: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          items: items,
          onChanged: onChanged,
        ),
      );
    }

    return panelContainer(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(context, 'Settings', icon: Icons.settings_outlined),
          const SizedBox(height: 8),
          sectionCard(
            title: 'Audio',
            icon: Icons.volume_up_outlined,
            initiallyExpanded: true,
            children: [
              sectionLabel(context, 'Background sound'),
              dropdownField<String>(
                value: soundList.any((e) => e.link == soundChosen)
                    ? soundChosen
                    : soundList.first.link,
                items: soundList
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.link,
                        child: Text(
                          e.title,
                          style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onSoundChanged,
              ),
              sectionLabel(context, 'Noise volume'),
              dropdownField<double>(
                value: noiseVolume,
                items: volumeLists
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          _getVolTitle(e),
                          style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onNoiseVolumeChanged,
              ),
              sectionLabel(context, 'Speech volume'),
              dropdownField<double>(
                value: speakVolume,
                items: volumeLists
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          _getVolTitle(e),
                          style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onSpeakVolumeChanged,
              ),
            ],
          ),
          sectionCard(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: appDarkTheme,
                onChanged: (val) => onAppDarkThemeChanged(val),
                title: Text(
                  'Dark theme for app',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: fullscreenDarkTheme,
                onChanged: (val) => onFullscreenDarkThemeChanged(val),
                title: Text(
                  'Dark theme in fullscreen by default',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: fullscreenDimBrightness,
                onChanged: (val) => onFullscreenDimBrightnessChanged(val),
                title: Text(
                  'Dim screen brightness in fullscreen',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: fullscreenStartLandscape,
                onChanged: (val) => onFullscreenStartLandscapeChanged(val),
                title: Text(
                  'Start fullscreen in landscape orientation',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          sectionCard(
            title: 'Sleep Mode',
            icon: Icons.nightlight_outlined,
            children: [
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: muteSpeechAfterMidnight,
                onChanged: (val) => onMuteSpeechAfterMidnightChanged(val),
                title: Text(
                  'Enable sleep mode',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              if (muteSpeechAfterMidnight) ...[
                dropdownField<String>(
                  value: nightMuteMode,
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
                sectionLabel(context, 'Sleep time range'),
                Row(
                  children: [
                    Expanded(
                      child: actionBtn(
                        context,
                        'Start: $sleepStartLabel',
                        onPickSleepStart,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: actionBtn(
                          context, 'End: $sleepEndLabel', onPickSleepEnd),
                    ),
                  ],
                ),
              ],
            ],
          ),
          sectionCard(
            title: 'Goal Reminder',
            icon: Icons.flag_outlined,
            children: [
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: goalReminderOn,
                onChanged: (val) => onGoalReminderOnChanged(val),
                title: Text(
                  'Enable goal reminder (TTS round-robin)',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              if (goalReminderOn) ...[
                sectionLabel(context, 'Goal reminder interval'),
                dropdownField<int>(
                  value: goalReminderIntervalMins,
                  items: goalReminderIntervalOptions
                      .map(
                        (mins) => DropdownMenuItem(
                          value: mins,
                          child: Text(
                            mins == 60
                                ? 'Every 1 hour'
                                : (mins == 120
                                    ? 'Every 2 hours'
                                    : 'Every $mins minutes'),
                            style:
                                tt.bodyMedium?.copyWith(color: cs.onSurface),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onGoalReminderIntervalChanged,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: actionBtn(
                        context,
                        'Add goal',
                        onAddGoal,
                        icon: Icons.add_task_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: actionBtn(
                        context,
                        'Bulk add',
                        onBulkAddGoals,
                        icon: Icons.playlist_add_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                actionBtn(
                  context,
                  'Speak next goal now',
                  onSpeakNextGoalNow,
                  icon: Icons.record_voice_over_outlined,
                ),
                sectionLabel(
                  context,
                  'Goals (${goalReminderItems.length})'
                  '${goalReminderItems.isEmpty ? '' : ' · Next: ${(goalReminderNextIndex % goalReminderItems.length) + 1}'}',
                ),
                if (goalReminderItems.isEmpty)
                  Text(
                    'No goals yet. Add one goal or bulk add one per line.',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  )
                else
                  ...goalReminderItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final goal = entry.value;
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 6),
                      color: cs.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                '${index + 1}. $goal',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Edit goal',
                              onPressed: () => onEditGoal(index),
                              icon: Icon(
                                Icons.edit_outlined,
                                color: cs.onSurfaceVariant,
                                size: 18,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Delete goal',
                              onPressed: () => onRemoveGoal(index),
                              icon: Icon(
                                Icons.delete_outline,
                                color: cs.error,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ],
          ),
          sectionCard(
            title: 'Voice',
            icon: Icons.record_voice_over_outlined,
            children: [
              sectionLabel(context, 'Voice list'),
              dropdownField<String>(
                value: voiceListMode,
                items: [
                  DropdownMenuItem(
                    value: 'pleasant',
                    child: Text(
                      'Pleasant voices',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'all',
                    child: Text(
                      'All English voices',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'malayalam',
                    child: Text(
                      'Malayalam voices',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                  ),
                ],
                onChanged: onVoiceListModeChanged,
              ),
              sectionLabel(context, 'Favorite voice'),
              dropdownField<String>(
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
                items: [
                  DropdownMenuItem(
                    value: '__auto__',
                    child: Text(
                      'Auto select',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
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
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: onFavoriteVoiceChanged,
              ),
            ],
          ),
          sectionCard(
            title: 'Help & Status',
            icon: Icons.help_outline,
            children: [
              actionBtn(context, 'Help / How it works', onOpenHelp,
                  icon: Icons.help_outline),
              const SizedBox(height: 10),
              Text(
                isSpeechActive
                    ? 'Speaking…'
                    : (speechQueueLength > 0
                        ? '$speechQueueLength queued'
                        : 'Ready'),
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
