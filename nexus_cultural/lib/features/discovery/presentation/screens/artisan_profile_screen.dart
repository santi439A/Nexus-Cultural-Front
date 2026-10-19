import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class ArtisanProfileScreen extends ConsumerWidget {
  static const routeName = '/artisan-profile';

  const ArtisanProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(selectedProductProvider);
    final artisan = product.artisan;

    return Scaffold(
      appBar: NexusAppBar(
        title: artisan.name,
        subtitle: artisan.community,
        voiceExplanation:
            'Perfil del maestro artesano ${artisan.name}. Cuenta con más de ${artisan.yearsOfExperience} años de experiencia en tejeduría ancestral en ${artisan.department}.',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18.0),
          children: [
            // Header with Avatar and Community
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: NexusColors.surfaceHighlight,
                      shape: BoxShape.circle,
                      border: Border.all(color: NexusColors.primary, width: 3),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, size: 64, color: NexusColors.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    artisan.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'PlayfairDisplay'),
                  ),
                  Text(
                    artisan.community,
                    style: const TextStyle(fontSize: 15, color: NexusColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: NexusColors.greenProtectionContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Taller Verificado · 38 Años de Oficio',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NexusColors.greenDark),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            VoiceAssistCard(
              title: 'Escuchar historia de vida de doña María',
              subtitle: 'Tradición oral transmitida a sus hijas',
              textToRead:
                  'Aprendí a hilar el algodón silvestre a los ocho años viendo tejer a mi abuela en la enramada de Uribia. Hoy mis tres hijas y nietas continúan este legado.',
            ),

            const SizedBox(height: 16),
            const Text(
              'Biografía y Saber Ancestral:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                border: Border.all(color: NexusColors.border),
              ),
              child: Text(
                artisan.bio,
                style: const TextStyle(fontSize: 16, height: 1.45),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/cultural-story');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NexusColors.primary,
                minimumSize: const Size(double.infinity, 56),
              ),
              icon: const Icon(Icons.history_edu, size: 24),
              label: const Text('Conocer la Historia y Simbología Completa', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
