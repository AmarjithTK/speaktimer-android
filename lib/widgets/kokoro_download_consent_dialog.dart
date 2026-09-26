import 'package:flutter/material.dart';

class KokoroDownloadConsentDialog extends StatelessWidget {
  const KokoroDownloadConsentDialog({
    required this.onAccept,
    required this.onDecline,
    super.key,
  });

  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download the Kokoro English voice?'),
      content: const Text(
        'Solas Flow can download a 140 MiB English speech model for more '
        'natural English announcements. The download is verified and then '
        'available offline. English and Malayalam bundled voices remain '
        'available if you skip it. You can download, cancel, or retry later '
        'from Settings.',
      ),
      actions: [
        TextButton(onPressed: onDecline, child: const Text('Keep Piper')),
        FilledButton.icon(
          onPressed: onAccept,
          icon: const Icon(Icons.download_rounded),
          label: const Text('Accept and download'),
        ),
      ],
    );
  }
}
