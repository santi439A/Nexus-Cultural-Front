import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class RoleSelectionScreen extends ConsumerWidget {
  static const routeName = '/role-selection';

  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(userRoleProvider);

    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Selección de Rol',
        subtitle: '¿Cómo deseas participar en Nexus?',
        voiceExplanation:
            'Pantalla de selección de rol. Elige si eres un maestro artesano que desea compartir y vender sus obras, o si eres un comprador o coleccionista cultural.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Contextual Reference Banner

              const VoiceAssistCard(
                title: 'Orientación para adultos mayores',
                subtitle: 'Pulsa para escuchar con claridad',
                textToRead:
                    'Si elaboras mochilas, cerámica, sombreros o talla con tus manos, selecciona la opción Maestro Artesano. Si deseas adquirir piezas auténticas, selecciona Comprador.',
              ),

              const SizedBox(height: 16),
              // Option 1: Maestro Artesano
              _RoleCard(
                title: 'Soy Maestro Artesano',
                description:
                    'Elaboro piezas tradicionales en mi taller o resguardo. Deseo mostrar mi técnica, contar mi historia y vender a precio justo con pago directo.',
                icon: Icons.front_hand,
                badgeText: 'Preservación Cultural',
                isSelected: currentRole == UserRole.artisan,
                onTap: () {
                  ref.read(userRoleProvider.notifier).state = UserRole.artisan;
                },
              ),

              const SizedBox(height: 16),
              // Option 2: Comprador / Coleccionista
              _RoleCard(
                title: 'Soy Comprador o Coleccionista',
                description:
                    'Busco piezas hechas a mano con certificado de autenticidad, trazabilidad de origen y comercio solidario 100% garantizado.',
                icon: Icons.travel_explore,
                badgeText: 'Apoyo Directo a Talleres',
                isSelected: currentRole == UserRole.buyer,
                onTap: () {
                  ref.read(userRoleProvider.notifier).state = UserRole.buyer;
                },
              ),

              const SizedBox(height: 28),
              // Action Button to Continue to Registration (M03)
              ElevatedButton.icon(
                onPressed: () {
                  final role = ref.read(userRoleProvider);
                  if (role == UserRole.artisan) {
                    context.push('/register-artisan');
                  } else {
                    context.push('/register-buyer');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusColors.primary,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward, size: 24),
                label: const Text(
                  'Continuar al Registro',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String badgeText;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.badgeText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? NexusColors.surfaceHighlight : Colors.white,
          borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
          border: Border.all(
            color: isSelected ? NexusColors.primary : NexusColors.border,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? NexusColors.primary : NexusColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: isSelected ? Colors.white : NexusColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: NexusColors.greenProtectionContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: NexusColors.greenDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? NexusColors.primary : NexusColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<bool>(
                  value: true,
                  groupValue: isSelected,
                  activeColor: NexusColors.primary,
                  onChanged: (_) => onTap(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: NexusColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
