import 'package:flutter/material.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class ClockPanel extends StatelessWidget {
  final bool clockOn;
  final String currentTimeDisplay;
  final int clockIntervalMins;
  final bool motivationOn;
  final List<int> clockIntervalOptions;
  final VoidCallback toggleClock;
  final ValueChanged<int?> onIntervalChanged;
  final ValueChanged<bool?> onMotivationChanged;

  const ClockPanel({
    super.key,
    required this.clockOn,
    required this.currentTimeDisplay,
    required this.clockIntervalMins,
    required this.motivationOn,
    required this.clockIntervalOptions,
    required this.toggleClock,
    required this.onIntervalChanged,
    required this.onMotivationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return panelContainer(
      active: clockOn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle("🕐 Speaking Clock", "A"),
          const SizedBox(height: 8),
          Text(
            currentTimeDisplay,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: palette.primary,
              letterSpacing: 1.2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          sectionLabel("Announce every"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: palette.accent,
              border: Border.all(color: palette.primary, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<int>(
              value: clockIntervalMins,
              isExpanded: true,
              underline: const SizedBox(),
              iconEnabledColor: palette.primary,
              dropdownColor: palette.accent,
              items: clockIntervalOptions.map((e) => DropdownMenuItem(
                value: e,
                child: Text("$e min", style: TextStyle(color: palette.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              )).toList(),
              onChanged: onIntervalChanged,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: motivationOn,
                activeColor: palette.primary,
                checkColor: palette.accent,
                onChanged: onMotivationChanged,
              ),
              Expanded(child: sectionLabel("Speak motivational quote after time")),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: toggleClock,
            style: ElevatedButton.styleFrom(
              backgroundColor: clockOn ? palette.primary : palette.accent,
              foregroundColor: clockOn ? palette.accent : palette.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              side: BorderSide(color: palette.primary, width: 2),
            ),
            child: Text(clockOn ? "🔔 ON" : "🔕 OFF", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }
}
