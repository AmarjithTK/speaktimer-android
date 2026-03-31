import 'package:flutter/material.dart';

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

  Widget _quickStep(
    BuildContext context,
    int index,
    String title,
    String subtitle,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 6),
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$index',
                style: tt.labelSmall?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.titleSmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(
    BuildContext context, {
    required String title,
    required List<String> points,
    bool initiallyExpanded = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          iconColor: cs.onSurfaceVariant,
          collapsedIconColor: cs.onSurfaceVariant,
          title: Text(
            title,
            style: tt.titleSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: points
              .map(
                (text) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          text,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final range = '$sleepStartLabel → $sleepEndLabel';
    final sleepModeStatus = !muteSpeechAfterMidnight
        ? 'Sleep mode is OFF'
        : (nightMuteMode == 'manual'
            ? 'Sleep mode is ON · Manual'
            : 'Sleep mode is ON · Automatic');

    return panelContainer(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle(context, 'Help & Guide', icon: Icons.help_outline),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: cs.secondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: cs.onSecondaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$sleepModeStatus\nCurrent range: $range',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Quick Start',
            style: tt.titleSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          _quickStep(
            context,
            1,
            'Configure timer and speech',
            'Open Timer Setup, choose minutes, speech interval, and optional chain preset.',
          ),
          _quickStep(
            context,
            2,
            'Set sleep behavior',
            'Open Settings, enable Sleep mode, pick Manual or Automatic, and choose time range.',
          ),
          _quickStep(
            context,
            3,
            'Use widget controls',
            'From home screen widget, toggle speech, start/stop timer, or launch quick 25m/resume.',
          ),
          _faqItem(
            context,
            title: 'SpeakClock (Clock tab)',
            points: [
              'Turn ON SpeakClock to hear time announcements at your selected interval.',
              'Optional motivation quotes are spoken after each time announcement.',
            ],
          ),
          _faqItem(
            context,
            title: 'Timer Setup',
            points: [
              'Set minutes with slider or quick presets.',
              'Enable speech to hear remaining-time messages.',
              'Chain mode runs preset sequences like Pomodoro automatically.',
            ],
          ),
          _faqItem(
            context,
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
            context,
            title: 'Home Screen Widget',
            points: [
              'Speech button instantly turns timer speech ON/OFF.',
              'Start/Stop controls timer directly from home screen.',
              '25m and Resume buttons start quick sessions.',
              'Widget status shows Speech, Timer, and Night state.',
            ],
          ),
          _faqItem(
            context,
            title: 'Tips',
            points: [
              'If widget command feels delayed, wait 1–2 seconds for sync.',
              'Keep notification and battery permissions allowed for stable background behavior.',
            ],
          ),
        ],
      ),
    );
  }
}
