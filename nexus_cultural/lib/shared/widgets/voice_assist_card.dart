import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/accessibility/voice_reader_service.dart';

class VoiceAssistCard extends ConsumerWidget {
  final String title;
  final String textToRead;
  final String? subtitle;

  const VoiceAssistCard({
    super.key,
    required this.title,
    required this.textToRead,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceService = ref.watch(voiceReaderProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexusColors.greenProtectionContainer,
        borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
        border: Border.all(color: NexusColors.greenProtection.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: NexusColors.greenProtection,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hearing,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NexusColors.greenDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: NexusColors.greenDark.withOpacity(0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              voiceService.speak(textToRead);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusColors.greenProtection,
              foregroundColor: Colors.white,
              minimumSize: const Size(96, NexusAccessibility.minTouchTarget),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.play_arrow, size: 24),
            label: const Text(
              'Oír',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
