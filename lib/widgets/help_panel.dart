import 'package:flutter/material.dart';

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

  Widget _quickStep(BuildContext context, int index, String title, String subtitle) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(subtitle,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
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

  Widget _faqItem(
    BuildContext context, {
    required String title,
    required List<String> points,
    bool initiallyExpanded = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        iconColor: cs.primary,
        collapsedIconColor: cs.onSurfaceVariant,
        title: Text(title,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        children: points
            .map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(text,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final range = '$sleepStartLabel → $sleepEndLabel';
    final sleepModeStatus = !muteSpeechAfterMidnight
        ? 'Sleep mode is OFF'
        : (nightMuteMode == 'manual'
              ? 'Sleep mode: ON • Manual'
              : 'Sleep mode: ON • Automatic');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primaryContainer, cs.surfaceContainerLow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sleepModeStatus,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (muteSpeechAfterMidnight)
                      Text('Current range: $range',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Quick Start',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        _quickStep(
          context, 1,
          'Configure timer and speech',
          'Open Timer Setup, choose minutes, speech interval, and optional chain preset.',
        ),
        _quickStep(
          context, 2,
          'Set sleep behavior',
          'Open Settings, enable Sleep mode, pick Manual or Automatic, and choose time range.',
        ),
        _quickStep(
          context, 3,
          'Use widget controls',
          'From home screen widget, toggle speech, start/stop timer, or launch quick 25m/resume.',
        ),
        const SizedBox(height: 8),
        Text('FAQ',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        _faqItem(
          context,
          title: 'Speaking Clock',
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
          title: 'Sleep Mode',
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
            'If widget command feels delayed, wait 1-2 seconds for sync.',
            'Keep notification and battery permissions allowed for stable background behavior.',
            'After reboot, enable Accessibility Service in Settings for auto-restart.',
          ],
        ),
      ],
    );
  }
}
