import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class SalesMetricsScreen extends ConsumerWidget {
  static const routeName = '/sales-metrics';

  const SalesMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Métricas de Ventas',
        subtitle: 'Impacto Comunitario y Ganancias',
        voiceExplanation:
            'Resumen de tus ventas este mes. Has recibido dos millones cuatrocientos cincuenta mil pesos directamente en tu cuenta con nueve piezas vendidas y calificación de 4.9 estrellas.',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18.0),
          children: [

            const VoiceAssistCard(
              title: 'Resumen en voz alta',
              subtitle: 'Ingresos directos sin deducciones',
              textToRead:
                  'Taller Doña María en Uribia La Guajira: Has entregado 9 piezas este mes a compradores en Bogotá, Medellín y Cali.',
            ),

            const SizedBox(height: 16),
            // Hero Earnings Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: NexusColors.textPrimary,
                borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingresos Directos Transferidos',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NexusColors.primaryFixed),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '\$2.450.000 COP',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'PlayfairDisplay', color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Depositado en tu cuenta Bancolombia sin deducciones abusivas.',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Metrics Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                      border: Border.all(color: NexusColors.border),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.inventory_2, color: NexusColors.primary, size: 26),
                        SizedBox(height: 8),
                        Text('Piezas Vendidas', style: TextStyle(fontSize: 13, color: NexusColors.textSecondary)),
                        Text('9', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: NexusColors.textPrimary)),
                        Text('+3 este mes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NexusColors.greenDark)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                      border: Border.all(color: NexusColors.border),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 26),
                        SizedBox(height: 8),
                        Text('Calificación', style: TextStyle(fontSize: 13, color: NexusColors.textSecondary)),
                        Text('4.9 / 5', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: NexusColors.textPrimary)),
                        Text('48 comentarios', style: TextStyle(fontSize: 12, color: NexusColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Buyer Comments
            const Text(
              'Testimonios de Compradores:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: NexusColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NexusColors.borderLight),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"El tejido de doña María es una joya viva. Se siente el trabajo paciente de días enteros en La Guajira."',
                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 6),
                  Text('— Camila O., Bogotá · Compradora verificada', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NexusColors.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
