import 'package:flutter/material.dart';
import '../theme/palette.dart';
import 'ui_helpers.dart';

class PresetsPanel extends StatelessWidget {
  final List<int> presetValues;
  final ValueChanged<int> choosePreset;

  const PresetsPanel({
    super.key,
    required this.presetValues,
    required this.choosePreset,
  });

  @override
  Widget build(BuildContext context) {
    return panelContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle("⚡ Presets", ""),
          sectionLabel("Tap to start instantly"),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.8,
            children: presetValues.map((p) {
              return InkWell(
                onTap: () => choosePreset(p),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.bg,
                    border: Border.all(color: palette.primary, width: p == 25 ? 2 : 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    p.toString(),
                    style: TextStyle(
                      color: palette.primary,
                      fontWeight: p >= 90 ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text("🍅 25 = Pomodoro  ·  bold = deep work", style: TextStyle(fontSize: 10, color: palette.primary.withAlpha(140))),
          )
        ],
      )
    );
  }
}
