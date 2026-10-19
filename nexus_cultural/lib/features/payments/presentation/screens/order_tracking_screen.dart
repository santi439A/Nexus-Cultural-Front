import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/nexus_bottom_nav.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class OrderTrackingScreen extends ConsumerWidget {
  static const routeName = '/order-tracking';

  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(activeOrderProvider);
    final stages = [
      {'title': 'Pago Confirmado', 'sub': '15 Oct, 10:24 AM', 'done': true},
      {'title': 'Embalaje Artesanal Protegido', 'sub': '16 Oct, 3:15 PM · Taller La Guajira', 'done': true},
      {'title': 'Recogido por Transportadora', 'sub': '17 Oct, 9:00 AM · Guía ${order.trackingGuide}', 'done': true},
      {'title': 'En Camino a tu Ciudad (Bogotá)', 'sub': 'En tránsito seguro · Entrega 19-21 Oct', 'done': true, 'current': true},
      {'title': 'Entrega en tu Hogar', 'sub': 'Pendiente de entrega final', 'done': false},
    ];

    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Seguimiento de Envíos',
        subtitle: 'Trazabilidad y Garantía en 5 Etapas',
        voiceExplanation:
            'Seguimiento en tiempo real de tu orden. Tu pedido se encuentra en la etapa cuatro de cinco: en camino seguro hacia Bogotá con entrega estimada entre el diecinueve y el veintiuno de octubre.',
      ),
      bottomNavigationBar: NexusBottomNav(
        currentIndex: 4,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.push('/filters');
              break;
            case 2:
              context.push('/artisan-dashboard');
              break;
            case 3:
              context.push('/cart');
              break;
            case 4:
              break;
          }
        },
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18.0),
          children: [
            // Banner M19

            VoiceAssistCard(
              title: 'Estado actual de tu envío',
              subtitle: 'Etapa 4 de 5: En camino',
              textToRead:
                  'Tu pedido con la Mochila Wayúu y el Jarrón de Barro Negro va en camino a Bogotá por la transportadora ${order.carrierName}. Guía de rastreo número ${order.trackingGuide}.',
            ),

            const SizedBox(height: 16),
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                border: Border.all(color: NexusColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Orden ${order.orderNumber}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.primary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: NexusColors.greenProtectionContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'En camino',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NexusColors.greenDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Transportadora: ${order.carrierName}'),
                  Text('Número de Guía: ${order.trackingGuide}'),
                  Text('Fecha Estimada: ${order.estimatedDelivery}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Progreso del Envío (5 Etapas):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
            ),
            const SizedBox(height: 12),

            // Stepper timeline
            ...List.generate(stages.length, (idx) {
              final stage = stages[idx];
              final isDone = stage['done'] as bool;
              final isCurrent = stage['current'] == true;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? NexusColors.primary
                              : isDone
                                  ? NexusColors.greenProtection
                                  : NexusColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone ? Icons.check : Icons.circle,
                          color: isDone ? Colors.white : NexusColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      if (idx < stages.length - 1)
                        Container(
                          width: 3,
                          height: 44,
                          color: isDone ? NexusColors.greenProtection : NexusColors.borderLight,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isCurrent ? NexusColors.primary : NexusColors.textPrimary,
                            ),
                          ),
                          Text(
                            stage['sub'] as String,
                            style: const TextStyle(fontSize: 13, color: NexusColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 12),
            // Guarantee & Refund Action Button (M20)
            OutlinedButton.icon(
              onPressed: () {
                context.push('/refund-request');
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: NexusColors.border, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                ),
              ),
              icon: const Icon(Icons.assignment_return, color: NexusColors.primary),
              label: const Text(
                'Solicitar Devolución o Reembolso de Garantía',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NexusColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
