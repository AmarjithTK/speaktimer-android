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
  final int clockIntervalMins;
  final bool clockShowMilliseconds;
  final bool motivationOn;
  final String motivationCategory;
  final int motivationDelaySeconds;
  final List<int> clockIntervalOptions;
  final List<String> motivationCategories;
  final List<int> motivationDelayOptions;
  final bool timerNoiseOn;
  final bool timerSpeakOn;
  final bool timerShowMilliseconds;
  final int timerAnnounceEvery;
  final List<int> timerAnnounceOptions;
  final bool chainModeOn;
  final String chainPresetKey;
  final Map<String, List<int>> chainPresets;
  final int chainIndex;
  final bool stopwatchSpeakOn;
  final bool stopwatchShowMilliseconds;
  final int stopwatchSpeakDelaySeconds;
  final List<int> stopwatchSpeakDelayOptions;
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
  final ValueChanged<int?> onClockIntervalChanged;
  final ValueChanged<bool?> onClockShowMillisecondsChanged;
  final ValueChanged<bool?> onMotivationChanged;
  final ValueChanged<String?> onMotivationCategoryChanged;
  final ValueChanged<int?> onMotivationDelayChanged;
  final ValueChanged<bool?> onTimerNoiseOnChanged;
  final ValueChanged<bool?> onTimerSpeakOnChanged;
  final ValueChanged<bool?> onTimerShowMillisecondsChanged;
  final ValueChanged<int?> onTimerAnnounceEveryChanged;
  final ValueChanged<bool?> onChainModeChanged;
  final ValueChanged<String?> onChainPresetChanged;
  final ValueChanged<bool?> onStopwatchSpeakOnChanged;
  final ValueChanged<bool?> onStopwatchShowMillisecondsChanged;
  final ValueChanged<int?> onStopwatchSpeakDelayChanged;
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
    required this.clockIntervalMins,
    required this.clockShowMilliseconds,
    required this.motivationOn,
    required this.motivationCategory,
    required this.motivationDelaySeconds,
    required this.clockIntervalOptions,
    required this.motivationCategories,
    required this.motivationDelayOptions,
    required this.timerNoiseOn,
    required this.timerSpeakOn,
    required this.timerShowMilliseconds,
    required this.timerAnnounceEvery,
    required this.timerAnnounceOptions,
    required this.chainModeOn,
    required this.chainPresetKey,
    required this.chainPresets,
    required this.chainIndex,
    required this.stopwatchSpeakOn,
    required this.stopwatchShowMilliseconds,
    required this.stopwatchSpeakDelaySeconds,
    required this.stopwatchSpeakDelayOptions,
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
    required this.onClockIntervalChanged,
    required this.onClockShowMillisecondsChanged,
    required this.onMotivationChanged,
    required this.onMotivationCategoryChanged,
    required this.onMotivationDelayChanged,
    required this.onTimerNoiseOnChanged,
    required this.onTimerSpeakOnChanged,
    required this.onTimerShowMillisecondsChanged,
    required this.onTimerAnnounceEveryChanged,
    required this.onChainModeChanged,
    required this.onChainPresetChanged,
    required this.onStopwatchSpeakOnChanged,
    required this.onStopwatchShowMillisecondsChanged,
    required this.onStopwatchSpeakDelayChanged,
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
              Row(
                children: [
                  Checkbox(
                    value: appDarkTheme,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onAppDarkThemeChanged,
                  ),
                  Expanded(
                    child: sectionLabel(
                      'Use dark theme for app (Material You)',
                    ),
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
            title: 'Clock Advanced',
            icon: Icons.schedule,
            children: [
              dropdownContainer(
                DropdownButton<int>(
                  value: clockIntervalMins,
                  isExpanded: true,
                  underline: const SizedBox(),
                  iconEnabledColor: palette.primary,
                  dropdownColor: palette.accent,
                  items: clockIntervalOptions
                      .map(
                        (mins) => DropdownMenuItem(
                          value: mins,
                          child: Text(
                            'Announce every $mins min',
                            style: TextStyle(
                              color: palette.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onClockIntervalChanged,
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: clockShowMilliseconds,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onClockShowMillisecondsChanged,
                  ),
                  Expanded(
                    child: sectionLabel('Show milliseconds in Speaking Clock'),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: motivationOn,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onMotivationChanged,
                  ),
                  Expanded(
                    child: sectionLabel('Speak motivational quote after time'),
                  ),
                ],
              ),
              if (motivationOn) ...[
                dropdownContainer(
                  DropdownButton<String>(
                    value: motivationCategory,
                    isExpanded: true,
                    underline: const SizedBox(),
                    iconEnabledColor: palette.primary,
                    dropdownColor: palette.accent,
                    items: motivationCategories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: TextStyle(
                                color: palette.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onMotivationCategoryChanged,
                  ),
                ),
                const SizedBox(height: 6),
                dropdownContainer(
                  DropdownButton<int>(
                    value: motivationDelaySeconds,
                    isExpanded: true,
                    underline: const SizedBox(),
                    iconEnabledColor: palette.primary,
                    dropdownColor: palette.accent,
                    items: motivationDelayOptions
                        .map(
                          (seconds) => DropdownMenuItem(
                            value: seconds,
                            child: Text(
                              'Motivation delay: $seconds sec',
                              style: TextStyle(
                                color: palette.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onMotivationDelayChanged,
                  ),
                ),
              ],
            ],
          ),
          sectionCard(
            title: 'Timer Advanced',
            icon: Icons.timer_outlined,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: timerNoiseOn,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onTimerNoiseOnChanged,
                  ),
                  Expanded(
                    child: sectionLabel('Play background noise during timer'),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: timerSpeakOn,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onTimerSpeakOnChanged,
                  ),
                  Expanded(child: sectionLabel('Speak remaining during timer')),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: timerShowMilliseconds,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onTimerShowMillisecondsChanged,
                  ),
                  Expanded(child: sectionLabel('Show milliseconds in timer')),
                ],
              ),
              if (timerSpeakOn)
                dropdownContainer(
                  DropdownButton<int>(
                    value: timerAnnounceEvery,
                    isExpanded: true,
                    underline: const SizedBox(),
                    iconEnabledColor: palette.primary,
                    dropdownColor: palette.accent,
                    items: timerAnnounceOptions
                        .map(
                          (mins) => DropdownMenuItem(
                            value: mins,
                            child: Text(
                              'Speak every $mins min',
                              style: TextStyle(
                                color: palette.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onTimerAnnounceEveryChanged,
                  ),
                ),
              Row(
                children: [
                  Checkbox(
                    value: chainModeOn,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onChainModeChanged,
                  ),
                  Expanded(child: sectionLabel('Enable chain timers')),
                ],
              ),
              if (chainModeOn) ...[
                dropdownContainer(
                  DropdownButton<String>(
                    value: chainPresetKey,
                    isExpanded: true,
                    underline: const SizedBox(),
                    iconEnabledColor: palette.primary,
                    dropdownColor: palette.accent,
                    items: chainPresets.keys
                        .map(
                          (key) => DropdownMenuItem(
                            value: key,
                            child: Text(
                              key,
                              style: TextStyle(
                                color: palette.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onChainPresetChanged,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Chain step ${chainIndex + 1}/${chainPresets[chainPresetKey]?.length ?? 1}',
                    style: TextStyle(
                      color: palette.primary.withAlpha(170),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
          sectionCard(
            title: 'Stopwatch Advanced',
            icon: Icons.av_timer_outlined,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: stopwatchSpeakOn,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onStopwatchSpeakOnChanged,
                  ),
                  Expanded(
                    child: sectionLabel('Speak elapsed time automatically'),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: stopwatchShowMilliseconds,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onStopwatchShowMillisecondsChanged,
                  ),
                  Expanded(
                    child: sectionLabel('Show milliseconds in Stopwatch'),
                  ),
                ],
              ),
              if (stopwatchSpeakOn)
                dropdownContainer(
                  DropdownButton<int>(
                    value: stopwatchSpeakDelaySeconds,
                    isExpanded: true,
                    underline: const SizedBox(),
                    iconEnabledColor: palette.primary,
                    dropdownColor: palette.accent,
                    items: stopwatchSpeakDelayOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e >= 60
                                  ? (e % 60 == 0 ? '${e ~/ 60} min' : '${e}s')
                                  : '$e sec',
                              style: TextStyle(
                                color: palette.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onStopwatchSpeakDelayChanged,
                  ),
                ),
            ],
          ),
          sectionCard(
            title: 'Goal Reminder',
            icon: Icons.flag_outlined,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: goalReminderOn,
                    activeColor: palette.primary,
                    checkColor: palette.accent,
                    onChanged: onGoalReminderOnChanged,
                  ),
                  Expanded(
                    child: sectionLabel(
                      'Enable goal reminder (TTS round-robin)',
                    ),
                  ),
                ],
              ),
              if (goalReminderOn) ...[
                sectionLabel('Goal reminder interval'),
                dropdownContainer(
                  DropdownButton<int>(
                    value: goalReminderIntervalMins,
                    isExpanded: true,
                    underline: const SizedBox(),
                    iconEnabledColor: palette.primary,
                    dropdownColor: palette.accent,
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
                              style: TextStyle(
                                color: palette.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onGoalReminderIntervalChanged,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: actionBtn(
                        'Add goal',
                        onAddGoal,
                        icon: Icons.add_task_outlined,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: actionBtn(
                        'Bulk add lines',
                        onBulkAddGoals,
                        icon: Icons.playlist_add_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                actionBtn(
                  'Speak next goal now',
                  onSpeakNextGoalNow,
                  icon: Icons.record_voice_over_outlined,
                ),
                sectionLabel(
                  'Goals (${goalReminderItems.length})${goalReminderItems.isEmpty ? '' : ' · Next: ${(goalReminderNextIndex % goalReminderItems.length) + 1}'}',
                ),
                if (goalReminderItems.isEmpty)
                  Text(
                    'No goals yet. Add one goal or bulk add one per line.',
                    style: TextStyle(
                      color: palette.primary.withAlpha(160),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  ...goalReminderItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final goal = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: palette.accent,
                        border: Border.all(color: palette.primary, width: 2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${index + 1}. $goal',
                              style: TextStyle(
                                color: palette.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Edit goal',
                            onPressed: () => onEditGoal(index),
                            icon: Icon(
                              Icons.edit_outlined,
                              color: palette.primary,
                              size: 18,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Delete goal',
                            onPressed: () => onRemoveGoal(index),
                            icon: Icon(
                              Icons.delete_outline,
                              color: palette.primary,
                              size: 18,
                            ),
                          ),
                        ],
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
              sectionLabel('Voice list'),
              dropdownContainer(
                DropdownButton<String>(
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
