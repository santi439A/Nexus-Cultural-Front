import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class CheckoutSummaryScreen extends ConsumerWidget {
  static const routeName = '/checkout-summary';

  const CheckoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final shipping = ref.watch(shippingFormProvider);
    final total = cartNotifier.total;
    final artisanDirectPayout = cartNotifier.artisanDirectPayout;

    return Scaffold(
      appBar: NexusAppBar(
        title: 'Resumen de Compra',
        subtitle: 'Paso 2 de 3 en Pago',
        voiceExplanation:
            'Verifica tu pedido antes de pagar. Revisa los datos de envío a ${shipping.city} y confirma el valor total de ${total.toInt()} pesos.',
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: NexusColors.borderLight)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/payment-method');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusColors.primary,
              minimumSize: const Size(double.infinity, 58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
              ),
            ),
            icon: const Icon(Icons.payment, size: 24),
            label: Text(
              'Confirmar e Ir a Pagar (\${total.toInt()} COP)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18.0),
          children: [
            // Banner M15

            VoiceAssistCard(
              title: 'Resumen narrado de compra',
              subtitle: 'Total a pagar: \$${total.toInt()} COP',
              textToRead:
                  'Resumen de tu pedido: Envío a nombre de ${shipping.fullName} en ${shipping.city}. Total a pagar ${total.toInt()} pesos, con ${artisanDirectPayout.toInt()} pesos destinados directamente a los artesanos.',
            ),

            const SizedBox(height: 16),
            // Shipping Details Card
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
                      const Row(
                        children: [
                          Icon(Icons.local_shipping, color: NexusColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Dirección de Envío',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Editar', style: TextStyle(fontWeight: FontWeight.bold, color: NexusColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(shipping.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${shipping.address}, ${shipping.city}'),
                  Text('Teléfono: ${shipping.phone}'),
                  if (shipping.deliveryNotes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('Nota: ${shipping.deliveryNotes}', style: const TextStyle(fontStyle: FontStyle.italic, color: NexusColors.textSecondary)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Items Summary
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
                  const Text(
                    'Piezas Artesanales a Recibir',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ...cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.product.name} (${item.product.artisan.name})',
                                style: const TextStyle(fontSize: 15, color: NexusColors.textPrimary),
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toInt()} COP',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Envío nacional protegido:', style: TextStyle(fontSize: 15, color: NexusColors.textSecondary)),
                      Text('\$${cartNotifier.shippingCost.toInt()} COP', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a pagar:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
                      ),
                      Text(
                        '\$${total.toInt()} COP',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: NexusColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Direct Artisan Protection Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: NexusColors.greenProtectionContainer,
                borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                border: Border.all(color: NexusColors.greenProtection.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.handshake, color: NexusColors.greenDark, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tus \$${artisanDirectPayout.toInt()} COP de pago van directamente a la cuenta del artesano sin descuentos comerciales.',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NexusColors.greenDark),
                    ),
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
