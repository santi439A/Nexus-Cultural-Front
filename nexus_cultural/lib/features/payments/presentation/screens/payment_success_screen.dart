import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  static const routeName = '/payment-success';

  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(activeOrderProvider);

    return Scaffold(
      appBar: NexusAppBar(
        title: 'Pago Exitoso',
        subtitle: 'Compra Protegida y Confirmada',
        showBack: false,
        voiceExplanation:
            '¡Felicitaciones! Tu pago ha sido aprobado con éxito. La orden número ${order.orderNumber} está en preparación en el taller artesanal. Tu compra apoya directamente a los maestros colombianos.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner M18

              // Big Green Checkmark
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: NexusColors.greenProtection,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: NexusColors.greenProtection.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.check, size: 54, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                '¡Pago Exitoso y Confirmado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                  color: NexusColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Orden ${order.orderNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: NexusColors.primary,
                ),
              ),

              const SizedBox(height: 16),
              const VoiceAssistCard(
                title: 'Lectura de tu comprobante',
                subtitle: 'Confirmación de despacho',
                textToRead:
                    'Tu pago fue recibido exitosamente. Tu pedido se despachará con empaque protegido y certificado de autenticidad.',
              ),

              const SizedBox(height: 20),
              // Order Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  border: Border.all(color: NexusColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fecha de compra:', style: TextStyle(color: NexusColors.textSecondary)),
                        Text(order.orderDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Entrega estimada:', style: TextStyle(color: NexusColors.textSecondary)),
                        Text(order.estimatedDelivery, style: const TextStyle(fontWeight: FontWeight.bold, color: NexusColors.greenDark)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pagado:', style: TextStyle(color: NexusColors.textSecondary)),
                        Text('\$${order.totalAmount.toInt()} COP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // CTA 1: Ver Comprobante Oficial DIAN (M18B)
              OutlinedButton.icon(
                onPressed: () {
                  context.push('/invoice');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: NexusColors.primary, width: 2),
                ),
                icon: const Icon(Icons.receipt_long, color: NexusColors.primary),
                label: const Text(
                  'Ver Comprobante Electrónico DIAN',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.primary),
                ),
              ),

              const SizedBox(height: 12),
              // CTA 2: Ver Seguimiento en Tiempo Real (M19)
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/order-tracking');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusColors.primary,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  ),
                ),
                icon: const Icon(Icons.local_shipping, size: 24),
                label: const Text(
                  'Rastrear mi Envío en 5 Etapas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Volver al Catálogo Principal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
