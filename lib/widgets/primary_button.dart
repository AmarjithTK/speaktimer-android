import 'package:flutter/material.dart';

/// Primary action button — full width, accent fill, clear label.
///
/// Used for Start, Pause, Resume — the dominant action on each screen.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: compact ? 44 : 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20) : null,
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label),
        ),
      ),
    );
  }
}
