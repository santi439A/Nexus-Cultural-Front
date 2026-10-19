import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class CulturalStoryScreen extends ConsumerWidget {
  static const routeName = '/cultural-story';

  const CulturalStoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(selectedProductProvider);

    return Scaffold(
      appBar: NexusAppBar(
        title: 'Historia y Memoria',
        subtitle: product.artisan.community,
        voiceExplanation:
            'Preservación de la memoria viva. Conoce el significado del mito de Wale’kerü, la araña tejedora que enseñó a las mujeres Wayúu a dibujar las constelaciones sobre el hilo.',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18.0),
          children: [
            // Banner M09C

            const VoiceAssistCard(
              title: 'El mito de Wale’kerü (La Araña Tejedora)',
              subtitle: 'Narración oral del Pueblo Wayúu',
              textToRead:
                  'Cuenta la tradición que la araña Wale’kerü tejía antes del amanecer fajas y mochilas con hilos de rocío. Al ver su destreza, una niña le pidió que le enseñara el arte para que su pueblo nunca olvidara el camino de las estrellas.',
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                border: Border.all(color: NexusColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simbología de las Figuras Kanaas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'PlayfairDisplay'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.symbolism,
                    style: const TextStyle(fontSize: 16, height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Los Kanaas no son simples adornos decorativos; son un lenguaje visual que registra genealogías familiares, ciclos lunares y las fuentes de agua dulce en el desierto de La Guajira.',
                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: NexusColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
