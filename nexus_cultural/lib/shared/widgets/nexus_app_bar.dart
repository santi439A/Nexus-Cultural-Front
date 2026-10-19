import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/accessibility/voice_reader_service.dart';

class NexusAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final String? voiceExplanation;
  final List<Widget>? actions;

  const NexusAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.voiceExplanation,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceService = ref.watch(voiceReaderProvider);

    return AppBar(
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: NexusColors.surfaceBackground,
      titleSpacing: 16,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                iconSize: 32,
                tooltip: 'Volver a la pantalla anterior',
                style: IconButton.styleFrom(
                  minimumSize: const Size(NexusAccessibility.minTouchTarget, NexusAccessibility.minTouchTarget),
                  backgroundColor: NexusColors.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.arrow_back, color: NexusColors.primary),
                onPressed: () {
                  if (onBack != null) {
                    onBack!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: NexusColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'N',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: NexusColors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: NexusColors.textSecondary,
              ),
            ),
        ],
      ),
      actions: [
        if (voiceExplanation != null)
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: IconButton(
              iconSize: 28,
              tooltip: 'Escuchar explicación de esta pantalla con voz guiada',
              style: IconButton.styleFrom(
                minimumSize: const Size(NexusAccessibility.minTouchTarget, NexusAccessibility.minTouchTarget),
                backgroundColor: NexusColors.surfaceHighlight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: NexusColors.borderLight),
                ),
              ),
              icon: const Icon(Icons.volume_up, color: NexusColors.primary),
              onPressed: () {
                voiceService.speak(voiceExplanation!);
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TextButton.icon(
            onPressed: () {
              voiceService.speak(
                'Nexus Cultural conecta directamente con maestros artesanos mayores en Colombia. Tu compra está 100% protegida y el 90% del valor va a los talleres familiares.'
              );
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(60, NexusAccessibility.minTouchTarget),
              backgroundColor: NexusColors.greenProtectionContainer,
              foregroundColor: NexusColors.greenDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.help_outline, size: 22),
            label: const Text(
              'Ayuda',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ...?actions,
      ],
    );
  }
}
