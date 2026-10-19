import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../core/accessibility/voice_reader_service.dart';

class WelcomeScreen extends ConsumerWidget {
  static const routeName = '/welcome';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceService = ref.watch(voiceReaderProvider);

    return Scaffold(
      backgroundColor: NexusColors.surfaceBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Accessibility Voice Helper Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  onPressed: () {
                    voiceService.speak(
                      'Bienvenido a Nexus Cultural. La plataforma móvil que conecta a nuestros artesanos colombianos mayores con personas que valoran el arte hecho a mano. Pulsa el botón café para comenzar o el botón blanco si ya tienes cuenta.'
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: NexusColors.surfaceContainer,
                    foregroundColor: NexusColors.primary,
                    minimumSize: const Size(120, NexusAccessibility.minTouchTarget),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: NexusColors.border),
                    ),
                  ),
                  icon: const Icon(Icons.volume_up, size: 24),
                  label: const Text('Escuchar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),

              // Logo oficial sin círculo
              Image.asset(
                'assets/images/logo_nexus_cultural.png',
                width: MediaQuery.of(context).size.width * 0.75, // 75% del ancho de la pantalla
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: NexusColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: NexusColors.border),
                ),
                child: const Text(
                  'Artesanías Ancestrales Colombianas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: NexusColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Value Proposition for Elderly Artisans and Buyers
              const Text(
                'El punto de encuentro digno entre el saber ancestral de nuestros abuelos artesanos y quienes valoran la autenticidad colombiana.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.45,
                  color: NexusColors.textSecondary,
                ),
              ),

              const SizedBox(height: 36),
              // Primary CTA: Comenzar / Elegir Rol (Min 56px touch target)
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/role-selection');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.arrow_forward, size: 26),
                label: const Text(
                  'Comenzar Experiencia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),
              // Secondary CTA: Ya tengo cuenta / Ingresar (Min 56px touch target)
              OutlinedButton.icon(
                onPressed: () {
                  context.push('/login');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  side: const BorderSide(color: NexusColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  ),
                ),
                icon: const Icon(Icons.lock_open, size: 24, color: NexusColors.primary),
                label: const Text(
                  'Ya tengo una cuenta registrada',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.primary),
                ),
              ),

              const SizedBox(height: 32),
              // Trust and Fair Trade Guarantee badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NexusColors.greenProtectionContainer,
                  borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  border: Border.all(color: NexusColors.greenProtection.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, color: NexusColors.greenDark, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Comercio ético verificado: 90% directo a los artesanos y compras protegidas en toda Colombia.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: NexusColors.greenDark.withOpacity(0.95),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}