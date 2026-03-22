import 'package:flutter/material.dart';

import '../theme/palette.dart';
import 'ui_helpers.dart';

class HelpPanel extends StatelessWidget {
  final bool muteSpeechAfterMidnight;
  final String nightMuteMode;
  final String sleepStartLabel;
  final String sleepEndLabel;

  const HelpPanel({
    super.key,
    required this.muteSpeechAfterMidnight,
    required this.nightMuteMode,
    required this.sleepStartLabel,
    required this.sleepEndLabel,
  });

  Widget _quickStep(int index, String title, String subtitle) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: palette.accent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.primary.withAlpha(120), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: palette.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: palette.primary.withAlpha(190),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem({
    required String title,
    required List<String> points,
    bool initiallyExpanded = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: palette.accent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.primary, width: 1.4),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        iconColor: palette.primary,
        collapsedIconColor: palette.primary,
        title: Text(
          title,
          style: TextStyle(
            color: palette.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        children: points
            .map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 13,
                        color: palette.primary.withAlpha(190),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: palette.primary.withAlpha(210),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final range = '$sleepStartLabel → $sleepEndLabel';
    final sleepModeStatus = !muteSpeechAfterMidnight
        ? 'Sleep mode is OFF'
        : (nightMuteMode == 'manual'
              ? 'Sleep mode is ON • Manual'
              : 'Sleep mode is ON • Automatic');

    return panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle('Help & Guide', '', icon: Icons.help_outline),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: palette.primary),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '$sleepModeStatus\nCurrent range: $range',
                    style: TextStyle(
                      color: palette.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quick Start',
            style: TextStyle(
              color: palette.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          _quickStep(
            1,
            'Configure timer and speech',
            'Open Timer Setup, choose minutes, speech interval, and optional chain preset.',
          ),
          _quickStep(
            2,
            'Set sleep behavior',
            'Open Settings, enable Sleep mode, pick Manual or Automatic, and choose time range.',
          ),
          _quickStep(
            3,
            'Use widget controls',
            'From home screen widget, toggle speech, start/stop timer, or launch quick 25m/resume.',
          ),
          _faqItem(
            title: 'SpeakClock (Tab A)',
            points: [
              'Turn ON SpeakClock to hear time announcements at your selected interval.',
              'Optional motivation quotes are spoken after each time announcement.',
            ],
          ),
          _faqItem(
            title: 'Timer Setup (Tab B)',
            points: [
              'Set minutes with slider or quick presets.',
              'Enable speech to hear remaining-time messages.',
              'Chain mode runs preset sequences like Pomodoro automatically.',
            ],
          ),
          _faqItem(
            title: 'Sleep Mode (Settings)',
            initiallyExpanded: true,
            points: [
              'Choose custom sleep range with Start and End time pickers.',
              'Manual mode: speech is muted for the full configured range.',
              'Automatic mode: after 5 minutes inactivity during sleep range, mute auto-activates.',
              'When you use phone again during sleep range, current time is spoken after 5 seconds.',
            ],
          ),
          _faqItem(
            title: 'Home Screen Widget',
            points: [
              'Speech button instantly turns timer speech ON/OFF.',
              'Start/Stop controls timer directly from home screen.',
              '25m and Resume buttons start quick sessions.',
              'Widget status shows Speech, Timer, and Night state.',
            ],
          ),
          _faqItem(
            title: 'Tips',
            points: [
              'If widget command feels delayed, wait 1-2 seconds for sync.',
              'Keep notification and battery permissions allowed for stable background behavior.',
            ],
          ),
        ],
      ),
    );
  }
}
